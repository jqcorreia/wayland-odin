#+feature dynamic-literals
package wayland

import "core:encoding/xml"

import "core:fmt"
import "core:os"
import "core:strings"
import "mustache"

Arg :: struct {
	name:      string,
	type:      string,
	emit_type: string,
	interface: string,
	nullable:  bool,
	_enum:     string,
	is_new_id: bool,
	is_last:   bool,
}

Event :: struct {
	name:           string,
	args:           [dynamic]Arg,
	type:           string,
	pascal_name:    string,
	interface_name: string,
	struct_name:    string,
}

Request :: struct {
	name:           string,
	args:           [dynamic]Arg,
	num_new_ids:    int,
	opcode:         int,
	type:           string,
	interface_name: string,
	return_string:  string,
	args_string:    string,
	proc_body:      string,
}

Enum :: struct {
	name:   string,
	values: map[string]string,
}

Interface :: struct {
	name:         string,
	events:       [dynamic]Event,
	requests:     [dynamic]Request,
	version:      string,
	enums:        [dynamic]Enum,
	pascal_name:  string,
	upper_case:   string,
	add_listener: bool,
}

type_map := map[string]string {
	"int"    = "c.int32_t",
	"fd"     = "c.int32_t",
	"new_id" = "c.uint32_t",
	"uint"   = "c.uint32_t",
	"fixed"  = "wl_fixed_t", // This has some functions that convert from 'fixed' to/from doubles and ints
	"string" = "cstring",
	"object" = "rawptr",
	"array"  = "^wl_array",
}

global_events: [dynamic]Event

emit_type :: proc(arg: Arg) -> string {
	if arg.type == "object" {
		return arg.interface == "" ? "rawptr" : fmt.tprintf("^%s", arg.interface)
	}

	return type_map[arg.type]
}

process_event :: proc(doc: ^xml.Document, interface: ^Interface, index: u32) -> Event {
	event_name, _ := xml.find_attribute_val_by_key(doc, index, "name")
	event_type, _ := xml.find_attribute_val_by_key(doc, index, "type")
	el := doc.elements[index]
	pascal_name := strings.to_pascal_case(event_name)
	event := Event {
		name           = event_name,
		type           = event_type,
		pascal_name    = pascal_name,
		interface_name = interface.name,
		struct_name    = fmt.tprintf("%s%s", interface.pascal_name, pascal_name),
	}

	for val in el.value {
		el := doc.elements[val.(u32)]

		if el.ident == "arg" {
			arg_name, _ := xml.find_attribute_val_by_key(doc, val.(u32), "name")
			arg_type, _ := xml.find_attribute_val_by_key(doc, val.(u32), "type")
			arg_nullable, _ := xml.find_attribute_val_by_key(doc, val.(u32), "allow-null")
			arg_interface, _ := xml.find_attribute_val_by_key(doc, val.(u32), "interface")
			arg_enum, _ := xml.find_attribute_val_by_key(doc, val.(u32), "enum")

			nullable := arg_nullable == "true" ? true : false
			arg := Arg {
				name      = arg_name,
				type      = arg_type,
				interface = arg_interface,
				nullable  = nullable,
				_enum     = arg_enum,
			}
			arg.emit_type = emit_type(arg)
			append(&event.args, arg)
		}
	}
	if len(event.args) > 0 {
		event.args[len(event.args) - 1].is_last = true
	}
	return event
}

