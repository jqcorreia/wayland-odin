package main

import "../render"
import "../utils"
import wl "../wayland"
import "core:c"
import "core:c/libc"
import "core:fmt"

import "core:sys/posix"

import "base:runtime"
import gl "vendor:OpenGL"
import "vendor:egl"

foreign import lib "lib.o"

foreign lib {
	allocate_shm_file :: proc(_: libc.size_t) -> c.int ---
}

state :: struct {
	compositor: ^wl.wl_compositor,
	xdg_base:   ^wl.xdg_wm_base,
	shm:        ^wl.wl_shm,
	surface:    ^wl.wl_surface,
}

pixel :: struct {
	b: u8,
	g: u8,
	r: u8,
	a: u8,
}


global :: proc "c" (
	data: rawptr,
	registry: ^wl.wl_registry,
	name: c.uint32_t,
	interface: cstring,
	version: c.uint32_t,
) {
	if interface == wl.wl_compositor_interface.name {
		state: ^state = cast(^state)data
		state.compositor = cast(^wl.wl_compositor)(wl.wl_registry_bind(
				registry,
				name,
				&wl.wl_compositor_interface,
				version,
			))
	}

	if interface == wl.wl_shm_interface.name {
		state: ^state = cast(^state)data
		state.shm = cast(^wl.wl_shm)(wl.wl_registry_bind(
				registry,
				name,
				&wl.wl_shm_interface,
				version,
			))
	}

	if interface == wl.xdg_wm_base_interface.name {
		state: ^state = cast(^state)data
		state.xdg_base = cast(^wl.xdg_wm_base)(wl.wl_registry_bind(
				registry,
				name,
				&wl.xdg_wm_base_interface,
				version,
			))
	}
}

global_remove :: proc "c" (data: rawptr, registry: ^wl.wl_registry, name: c.uint32_t) {
}

registry_listener := wl.wl_registry_listener {
	global        = global,
	global_remove = global_remove,
}

surface_listener := wl.xdg_surface_listener {
	configure = surface_configure,
}

buffer_listener := wl.wl_buffer_listener {
	release = proc "c" (data: rawptr, wl_buffer: ^wl.wl_buffer) {
		wl.wl_buffer_destroy(wl_buffer)
	},
}

done :: proc "c" (data: rawptr, wl_callback: ^wl.wl_callback, callback_data: c.uint32_t) {
	context = runtime.default_context()
	state := cast(^state)data

	wl_callback_destroy(wl_callback)

	wl_callback := wl.wl_surface_frame(state.surface)
	wl.wl_callback_add_listener(wl_callback, &frame_callback_listener, state)

	buffer := get_buffer(state, 800, 600)
	wl.wl_surface_attach(state.surface, buffer, 0, 0)
	wl.wl_surface_damage(state.surface, 0, 0, c.INT32_MAX, c.INT32_MAX)
	wl.wl_surface_commit(state.surface)
}

frame_callback_listener := wl.wl_callback_listener {
	done = done,
}

surface_configure :: proc "c" (data: rawptr, surface: ^wl.xdg_surface, serial: c.uint32_t) {
	//context = runtime.default_context()
	state := cast(^state)data
	//
	//fmt.println("surface configure")
	//wl.xdg_surface_ack_configure(surface, serial)
	//
	//buffer := get_buffer(state, 800, 600)
	//wl.wl_surface_attach(state.surface, buffer, 0, 0)
	wl.wl_surface_damage(state.surface, 0, 0, c.INT32_MAX, c.INT32_MAX)
	wl.wl_surface_commit(state.surface)
}

// This should be generated once this whole thing works
wl_callback_destroy :: proc "c" (wl_callback: ^wl.wl_callback) {
	wl.proxy_destroy(cast(^wl.wl_proxy)wl_callback)
}

get_buffer :: proc(state: ^state, width: c.int32_t, height: c.int32_t) -> ^wl.wl_buffer {
	stride := width * 4
	shm_pool_size := height * stride

	fd := cast(posix.FD)utils.allocate_shm_file(cast(uint)shm_pool_size)
	if fd < 0 {
		fmt.println("Errror")
		return nil
	}
	pool := wl.wl_shm_create_pool(state.shm, cast(c.int32_t)fd, shm_pool_size)

	//uint8_t* pool_data = mmap(NULL, shm_pool_size, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
	//
	pool_data := posix.mmap(
		nil,
		cast(uint)shm_pool_size,
		{posix.Prot_Flag_Bits.READ, posix.Prot_Flag_Bits.WRITE},
		{posix.Map_Flag_Bits.SHARED},
		fd,
		0,
	)
	buffer := wl.wl_shm_pool_create_buffer(pool, 0, width, height, stride, 0)

	wl.wl_shm_pool_destroy(pool)
	posix.close(fd)

	// This munmap yields segfault, but this is in default documentation
	// posix.munmap(pool_data, cast(uint)shm_pool_size)
	pixels := cast([^]pixel)pool_data
	for i in 1 ..= shm_pool_size / 4 {
		pixels[i].a = 255
		pixels[i].r = 0x9a
		pixels[i].g = 0xce
		pixels[i].b = 0xeb
	}

	wl.wl_buffer_add_listener(buffer, &buffer_listener, nil)

	return buffer
}

main :: proc() {
	state: state = {}

	display := wl.display_connect(nil)
	registry := wl.wl_display_get_registry(display)

	wl.wl_registry_add_listener(registry, &registry_listener, &state)
	wl.display_roundtrip(display)

	//Only after first round trip state.compositor is set
	state.surface = wl.wl_compositor_create_surface(state.compositor)

	xdg_surface := wl.xdg_wm_base_get_xdg_surface(state.xdg_base, state.surface)
	toplevel := wl.xdg_surface_get_toplevel(xdg_surface)
	wl.xdg_toplevel_set_title(toplevel, "Odin Wayland")

	wl.wl_surface_commit(state.surface) // This first commit is needed by egl or egl.SwapBuffers() will panic
	wl.xdg_surface_add_listener(xdg_surface, &surface_listener, &state)


	// EGL initialization stuff
	rctx := render.init_egl(display)
	egl_window := wl.egl_window_create(state.surface, 800, 600)
	egl_surface := egl.CreateWindowSurface(
		rctx.display,
		rctx.config,
		egl.NativeWindowType(egl_window),
		nil,
	)

	if egl_surface == egl.NO_SURFACE {
		fmt.println("Error creating window surface")
		return

	}
	if (!egl.MakeCurrent(rctx.display, egl_surface, egl_surface, rctx.ctx)) {
		fmt.println("Error making current!")
		return
	}
	gl.load_up_to(int(1), 5, egl.gl_set_proc_address)


	// wl_callback := wl.wl_surface_frame(state.surface)
	// wl.wl_callback_add_listener(wl_callback, &frame_callback_listener, &state)
	// wl.wl_surface_commit(state.surface)

	for {
		gl.ClearColor(147.0 / 255.0, 204.0 / 255., 234. / 255., 1.0)
		gl.Clear(gl.COLOR_BUFFER_BIT)
		gl.Flush()
		egl.SwapBuffers(rctx.display, egl_surface)

		wl.display_dispatch(display)
	}
}
