package wayland

import "core:c"
import "core:container/queue"
import "core:fmt"

Wayland :: struct {
	display: Wl_Display,
	// registry: ^wl_registry,
	queue:   queue.Queue(Wl_Event),
}

Wl_Event :: union {
	Wl_Registry_Global,
	Wl_Registry_Global_Remove,
}

Wl_Base_Interface :: struct {
	proxy:     ^wl_proxy,
	interface: ^wl_interface,
}

Wl_Display :: struct {
	proxy:        ^wl_proxy,
	interface:    ^wl_interface,
	get_registry: proc "c" (_wl_display: ^Wl_Display) -> Wl_Registry,
}

Wl_Registry :: struct {
	proxy:     ^wl_proxy,
	interface: ^wl_interface,
}

Wl_Registry_Global :: struct {
	data:      rawptr,
	registry:  ^wl_registry,
	name:      c.uint32_t,
	interface: cstring,
	version:   c.uint32_t,
}

Wl_Registry_Global_Remove :: struct {}