process_request :: proc(
	doc: ^xml.Document,
	interface: ^Interface,
	index: u32,
	opcode: int,
) -> Request {
	request_name, _ := xml.find_attribute_val_by_key(doc, index, "name")
	request_type, _ := xml.find_attribute_val_by_key(doc, index, "type")
	el := doc.elements[index]
	request := Request {
		name           = request_name,
		opcode         = opcode,
		type           = request_type,
		interface_name = interface.name,
	}

	num_new_ids := 0
	for val in el.value {
		el := doc.elements[val.(u32)]

		if el.ident == "arg" {
			arg_name, _ := xml.find_attribute_val_by_key(doc, val.(u32), "name")
			arg_type, _ := xml.find_attribute_val_by_key(doc, val.(u32), "type")
			arg_nullable, _ := xml.find_attribute_val_by_key(doc, val.(u32), "allow-null")
			arg_enum, _ := xml.find_attribute_val_by_key(doc, val.(u32), "enum")
			nullable := arg_nullable == "true" ? true : false

			if arg_type == "new_id" {
				num_new_ids += 1
			}

			arg_interface, _ := xml.find_attribute_val_by_key(doc, val.(u32), "interface")
			arg := Arg {
				name      = arg_name,
				type      = arg_type,
				interface = arg_interface,
				nullable  = nullable,
				_enum     = arg_enum,
			}
			arg.emit_type = emit_type(arg)
			append(&request.args, arg)
		}
	}
	if len(request.args) > 0 {
		request.args[len(request.args) - 1].is_last = true
	}
	request.num_new_ids = num_new_ids

	// NOTE: The following is still code pulled and/or inspired from libwayland, should be cleaned up
	// Compute return type string
	if request.num_new_ids > 1 {
		fmt.println("Not generating stub for {request.name}. new_ids > 1")
		return request
	}
	ret: ^Arg = nil
	ret_string: string = ""
	args_string: [dynamic]string

	// Find return argument
	for &arg in request.args {
		if arg.type == "new_id" {
			ret = &arg
			ret.is_new_id = true
			break
		}
	}

	// Calculate return type string
	if ret == nil {
		ret_string = ""
	} else if ret != nil && ret.interface == "" {
		ret_string = "rawptr"
	} else {
		ret_string = fmt.tprintf("^%s", strings.to_pascal_case(ret.interface))
	}

	// Calculate args for template
	for &arg in request.args {
		if arg.type == "new_id" && arg.interface == "" {
			append(&args_string, fmt.tprintf("interface: ^wl_interface, version: c.uint32_t"))
			continue
		} else if arg.type == "new_id" {
			continue
		} else if arg._enum != "" {
			// Deal with enums from other interfaces
			// Base case it the interface itself and the value from the "enum" field
			enum_name := arg._enum
			interface_name := interface.name

			// Otherwise it will come in the format <interface>.<enum>
			if strings.contains(arg._enum, ".") {
				interface_name = strings.split(arg._enum, ".")[0]
				enum_name = strings.split(arg._enum, ".")[1]
			}

			// FOR NOW IGNORE THE ABOVE SINCE TYPING THE ENUMS IS A MESS
			append(
				&args_string,
				fmt.tprintf(
					"%s : c.uint32_t",
					arg.name,
					// fmt.tprintf("%s_%s", interface_name, enum_name),
				),
			)
			continue
		} else {
			append(&args_string, fmt.tprintf("%s : %s", arg.name, emit_type(arg)))
		}
	}


	// Calculate procedure body
	sb := strings.builder_make()
	if ret != nil {
		fmt.sbprintf(&sb, "\t%s: ^wl_proxy\n\t%s = ", ret.name, ret.name)
	}

	strings.write_string(
		&sb,
		fmt.tprintf(
			`proxy_marshal_flags(
                self.proxy,
		        %d`,
			request.opcode, //NOTE: maybe emit enums and use them here
		),
	)

	if ret != nil {
		if ret.interface != "" {
			//         /* Normal factory case, an arg has type="new_id" and
			//          * an interface is provided */
			fmt.sbprintf(&sb, ", &%s_interface", ret.interface)
		} else {
			//         /* an arg has type ="new_id" but interface is not
			//          * provided, such as in wl_registry.bind */
			strings.write_string(&sb, fmt.tprintf(", interface"))
		}
	} else {
		//     /* No args have type="new_id" */
		strings.write_string(&sb, fmt.tprintf(", nil"))
	}

	if ret != nil && ret.interface == "" {
		strings.write_string(&sb, fmt.tprintf(", version"))
	} else {
		strings.write_string(&sb, fmt.tprintf(", proxy_get_version(self.proxy)"))
	}
	strings.write_string(
		&sb,
		fmt.tprintf(", %s", request.type == "destructor" ? "WL_MARSHAL_FLAG_DESTROY" : "0"),
	)

	for arg in request.args {
		if (arg.type == "new_id") {
			if (arg.interface == "") {
				strings.write_string(&sb, fmt.tprintf(", interface.name, version"))
			}
			strings.write_string(&sb, fmt.tprintf(", nil"))
		} else {
			strings.write_string(&sb, fmt.tprintf(", %s", arg.name))
		}
	}

	strings.write_string(&sb, fmt.tprintf(");\n\n"))

	if (ret != nil && ret.interface == "") {
		strings.write_string(&sb, fmt.tprintf("\n\treturn cast(rawptr)%s;\n", ret.name))
	} else if (ret != nil) {
		strings.write_string(
			&sb,
			fmt.tprintf("\n\treturn create_%s(%s)\n", ret.interface, ret.name),
		)
	}

	request.return_string = ret_string
	request.args_string = strings.join(args_string[:], ",")
	request.proc_body = strings.to_string(sb)
	return request
}

