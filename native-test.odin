package main

import "base:runtime"
import "core:c"
import "core:container/queue"
import "core:fmt"
import wl "wayland"


main :: proc() {
	wl.init()
	wl.bind_interfaces({"wl_compositor"})
}
