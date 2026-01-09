package main

import "base:runtime"
import "core:c"
import "core:container/queue"
import "core:fmt"
import wl "wayland"

Wayland :: struct {
	display:  ^wl.wl_display,
	registry: ^wl.wl_registry,
	queue:    queue.Queue(Wl_Event),
}

Wl_Event :: union {
	Wl_Registry_Global,
	Wl_Registry_Global_Remove,
}

Wl_Registry :: struct {
	handle:   ^wl.wl_registry,
	listener: ^wl.wl_registry_listener,
}

Wl_Registry_Global :: struct {
	data:      rawptr,
	registry:  ^wl.wl_registry,
	name:      c.uint32_t,
	interface: cstring,
	version:   c.uint32_t,
}

Wl_Registry_Global_Remove :: struct {}

create_wayland :: proc() -> Wayland {
	display := wl.display_connect(nil)
	registry := wl.wl_display_get_registry(display)

	return Wayland{display = display, registry = registry}
}

bind_interfaces :: proc(w: ^Wayland, interface_names: []string) {
	registry_listener := wl.wl_registry_listener {
		global = proc "c" (
			data: rawptr,
			registry: ^wl.wl_registry,
			name: c.uint32_t,
			interface: cstring,
			version: c.uint32_t,
		) {
			way := cast(^Wayland)data
			context = runtime.default_context()
			queue.enqueue(&way.queue, Wl_Registry_Global{data, registry, name, interface, version})
		},
		global_remove = nil,
	}
	wl.wl_registry_add_listener(w.registry, &registry_listener, w)
	wl.display_roundtrip(w.display)
	for event in poll(w) {
		#partial switch e in event {
		case Wl_Registry_Global:
			for iname in interface_names {
				if string(e.interface) == iname {
					fmt.println(e.interface)
				}
			}
		}
	}
}

poll :: proc(w: ^Wayland) -> []Wl_Event {
	result: [dynamic]Wl_Event

	for {
		event, ok := queue.pop_front_safe(&w.queue)
		if !ok {
			break
		}
		append(&result, event)
	}

	return result[:]
}

main :: proc() {
	way := create_wayland()
	bind_interfaces(&way, {"wl_compositor"})
}