process_enum :: proc(doc: ^xml.Document, interface: ^Interface, index: u32) -> Enum {
	enum_name, _ := xml.find_attribute_val_by_key(doc, index, "name")
	request_type, _ := xml.find_attribute_val_by_key(doc, index, "type")
	el := doc.elements[index]

	_enum := Enum {
		name   = enum_name,
		values = make(map[string]string),
	}

	for val in el.value {
		el := doc.elements[val.(u32)]

		if el.ident == "entry" {
			entry_name, _ := xml.find_attribute_val_by_key(doc, val.(u32), "name")
			entry_value, _ := xml.find_attribute_val_by_key(doc, val.(u32), "value")
			_enum.values[entry_name] = entry_value
		}
	}
	return _enum
}

process_interface :: proc(doc: ^xml.Document, el: xml.Element) -> Interface {
	interface := Interface{}

	for attr in el.attribs {
		if attr.key == "name" {
			interface.name = attr.val
			if interface.name != "wl_display" do interface.add_listener = true
			interface.pascal_name = strings.to_pascal_case(interface.name)
			interface.upper_case = strings.to_upper(interface.name)
		}
		if attr.key == "version" {
			interface.version = attr.val
		}
	}

	// Opcodes are defined by spec order, just increment it for every request processed
	opcode := 0
	for val in el.value {
		el := doc.elements[val.(u32)]
		if el.ident == "event" {
			event := process_event(doc, &interface, val.(u32))
			append(&interface.events, event)
			append(&global_events, event) // Add a copy to the global event list
		}
		if el.ident == "request" {
			append(&interface.requests, process_request(doc, &interface, val.(u32), opcode))
			opcode += 1
		}
		if el.ident == "enum" {
			append(&interface.enums, process_enum(doc, &interface, val.(u32)))
		}
	}

	return interface
}

emit_interface_code :: proc(out: ^os.File, interface: Interface) {
	template := #load("./templates/interface.txt")

	result, _ := mustache.render(string(template), interface)
	fmt.println(result)
	fmt.fprint(out, result)
	// emit_structs(out, interface)
	// emit_create_func(out, interface)
	// emit_listeners(out, interface)
	// emit_request_stubs(out, interface)
	// emit_destroy(out, interface)
	// emit_private_code(out, interface)
	// emit_enums(out, interface)
}

emit_events_union :: proc(out: ^os.File) {
	data: struct {
		items: []Event,
	} = {
		items = global_events[:],
	}
	template := #load("./templates/events.txt")
	result, _ := mustache.render(string(template), data)
	fmt.println(result)
	fmt.fprint(out, result)
}
emit_enums :: proc(out: ^os.File, interface: Interface) {
	for _enum in interface.enums {
		for key, value in _enum.values {
			fmt.fprintf(
				out,
				"%s_%s_%s :: %s\n",
				strings.to_upper(interface.name),
				strings.to_upper(_enum.name),
				strings.to_upper(key),
				value,
			)
		}
	}
	fmt.fprintf(out, "\n")
}

emit_destroy :: proc(out: ^os.File, interface: Interface) {
	// Emit function destroy
	if interface.name == "wl_display" {
		return
	}

	has_destroy := false
	for req in interface.requests {
		if req.name == "destroy" {
			has_destroy = true
			break
		}
	}

	if !has_destroy {
		destroy_template := `
%s_destroy :: proc "c" (%s: ^%s) {{
	proxy_destroy(cast(^wl_proxy)%s)
}};

`


		fmt.fprintf(
			out,
			destroy_template,
			interface.name,
			interface.name,
			interface.name,
			interface.name,
		)
	}
}

