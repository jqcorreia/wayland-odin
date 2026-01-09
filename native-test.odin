package main

import "base:runtime"
import "core:c"
import "core:container/queue"
import "core:fmt"
import wl "wayland"

Wayland :: struct {
	display: Wl_Display,
	// registry: ^wl.wl_registry,
	queue:   queue.Queue(Wl_Event),
}

Wl_Event :: union {
	Wl_Registry_Global,
	Wl_Registry_Global_Remove,
}

Wl_Base_Interface :: struct {
	proxy:     ^wl.wl_proxy,
	interface: ^wl.wl_interface,
}


Wl_Display :: struct {
	proxy:        ^wl.wl_proxy,
	interface:    ^wl.wl_interface,
	get_registry: proc "c" (_wl_display: ^Wl_Display) -> Wl_Registry,
}

_way: Wayland

wl_display_get_registry :: proc "c" (_wl_display: ^Wl_Display) -> Wl_Registry {
	display: ^wl.wl_proxy = _wl_display.proxy
	registry: ^wl.wl_proxy
	registry = wl.proxy_marshal_flags(
		display,
		1,
		&wl.wl_registry_interface,
		wl.proxy_get_version(display),
		0,
		nil,
	)
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
	wl.proxy_add_listener(registry, cast(^wl.Implementation)&registry_listener, &_way)

	return Wl_Registry{proxy = registry, interface = &wl.wl_registry_interface}
}

// create_wayland :: proc() -> Wayland {
// 	d := wl.display_connect(nil)
// 	display := Wl_Display {
// 		proxy        = cast(^wl.wl_proxy)d,
// 		interface    = cast(^wl.wl_interface)&wl.wl_display_interface,
// 		get_registry = wl_display_get_registry,
// 	}

// 	registry := display->get_registry()

// 	return Wayland{display = display, registry = registry}
// }

bind_interfaces :: proc(interface_names: []string) {
	wl.display_roundtrip(cast(^wl.wl_display)_way.display.proxy)
	for event in poll(&_way) {
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

init :: proc() {
	d := wl.display_connect(nil)
	display := Wl_Display {
		proxy        = cast(^wl.wl_proxy)d,
		interface    = cast(^wl.wl_interface)&wl.wl_display_interface,
		get_registry = wl_display_get_registry,
	}

	registry := display->get_registry()
	_way.display = display
}

main :: proc() {
	init()
	bind_interfaces({"wl_compositor"})
}