emit_listeners :: proc(out: ^os.File, interface: Interface) {
	fmt.fprintf(out, "%s_listener :: struct {{\n", interface.name)

	// Generate listener code based on interface event
	for event in interface.events {
		// Start proc definition
		fmt.fprintf(out, "\t%s: proc \"c\" (\n", event.name)

		// Add default arg of user data and interface pointer
		fmt.fprintf(out, "\t\tdata: rawptr,\n")
		fmt.fprintf(out, "\t\t%s: ^%s,\n", interface.name, interface.name)

		// Add spec args
		for arg in event.args {
			if arg.type == "object" && arg.interface != "" {
				fmt.fprintf(out, "\t\t%s: ^%s,\n", arg.name, arg.interface)
			} else {
				translated_type, ok := type_map[arg.type]
				if !ok {
					panic(
						fmt.tprintf(
							"Unsuported type: interface '%s', event '%s', arg_name %s, type '%s'",
							interface.name,
							event.name,
							arg.name,
							arg.type,
						),
					)
				}
				fmt.fprintf(out, "\t\t%s: %s,\n", arg.name, translated_type)
			}
		}
		fmt.fprintf(out, "\t),\n")
	}
	// Close proc declaration
	fmt.fprintf(out, "}}\n\n")

	// Generate *_add_listener proc for each interface
	add_listener_template := `%s_add_listener :: proc(
    %s: ^%s,
    listener: ^%s_listener,
    data: rawptr,
) -> c.int {{

    return proxy_add_listener(cast(^wl_proxy)%s, cast(^Implementation)listener, data)
}};

`


	fmt.fprintf(
		out,
		add_listener_template,
		interface.name,
		interface.name,
		interface.name,
		interface.name,
		interface.name,
	)
}

emit_request_stubs :: proc(out: ^os.File, interface: Interface) {
	// Generate requests code on interface requests
	// This is mostly a verbatim port of the original scanner.c code
	for request in interface.requests {
		if request.num_new_ids > 1 {
			fmt.println("Not generating stub for {request.name}. new_ids > 1")
			continue
		}
		ret: ^Arg = nil
		ret_string: string = ""

		// Find return argument
		for &arg in request.args {
			if arg.type == "new_id" {
				ret = &arg
				break
			}
		}

		// Calculate return type string
		if ret == nil {
			ret_string = ""
		} else if ret != nil && ret.interface == "" {
			ret_string = "rawptr"
		} else {
			ret_string = fmt.tprintf("^%s", ret.interface)
		}

		// Emit proc header start with default first argument
		fmt.fprintf(
			out,
			"%s_%s :: proc \"c\" (_%s: ^%s",
			interface.name,
			request.name,
			interface.name,
			interface.name,
		)

		// Emit the other args with the not documented "interface == null" edge-case...
		for &arg in request.args {
			if arg.type == "new_id" && arg.interface == "" {
				fmt.fprintf(out, ", interface: ^wl_interface, version: c.uint32_t")
				continue
			} else if arg.type == "new_id" {
				continue
			} else if arg._enum != "" {
				// Deal with enums from other interfaces
				// Base case it the interface itself and the value from the "enum" field
				enum_name := arg._enum
				interface_name := interface.name

				// Otherwise it will come in the format <interface>.<enum>
				if strings.contains(arg._enum, ".") {
					interface_name = strings.split(arg._enum, ".")[0]
					enum_name = strings.split(arg._enum, ".")[1]
				}

				// FOR NOW IGNORE THE ABOVE SINCE TYPING THE ENUMS IS A MESS
				fmt.fprintf(
					out,
					",%s : c.uint32_t",
					arg.name,
					// fmt.tprintf("%s_%s", interface_name, enum_name),
				)
				continue
			} else {
				fmt.fprintf(out, ",%s : %s", arg.name, emit_type(arg))
			}
		}

		// Close proc header and add return type
		fmt.fprintf(out, ")")
		if ret != nil {
			fmt.fprintf(out, "-> %s ", ret_string)
		} else {
			fmt.fprintf(out, "\n")
		}

		// Proc body start
		fmt.fprintf(out, "{{\n")

		// Proc body code
		if ret != nil {
			fmt.fprintf(out, "\t%s: ^wl_proxy\n\t%s = ", ret.name, ret.name)
		}

		fmt.fprintf(
			out,
			`proxy_marshal_flags(
                cast(^wl_proxy)_%s,
		        %d`,
			interface.name,
			request.opcode,
		)

		if ret != nil {
			if ret.interface != "" {
				//         /* Normal factory case, an arg has type="new_id" and
				//          * an interface is provided */
				fmt.fprintf(out, ", &%s_interface", ret.interface)
			} else {
				//         /* an arg has type ="new_id" but interface is not
				//          * provided, such as in wl_registry.bind */
				fmt.fprintf(out, ", interface")
			}
		} else {
			//     /* No args have type="new_id" */
			fmt.fprintf(out, ", nil")
		}

		if ret != nil && ret.interface == "" {
			fmt.fprintf(out, ", version")
		} else {
			fmt.fprintf(out, ", proxy_get_version(cast(^wl_proxy)_%s)", interface.name)
		}
		fmt.fprintf(out, ", %s", request.type == "destructor" ? "WL_MARSHAL_FLAG_DESTROY" : "0")

		for arg in request.args {
			if (arg.type == "new_id") {
				if (arg.interface == "") {
					fmt.fprintf(out, ", interface.name, version")
				}
				fmt.fprintf(out, ", nil")
			} else {
				fmt.fprintf(out, ", %s", arg.name)
			}
		}

		fmt.fprintf(out, ");\n\n")


		if (ret != nil && ret.interface == "") {
			fmt.fprintf(out, "\n\treturn cast(rawptr)%s;\n", ret.name)
		} else if (ret != nil) {
			fmt.fprintf(out, "\n\treturn cast(^%s)%s;\n", ret.interface, ret.name)
		}

		// Proc body end
		fmt.fprintf(out, "}}\n\n")
	}
}

emit_args_string :: proc(args: [dynamic]Arg) -> string {
	res: string = ""

	for arg in args {
		c: string = ""
		// Just check if it is indeed a nullable type
		if (arg.type == "object" || arg.type == "string") && arg.nullable {
			res = strings.concatenate({res, "?"})
		}

		switch (arg.type) {
		case "int":
			c = "i"
		case "new_id":
			c = arg.interface == "" ? "sun" : "n"
		case "uint":
			c = "u"
		case "fixed":
			c = "f"
		case "string":
			c = "s"
		case "object":
			c = "o"
		case "array":
			c = "a"
		case "fd":
			c = "h"
		}
		res = strings.concatenate({res, c})
	}
	return res
}

emit_requests_message :: proc(out: ^os.File, request: Request) {
	ret: ^Arg = nil

	type_arr: [dynamic]string = {}

	// Generate type interfaces
	for arg in request.args {
		// This complies with the case that wl_registry.bind() has a new_id but no specific interface and it "serializes as "sun"
		// Dunno why. Since we don't have forward declaration (wayland_types) we need to produce 3 nil values to pad this.
		// This is used in effect only to print the closures used when running with WAYLAND_DEBUG=1
		if arg.type == "new_id" && arg.interface == "" {
			append(&type_arr, fmt.tprintf("nil,nil,nil"))
			continue
		}
		if arg.interface != "" {
			append(&type_arr, fmt.tprintf("&%s_interface", arg.interface))
		} else {
			append(&type_arr, fmt.tprintf("nil"))
		}
	}


	fmt.fprintf(out, "\t{{ \"%s\", \"", request.name)
	fmt.fprintf(out, "%s", emit_args_string(request.args))
	fmt.fprintf(out, "\", raw_data([]^wl_interface{{%s}}) }},\n", strings.join(type_arr[:], ", "))
}

emit_events_message :: proc(out: ^os.File, event: Event) {
	ret: ^Arg = nil

	type_arr: [dynamic]string = {}

	// Generate type interfaces
	for arg in event.args {
		if arg.interface != "" {
			append(&type_arr, fmt.tprintf("&%s_interface", arg.interface))
		} else {
			append(&type_arr, fmt.tprintf("nil"))
		}
	}

	fmt.fprintf(out, "\t{{ \"%s\", \"", event.name)
	fmt.fprintf(out, "%s", emit_args_string(event.args))
	fmt.fprintf(out, "\", raw_data([]^wl_interface{{%s}}) }},\n", strings.join(type_arr[:], ", "))
}

emit_private_code :: proc(out: ^os.File, interface: Interface) {
	// Requests struct
	fmt.fprintf(out, "%s_requests: []wl_message = []wl_message{{\n", interface.name)
	for request in interface.requests {
		emit_requests_message(out, request)
	}
	fmt.fprintf(out, "}}\n\n")

	// Events struct
	fmt.fprintf(out, "%s_events: []wl_message = []wl_message{{\n", interface.name)
	for event in interface.events {
		emit_events_message(out, event)
	}
	fmt.fprintf(out, "}}\n\n")

	// Interface struct and @(init) function
	// We need init function in order to avoid cyclic initialization
	// since the original scanner relied on a list of interfaces and pointer aritmetic
	// which we should not use in odin
	fmt.fprintf(out, "%s_interface: wl_interface = {{}}\n", interface.name)
	fmt.fprintf(out, "@(init)\n")
	fmt.fprintf(out, "init_%s_interface :: proc \"contextless\" () {{\n", interface.name)
	fmt.fprintf(out, "\t%s_interface = {{\n", interface.name)
	fmt.fprintf(out, "\t\t\"%s\",\n", interface.name)
	fmt.fprintf(out, "\t\t%s,\n", interface.version)
	fmt.fprintf(out, "\t\t%d,\n", len(interface.requests))
	if len(interface.requests) > 0 {
		fmt.fprintf(out, "\t\t&%s_requests[0],\n", interface.name)
		// fmt.fprintf(out, "\t\t%s_requests,\n", interface.name)
	} else {
		fmt.fprintf(out, "\t\tnil,\n")
	}
	fmt.fprintf(out, "\t\t%d,\n", len(interface.events))
	if len(interface.events) > 0 {
		fmt.fprintf(out, "\t\t&%s_events[0],\n", interface.name)
		// fmt.fprintf(out, "\t\t%s_events,\n", interface.name)
	} else {
		fmt.fprintf(out, "\t\tnil,\n")
	}
	fmt.fprintf(out, "\t}}\n")
	fmt.fprintf(out, "}}\n\n")
}

scanner_config :: struct {
	input_path:  string,
	output_path: string,
}

// Really dumb argument parser
// Return scanner configuration
parse_args :: proc() -> scanner_config {
	cfg: scanner_config
	input_path := ""
	output_path := ""

	for arg, idx in os.args[1:] {
		switch arg {
		case "-i":
			cfg.input_path = os.args[idx + 2]
		case "-o":
			cfg.output_path = os.args[idx + 2]
		}
	}
	return cfg
}

USAGE :: `
Usage:
-i <input path>
-o <output path>

Missing input path or outputh path
`


// Prolly should use a string builder
main :: proc() {
	cfg := parse_args()
	if cfg.input_path == "" || cfg.output_path == "" {
		fmt.println(USAGE)
		os.exit(1)
	}
	fmt.println(cfg)

	out, _ := os.open(cfg.output_path, { .Read, .Write, .Create, .Trunc}, { .Read_User, .Write_User, })

	interfaces: [dynamic]Interface

	fmt.fprintln(out, "package wayland")
	fmt.fprintln(out, "import \"core:c\"")
	fmt.fprintln(out, "import \"base:runtime\"")
	fmt.fprintln(out, "import \"core:container/queue\"\n")

	doc, err := xml.load_from_file(cfg.input_path)
	if err != nil {
		fmt.println(err)
	}

	// Parse
	for el in doc.elements {
		if (el.ident == "interface") {
			// for attr in el.attribs {
			// 	if attr.key == "name" {
			// 		if attr.val == "wl_display" do continue // DO NOT PROCESS wl_display
			// 		append(&interfaces, process_interface(doc, el))
			// 	}
			// }
			append(&interfaces, process_interface(doc, el))
		}
	}

	// Emit code
	for i in interfaces {
		emit_interface_code(out, i)
	}
	emit_events_union(out)

	// Close file
	os.close(out)
}
