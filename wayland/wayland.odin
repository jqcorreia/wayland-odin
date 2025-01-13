package wayland

import "core:c"

wl_display_listener :: struct {
	error: proc(
		data: rawptr,
		wl_display: ^wl_display,
		object_id: rawptr,
		code: c.uint32_t,
		message: cstring,
	),
	delete_id: proc(
		data: rawptr,
		wl_display: ^wl_display,
		id: c.uint32_t,
	),
}

wl_display_add_listener :: proc(
    wl_display: ^wl_display,
    listener: ^wl_display_listener,
    data: rawptr,
) -> c.int {

    return proxy_add_listener(cast(^wl_proxy)wl_display, auto_cast listener, data)
};

wl_display_sync :: proc(_wl_display: ^wl_display)-> ^wl_callback {
	callback: ^wl_proxy
	callback = proxy_marshal_flags(
                cast(^wl_proxy)_wl_display,
		        0, &wl_callback_interface, proxy_get_version(cast(^wl_proxy)_wl_display), 0, nil);


	return cast(^wl_callback)callback;
}

wl_display_get_registry :: proc(_wl_display: ^wl_display)-> ^wl_registry {
	registry: ^wl_proxy
	registry = proxy_marshal_flags(
                cast(^wl_proxy)_wl_display,
		        1, &wl_registry_interface, proxy_get_version(cast(^wl_proxy)_wl_display), 0, nil);


	return cast(^wl_registry)registry;
}

wl_display_requests: []wl_message = []wl_message{
	{ "sync", "n", raw_data([]^wl_interface{&wl_callback_interface}) },
	{ "get_registry", "n", raw_data([]^wl_interface{&wl_registry_interface}) },
}

wl_display_events: []wl_message = []wl_message{
	{ "error", "ous", nil },
	{ "delete_id", "u", nil },
}

wl_display_interface: wl_interface = {}
@(init)
init_wl_display_interface :: proc() {
	wl_display_interface = {
		"wl_display",
		1,
		2,
		&wl_display_requests[0],
		2,
		&wl_display_events[0],
	}
}

wl_registry :: struct {}
wl_registry_listener :: struct {
	global: proc(
		data: rawptr,
		wl_registry: ^wl_registry,
		name: c.uint32_t,
		interface: cstring,
		version: c.uint32_t,
	),
	global_remove: proc(
		data: rawptr,
		wl_registry: ^wl_registry,
		name: c.uint32_t,
	),
}

wl_registry_add_listener :: proc(
    wl_registry: ^wl_registry,
    listener: ^wl_registry_listener,
    data: rawptr,
) -> c.int {

    return proxy_add_listener(cast(^wl_proxy)wl_registry, auto_cast listener, data)
};

wl_registry_bind :: proc(_wl_registry: ^wl_registry,name : c.uint32_t, interface: ^wl_interface, version: c.uint32_t)-> rawptr {
	id: ^wl_proxy
	id = proxy_marshal_flags(
                cast(^wl_proxy)_wl_registry,
		        0, interface, version, 0, name, interface.name, version, nil);


	return cast(rawptr)id;
}

wl_registry_requests: []wl_message = []wl_message{
	{ "bind", "usun", raw_data([]^wl_interface{nil, nil}) },
}

wl_registry_events: []wl_message = []wl_message{
	{ "global", "usu", nil },
	{ "global_remove", "u", nil },
}

wl_registry_interface: wl_interface = {}
@(init)
init_wl_registry_interface :: proc() {
	wl_registry_interface = {
		"wl_registry",
		1,
		1,
		&wl_registry_requests[0],
		2,
		&wl_registry_events[0],
	}
}

wl_callback :: struct {}
wl_callback_listener :: struct {
	done: proc(
		data: rawptr,
		wl_callback: ^wl_callback,
		callback_data: c.uint32_t,
	),
}

wl_callback_add_listener :: proc(
    wl_callback: ^wl_callback,
    listener: ^wl_callback_listener,
    data: rawptr,
) -> c.int {

    return proxy_add_listener(cast(^wl_proxy)wl_callback, auto_cast listener, data)
};

wl_callback_requests: []wl_message = []wl_message{
}

wl_callback_events: []wl_message = []wl_message{
	{ "done", "u", nil },
}

wl_callback_interface: wl_interface = {}
@(init)
init_wl_callback_interface :: proc() {
	wl_callback_interface = {
		"wl_callback",
		1,
		0,
		nil,
		1,
		&wl_callback_events[0],
	}
}

wl_compositor :: struct {}
wl_compositor_listener :: struct {
}

wl_compositor_add_listener :: proc(
    wl_compositor: ^wl_compositor,
    listener: ^wl_compositor_listener,
    data: rawptr,
) -> c.int {

    return proxy_add_listener(cast(^wl_proxy)wl_compositor, auto_cast listener, data)
};

wl_compositor_create_surface :: proc(_wl_compositor: ^wl_compositor)-> ^wl_surface {
	id: ^wl_proxy
	id = proxy_marshal_flags(
                cast(^wl_proxy)_wl_compositor,
		        0, &wl_surface_interface, proxy_get_version(cast(^wl_proxy)_wl_compositor), 0, nil);


	return cast(^wl_surface)id;
}

wl_compositor_create_region :: proc(_wl_compositor: ^wl_compositor)-> ^wl_region {
	id: ^wl_proxy
	id = proxy_marshal_flags(
                cast(^wl_proxy)_wl_compositor,
		        1, &wl_region_interface, proxy_get_version(cast(^wl_proxy)_wl_compositor), 0, nil);


	return cast(^wl_region)id;
}

wl_compositor_requests: []wl_message = []wl_message{
	{ "create_surface", "n", raw_data([]^wl_interface{&wl_surface_interface}) },
	{ "create_region", "n", raw_data([]^wl_interface{&wl_region_interface}) },
}

wl_compositor_events: []wl_message = []wl_message{
}

wl_compositor_interface: wl_interface = {}
@(init)
init_wl_compositor_interface :: proc() {
	wl_compositor_interface = {
		"wl_compositor",
		6,
		2,
		&wl_compositor_requests[0],
		0,
		nil,
	}
}

wl_shm_pool :: struct {}
wl_shm_pool_listener :: struct {
}

wl_shm_pool_add_listener :: proc(
    wl_shm_pool: ^wl_shm_pool,
    listener: ^wl_shm_pool_listener,
    data: rawptr,
) -> c.int {

    return proxy_add_listener(cast(^wl_proxy)wl_shm_pool, auto_cast listener, data)
};

wl_shm_pool_create_buffer :: proc(_wl_shm_pool: ^wl_shm_pool,offset : c.int32_t,width : c.int32_t,height : c.int32_t,stride : c.int32_t,format : c.uint32_t)-> ^wl_buffer {
	id: ^wl_proxy
	id = proxy_marshal_flags(
                cast(^wl_proxy)_wl_shm_pool,
		        0, &wl_buffer_interface, proxy_get_version(cast(^wl_proxy)_wl_shm_pool), 0, nil, offset, width, height, stride, format);


	return cast(^wl_buffer)id;
}

wl_shm_pool_destroy :: proc(_wl_shm_pool: ^wl_shm_pool)
{
proxy_marshal_flags(
                cast(^wl_proxy)_wl_shm_pool,
		        1, nil, proxy_get_version(cast(^wl_proxy)_wl_shm_pool), WL_MARSHAL_FLAG_DESTROY);

}

wl_shm_pool_resize :: proc(_wl_shm_pool: ^wl_shm_pool,size : c.int32_t)
{
proxy_marshal_flags(
                cast(^wl_proxy)_wl_shm_pool,
		        2, nil, proxy_get_version(cast(^wl_proxy)_wl_shm_pool), 0, size);

}

wl_shm_pool_requests: []wl_message = []wl_message{
	{ "create_buffer", "niiiiu", raw_data([]^wl_interface{&wl_buffer_interface, nil, nil, nil, nil, nil}) },
	{ "destroy", "", raw_data([]^wl_interface{}) },
	{ "resize", "i", raw_data([]^wl_interface{nil}) },
}

wl_shm_pool_events: []wl_message = []wl_message{
}

wl_shm_pool_interface: wl_interface = {}
@(init)
init_wl_shm_pool_interface :: proc() {
	wl_shm_pool_interface = {
		"wl_shm_pool",
		1,
		3,
		&wl_shm_pool_requests[0],
		0,
		nil,
	}
}

wl_shm :: struct {}
wl_shm_listener :: struct {
	format: proc(
		data: rawptr,
		wl_shm: ^wl_shm,
		format: c.uint32_t,
	),
}

wl_shm_add_listener :: proc(
    wl_shm: ^wl_shm,
    listener: ^wl_shm_listener,
    data: rawptr,
) -> c.int {

    return proxy_add_listener(cast(^wl_proxy)wl_shm, auto_cast listener, data)
};

wl_shm_create_pool :: proc(_wl_shm: ^wl_shm,fd : c.int32_t,size : c.int32_t)-> ^wl_shm_pool {
	id: ^wl_proxy
	id = proxy_marshal_flags(
                cast(^wl_proxy)_wl_shm,
		        0, &wl_shm_pool_interface, proxy_get_version(cast(^wl_proxy)_wl_shm), 0, nil, fd, size);


	return cast(^wl_shm_pool)id;
}

wl_shm_requests: []wl_message = []wl_message{
	{ "create_pool", "nhi", raw_data([]^wl_interface{&wl_shm_pool_interface, nil, nil}) },
}

wl_shm_events: []wl_message = []wl_message{
	{ "format", "u", nil },
}

wl_shm_interface: wl_interface = {}
@(init)
init_wl_shm_interface :: proc() {
	wl_shm_interface = {
		"wl_shm",
		1,
		1,
		&wl_shm_requests[0],
		1,
		&wl_shm_events[0],
	}
}

wl_buffer :: struct {}
wl_buffer_listener :: struct {
	release: proc(
		data: rawptr,
		wl_buffer: ^wl_buffer,
	),
}

wl_buffer_add_listener :: proc(
    wl_buffer: ^wl_buffer,
    listener: ^wl_buffer_listener,
    data: rawptr,
) -> c.int {

    return proxy_add_listener(cast(^wl_proxy)wl_buffer, auto_cast listener, data)
};

wl_buffer_destroy :: proc(_wl_buffer: ^wl_buffer)
{
proxy_marshal_flags(
                cast(^wl_proxy)_wl_buffer,
		        0, nil, proxy_get_version(cast(^wl_proxy)_wl_buffer), WL_MARSHAL_FLAG_DESTROY);

}

wl_buffer_requests: []wl_message = []wl_message{
	{ "destroy", "", raw_data([]^wl_interface{}) },
}

wl_buffer_events: []wl_message = []wl_message{
	{ "release", "", nil },
}

wl_buffer_interface: wl_interface = {}
@(init)
init_wl_buffer_interface :: proc() {
	wl_buffer_interface = {
		"wl_buffer",
		1,
		1,
		&wl_buffer_requests[0],
		1,
		&wl_buffer_events[0],
	}
}

wl_data_offer :: struct {}
wl_data_offer_listener :: struct {
	offer: proc(
		data: rawptr,
		wl_data_offer: ^wl_data_offer,
		mime_type: cstring,
	),
	source_actions: proc(
		data: rawptr,
		wl_data_offer: ^wl_data_offer,
		source_actions: c.uint32_t,
	),
	action: proc(
		data: rawptr,
		wl_data_offer: ^wl_data_offer,
		dnd_action: c.uint32_t,
	),
}

wl_data_offer_add_listener :: proc(
    wl_data_offer: ^wl_data_offer,
    listener: ^wl_data_offer_listener,
    data: rawptr,
) -> c.int {

    return proxy_add_listener(cast(^wl_proxy)wl_data_offer, auto_cast listener, data)
};

wl_data_offer_accept :: proc(_wl_data_offer: ^wl_data_offer,serial : c.uint32_t,mime_type : cstring)
{
proxy_marshal_flags(
                cast(^wl_proxy)_wl_data_offer,
		        0, nil, proxy_get_version(cast(^wl_proxy)_wl_data_offer), 0, serial, mime_type);

}

wl_data_offer_receive :: proc(_wl_data_offer: ^wl_data_offer,mime_type : cstring,fd : c.int32_t)
{
proxy_marshal_flags(
                cast(^wl_proxy)_wl_data_offer,
		        1, nil, proxy_get_version(cast(^wl_proxy)_wl_data_offer), 0, mime_type, fd);

}

wl_data_offer_destroy :: proc(_wl_data_offer: ^wl_data_offer)
{
proxy_marshal_flags(
                cast(^wl_proxy)_wl_data_offer,
		        2, nil, proxy_get_version(cast(^wl_proxy)_wl_data_offer), WL_MARSHAL_FLAG_DESTROY);

}

wl_data_offer_finish :: proc(_wl_data_offer: ^wl_data_offer)
{
proxy_marshal_flags(
                cast(^wl_proxy)_wl_data_offer,
		        3, nil, proxy_get_version(cast(^wl_proxy)_wl_data_offer), 0);

}

wl_data_offer_set_actions :: proc(_wl_data_offer: ^wl_data_offer,dnd_actions : c.uint32_t,preferred_action : c.uint32_t)
{
proxy_marshal_flags(
                cast(^wl_proxy)_wl_data_offer,
		        4, nil, proxy_get_version(cast(^wl_proxy)_wl_data_offer), 0, dnd_actions, preferred_action);

}

wl_data_offer_requests: []wl_message = []wl_message{
	{ "accept", "u?s", raw_data([]^wl_interface{nil, nil}) },
	{ "receive", "sh", raw_data([]^wl_interface{nil, nil}) },
	{ "destroy", "", raw_data([]^wl_interface{}) },
	{ "finish", "", raw_data([]^wl_interface{}) },
	{ "set_actions", "uu", raw_data([]^wl_interface{nil, nil}) },
}

wl_data_offer_events: []wl_message = []wl_message{
	{ "offer", "s", nil },
	{ "source_actions", "u", nil },
	{ "action", "u", nil },
}

wl_data_offer_interface: wl_interface = {}
@(init)
init_wl_data_offer_interface :: proc() {
	wl_data_offer_interface = {
		"wl_data_offer",
		3,
		5,
		&wl_data_offer_requests[0],
		3,
		&wl_data_offer_events[0],
	}
}

wl_data_source :: struct {}
wl_data_source_listener :: struct {
	target: proc(
		data: rawptr,
		wl_data_source: ^wl_data_source,
		mime_type: cstring,
	),
	send: proc(
		data: rawptr,
		wl_data_source: ^wl_data_source,
		mime_type: cstring,
		fd: c.int32_t,
	),
	cancelled: proc(
		data: rawptr,
		wl_data_source: ^wl_data_source,
	),
	dnd_drop_performed: proc(
		data: rawptr,
		wl_data_source: ^wl_data_source,
	),
	dnd_finished: proc(
		data: rawptr,
		wl_data_source: ^wl_data_source,
	),
	action: proc(
		data: rawptr,
		wl_data_source: ^wl_data_source,
		dnd_action: c.uint32_t,
	),
}

wl_data_source_add_listener :: proc(
    wl_data_source: ^wl_data_source,
    listener: ^wl_data_source_listener,
    data: rawptr,
) -> c.int {

    return proxy_add_listener(cast(^wl_proxy)wl_data_source, auto_cast listener, data)
};

wl_data_source_offer :: proc(_wl_data_source: ^wl_data_source,mime_type : cstring)
{
proxy_marshal_flags(
                cast(^wl_proxy)_wl_data_source,
		        0, nil, proxy_get_version(cast(^wl_proxy)_wl_data_source), 0, mime_type);

}

wl_data_source_destroy :: proc(_wl_data_source: ^wl_data_source)
{
proxy_marshal_flags(
                cast(^wl_proxy)_wl_data_source,
		        1, nil, proxy_get_version(cast(^wl_proxy)_wl_data_source), WL_MARSHAL_FLAG_DESTROY);

}

wl_data_source_set_actions :: proc(_wl_data_source: ^wl_data_source,dnd_actions : c.uint32_t)
{
proxy_marshal_flags(
                cast(^wl_proxy)_wl_data_source,
		        2, nil, proxy_get_version(cast(^wl_proxy)_wl_data_source), 0, dnd_actions);

}

wl_data_source_requests: []wl_message = []wl_message{
	{ "offer", "s", raw_data([]^wl_interface{nil}) },
	{ "destroy", "", raw_data([]^wl_interface{}) },
	{ "set_actions", "u", raw_data([]^wl_interface{nil}) },
}

wl_data_source_events: []wl_message = []wl_message{
	{ "target", "?s", nil },
	{ "send", "sh", nil },
	{ "cancelled", "", nil },
	{ "dnd_drop_performed", "", nil },
	{ "dnd_finished", "", nil },
	{ "action", "u", nil },
}

wl_data_source_interface: wl_interface = {}
@(init)
init_wl_data_source_interface :: proc() {
	wl_data_source_interface = {
		"wl_data_source",
		3,
		3,
		&wl_data_source_requests[0],
		6,
		&wl_data_source_events[0],
	}
}

wl_data_device :: struct {}
wl_data_device_listener :: struct {
	data_offer: proc(
		data: rawptr,
		wl_data_device: ^wl_data_device,
		id: c.uint32_t,
	),
	enter: proc(
		data: rawptr,
		wl_data_device: ^wl_data_device,
		serial: c.uint32_t,
		surface: ^wl_surface,
		x: wl_fixed_t,
		y: wl_fixed_t,
		id: ^wl_data_offer,
	),
	leave: proc(
		data: rawptr,
		wl_data_device: ^wl_data_device,
	),
	motion: proc(
		data: rawptr,
		wl_data_device: ^wl_data_device,
		time: c.uint32_t,
		x: wl_fixed_t,
		y: wl_fixed_t,
	),
	drop: proc(
		data: rawptr,
		wl_data_device: ^wl_data_device,
	),
	selection: proc(
		data: rawptr,
		wl_data_device: ^wl_data_device,
		id: ^wl_data_offer,
	),
}

wl_data_device_add_listener :: proc(
    wl_data_device: ^wl_data_device,
    listener: ^wl_data_device_listener,
    data: rawptr,
) -> c.int {

    return proxy_add_listener(cast(^wl_proxy)wl_data_device, auto_cast listener, data)
};

wl_data_device_start_drag :: proc(_wl_data_device: ^wl_data_device,source : ^wl_data_source,origin : ^wl_surface,icon : ^wl_surface,serial : c.uint32_t)
{
proxy_marshal_flags(
                cast(^wl_proxy)_wl_data_device,
		        0, nil, proxy_get_version(cast(^wl_proxy)_wl_data_device), 0, source, origin, icon, serial);

}

wl_data_device_set_selection :: proc(_wl_data_device: ^wl_data_device,source : ^wl_data_source,serial : c.uint32_t)
{
proxy_marshal_flags(
                cast(^wl_proxy)_wl_data_device,
		        1, nil, proxy_get_version(cast(^wl_proxy)_wl_data_device), 0, source, serial);

}

wl_data_device_release :: proc(_wl_data_device: ^wl_data_device)
{
proxy_marshal_flags(
                cast(^wl_proxy)_wl_data_device,
		        2, nil, proxy_get_version(cast(^wl_proxy)_wl_data_device), WL_MARSHAL_FLAG_DESTROY);

}

wl_data_device_requests: []wl_message = []wl_message{
	{ "start_drag", "?oo?ou", raw_data([]^wl_interface{&wl_data_source_interface, &wl_surface_interface, &wl_surface_interface, nil}) },
	{ "set_selection", "?ou", raw_data([]^wl_interface{&wl_data_source_interface, nil}) },
	{ "release", "", raw_data([]^wl_interface{}) },
}

wl_data_device_events: []wl_message = []wl_message{
	{ "data_offer", "n", nil },
	{ "enter", "uoff?o", nil },
	{ "leave", "", nil },
	{ "motion", "uff", nil },
	{ "drop", "", nil },
	{ "selection", "?o", nil },
}

wl_data_device_interface: wl_interface = {}
@(init)
init_wl_data_device_interface :: proc() {
	wl_data_device_interface = {
		"wl_data_device",
		3,
		3,
		&wl_data_device_requests[0],
		6,
		&wl_data_device_events[0],
	}
}

wl_data_device_manager :: struct {}
wl_data_device_manager_listener :: struct {
}

wl_data_device_manager_add_listener :: proc(
    wl_data_device_manager: ^wl_data_device_manager,
    listener: ^wl_data_device_manager_listener,
    data: rawptr,
) -> c.int {

    return proxy_add_listener(cast(^wl_proxy)wl_data_device_manager, auto_cast listener, data)
};

wl_data_device_manager_create_data_source :: proc(_wl_data_device_manager: ^wl_data_device_manager)-> ^wl_data_source {
	id: ^wl_proxy
	id = proxy_marshal_flags(
                cast(^wl_proxy)_wl_data_device_manager,
		        0, &wl_data_source_interface, proxy_get_version(cast(^wl_proxy)_wl_data_device_manager), 0, nil);


	return cast(^wl_data_source)id;
}

wl_data_device_manager_get_data_device :: proc(_wl_data_device_manager: ^wl_data_device_manager,seat : ^wl_seat)-> ^wl_data_device {
	id: ^wl_proxy
	id = proxy_marshal_flags(
                cast(^wl_proxy)_wl_data_device_manager,
		        1, &wl_data_device_interface, proxy_get_version(cast(^wl_proxy)_wl_data_device_manager), 0, nil, seat);


	return cast(^wl_data_device)id;
}

wl_data_device_manager_requests: []wl_message = []wl_message{
	{ "create_data_source", "n", raw_data([]^wl_interface{&wl_data_source_interface}) },
	{ "get_data_device", "no", raw_data([]^wl_interface{&wl_data_device_interface, &wl_seat_interface}) },
}

wl_data_device_manager_events: []wl_message = []wl_message{
}

wl_data_device_manager_interface: wl_interface = {}
@(init)
init_wl_data_device_manager_interface :: proc() {
	wl_data_device_manager_interface = {
		"wl_data_device_manager",
		3,
		2,
		&wl_data_device_manager_requests[0],
		0,
		nil,
	}
}

wl_shell :: struct {}
wl_shell_listener :: struct {
}

wl_shell_add_listener :: proc(
    wl_shell: ^wl_shell,
    listener: ^wl_shell_listener,
    data: rawptr,
) -> c.int {

    return proxy_add_listener(cast(^wl_proxy)wl_shell, auto_cast listener, data)
};

wl_shell_get_shell_surface :: proc(_wl_shell: ^wl_shell,surface : ^wl_surface)-> ^wl_shell_surface {
	id: ^wl_proxy
	id = proxy_marshal_flags(
                cast(^wl_proxy)_wl_shell,
		        0, &wl_shell_surface_interface, proxy_get_version(cast(^wl_proxy)_wl_shell), 0, nil, surface);


	return cast(^wl_shell_surface)id;
}

wl_shell_requests: []wl_message = []wl_message{
	{ "get_shell_surface", "no", raw_data([]^wl_interface{&wl_shell_surface_interface, &wl_surface_interface}) },
}

wl_shell_events: []wl_message = []wl_message{
}

wl_shell_interface: wl_interface = {}
@(init)
init_wl_shell_interface :: proc() {
	wl_shell_interface = {
		"wl_shell",
		1,
		1,
		&wl_shell_requests[0],
		0,
		nil,
	}
}

wl_shell_surface :: struct {}
wl_shell_surface_listener :: struct {
	ping: proc(
		data: rawptr,
		wl_shell_surface: ^wl_shell_surface,
		serial: c.uint32_t,
	),
	configure: proc(
		data: rawptr,
		wl_shell_surface: ^wl_shell_surface,
		edges: c.uint32_t,
		width: c.int32_t,
		height: c.int32_t,
	),
	popup_done: proc(
		data: rawptr,
		wl_shell_surface: ^wl_shell_surface,
	),
}

wl_shell_surface_add_listener :: proc(
    wl_shell_surface: ^wl_shell_surface,
    listener: ^wl_shell_surface_listener,
    data: rawptr,
) -> c.int {

    return proxy_add_listener(cast(^wl_proxy)wl_shell_surface, auto_cast listener, data)
};

wl_shell_surface_pong :: proc(_wl_shell_surface: ^wl_shell_surface,serial : c.uint32_t)
{
proxy_marshal_flags(
                cast(^wl_proxy)_wl_shell_surface,
		        0, nil, proxy_get_version(cast(^wl_proxy)_wl_shell_surface), 0, serial);

}

wl_shell_surface_move :: proc(_wl_shell_surface: ^wl_shell_surface,seat : ^wl_seat,serial : c.uint32_t)
{
proxy_marshal_flags(
                cast(^wl_proxy)_wl_shell_surface,
		        1, nil, proxy_get_version(cast(^wl_proxy)_wl_shell_surface), 0, seat, serial);

}

wl_shell_surface_resize :: proc(_wl_shell_surface: ^wl_shell_surface,seat : ^wl_seat,serial : c.uint32_t,edges : c.uint32_t)
{
proxy_marshal_flags(
                cast(^wl_proxy)_wl_shell_surface,
		        2, nil, proxy_get_version(cast(^wl_proxy)_wl_shell_surface), 0, seat, serial, edges);

}

wl_shell_surface_set_toplevel :: proc(_wl_shell_surface: ^wl_shell_surface)
{
proxy_marshal_flags(
                cast(^wl_proxy)_wl_shell_surface,
		        3, nil, proxy_get_version(cast(^wl_proxy)_wl_shell_surface), 0);

}

wl_shell_surface_set_transient :: proc(_wl_shell_surface: ^wl_shell_surface,parent : ^wl_surface,x : c.int32_t,y : c.int32_t,flags : c.uint32_t)
{
proxy_marshal_flags(
                cast(^wl_proxy)_wl_shell_surface,
		        4, nil, proxy_get_version(cast(^wl_proxy)_wl_shell_surface), 0, parent, x, y, flags);

}

wl_shell_surface_set_fullscreen :: proc(_wl_shell_surface: ^wl_shell_surface,method : c.uint32_t,framerate : c.uint32_t,output : ^wl_output)
{
proxy_marshal_flags(
                cast(^wl_proxy)_wl_shell_surface,
		        5, nil, proxy_get_version(cast(^wl_proxy)_wl_shell_surface), 0, method, framerate, output);

}

wl_shell_surface_set_popup :: proc(_wl_shell_surface: ^wl_shell_surface,seat : ^wl_seat,serial : c.uint32_t,parent : ^wl_surface,x : c.int32_t,y : c.int32_t,flags : c.uint32_t)
{
proxy_marshal_flags(
                cast(^wl_proxy)_wl_shell_surface,
		        6, nil, proxy_get_version(cast(^wl_proxy)_wl_shell_surface), 0, seat, serial, parent, x, y, flags);

}

wl_shell_surface_set_maximized :: proc(_wl_shell_surface: ^wl_shell_surface,output : ^wl_output)
{
proxy_marshal_flags(
                cast(^wl_proxy)_wl_shell_surface,
		        7, nil, proxy_get_version(cast(^wl_proxy)_wl_shell_surface), 0, output);

}

wl_shell_surface_set_title :: proc(_wl_shell_surface: ^wl_shell_surface,title : cstring)
{
proxy_marshal_flags(
                cast(^wl_proxy)_wl_shell_surface,
		        8, nil, proxy_get_version(cast(^wl_proxy)_wl_shell_surface), 0, title);

}

wl_shell_surface_set_class :: proc(_wl_shell_surface: ^wl_shell_surface,class_ : cstring)
{
proxy_marshal_flags(
                cast(^wl_proxy)_wl_shell_surface,
		        9, nil, proxy_get_version(cast(^wl_proxy)_wl_shell_surface), 0, class_);

}

wl_shell_surface_requests: []wl_message = []wl_message{
	{ "pong", "u", raw_data([]^wl_interface{nil}) },
	{ "move", "ou", raw_data([]^wl_interface{&wl_seat_interface, nil}) },
	{ "resize", "ouu", raw_data([]^wl_interface{&wl_seat_interface, nil, nil}) },
	{ "set_toplevel", "", raw_data([]^wl_interface{}) },
	{ "set_transient", "oiiu", raw_data([]^wl_interface{&wl_surface_interface, nil, nil, nil}) },
	{ "set_fullscreen", "uu?o", raw_data([]^wl_interface{nil, nil, &wl_output_interface}) },
	{ "set_popup", "ouoiiu", raw_data([]^wl_interface{&wl_seat_interface, nil, &wl_surface_interface, nil, nil, nil}) },
	{ "set_maximized", "?o", raw_data([]^wl_interface{&wl_output_interface}) },
	{ "set_title", "s", raw_data([]^wl_interface{nil}) },
	{ "set_class", "s", raw_data([]^wl_interface{nil}) },
}

wl_shell_surface_events: []wl_message = []wl_message{
	{ "ping", "u", nil },
	{ "configure", "uii", nil },
	{ "popup_done", "", nil },
}

wl_shell_surface_interface: wl_interface = {}
@(init)
init_wl_shell_surface_interface :: proc() {
	wl_shell_surface_interface = {
		"wl_shell_surface",
		1,
		10,
		&wl_shell_surface_requests[0],
		3,
		&wl_shell_surface_events[0],
	}
}

wl_surface :: struct {}
wl_surface_listener :: struct {
	enter: proc(
		data: rawptr,
		wl_surface: ^wl_surface,
		output: ^wl_output,
	),
	leave: proc(
		data: rawptr,
		wl_surface: ^wl_surface,
		output: ^wl_output,
	),
	preferred_buffer_scale: proc(
		data: rawptr,
		wl_surface: ^wl_surface,
		factor: c.int32_t,
	),
	preferred_buffer_transform: proc(
		data: rawptr,
		wl_surface: ^wl_surface,
		transform: c.uint32_t,
	),
}

wl_surface_add_listener :: proc(
    wl_surface: ^wl_surface,
    listener: ^wl_surface_listener,
    data: rawptr,
) -> c.int {

    return proxy_add_listener(cast(^wl_proxy)wl_surface, auto_cast listener, data)
};

wl_surface_destroy :: proc(_wl_surface: ^wl_surface)
{
proxy_marshal_flags(
                cast(^wl_proxy)_wl_surface,
		        0, nil, proxy_get_version(cast(^wl_proxy)_wl_surface), WL_MARSHAL_FLAG_DESTROY);

}

wl_surface_attach :: proc(_wl_surface: ^wl_surface,buffer : ^wl_buffer,x : c.int32_t,y : c.int32_t)
{
proxy_marshal_flags(
                cast(^wl_proxy)_wl_surface,
		        1, nil, proxy_get_version(cast(^wl_proxy)_wl_surface), 0, buffer, x, y);

}

wl_surface_damage :: proc(_wl_surface: ^wl_surface,x : c.int32_t,y : c.int32_t,width : c.int32_t,height : c.int32_t)
{
proxy_marshal_flags(
                cast(^wl_proxy)_wl_surface,
		        2, nil, proxy_get_version(cast(^wl_proxy)_wl_surface), 0, x, y, width, height);

}

wl_surface_frame :: proc(_wl_surface: ^wl_surface)-> ^wl_callback {
	callback: ^wl_proxy
	callback = proxy_marshal_flags(
                cast(^wl_proxy)_wl_surface,
		        3, &wl_callback_interface, proxy_get_version(cast(^wl_proxy)_wl_surface), 0, nil);


	return cast(^wl_callback)callback;
}

wl_surface_set_opaque_region :: proc(_wl_surface: ^wl_surface,region : ^wl_region)
{
proxy_marshal_flags(
                cast(^wl_proxy)_wl_surface,
		        4, nil, proxy_get_version(cast(^wl_proxy)_wl_surface), 0, region);

}

wl_surface_set_input_region :: proc(_wl_surface: ^wl_surface,region : ^wl_region)
{
proxy_marshal_flags(
                cast(^wl_proxy)_wl_surface,
		        5, nil, proxy_get_version(cast(^wl_proxy)_wl_surface), 0, region);

}

wl_surface_commit :: proc(_wl_surface: ^wl_surface)
{
proxy_marshal_flags(
                cast(^wl_proxy)_wl_surface,
		        6, nil, proxy_get_version(cast(^wl_proxy)_wl_surface), 0);

}

wl_surface_set_buffer_transform :: proc(_wl_surface: ^wl_surface,transform : c.int32_t)
{
proxy_marshal_flags(
                cast(^wl_proxy)_wl_surface,
		        7, nil, proxy_get_version(cast(^wl_proxy)_wl_surface), 0, transform);

}

wl_surface_set_buffer_scale :: proc(_wl_surface: ^wl_surface,scale : c.int32_t)
{
proxy_marshal_flags(
                cast(^wl_proxy)_wl_surface,
		        8, nil, proxy_get_version(cast(^wl_proxy)_wl_surface), 0, scale);

}

wl_surface_damage_buffer :: proc(_wl_surface: ^wl_surface,x : c.int32_t,y : c.int32_t,width : c.int32_t,height : c.int32_t)
{
proxy_marshal_flags(
                cast(^wl_proxy)_wl_surface,
		        9, nil, proxy_get_version(cast(^wl_proxy)_wl_surface), 0, x, y, width, height);

}

wl_surface_offset :: proc(_wl_surface: ^wl_surface,x : c.int32_t,y : c.int32_t)
{
proxy_marshal_flags(
                cast(^wl_proxy)_wl_surface,
		        10, nil, proxy_get_version(cast(^wl_proxy)_wl_surface), 0, x, y);

}

wl_surface_requests: []wl_message = []wl_message{
	{ "destroy", "", raw_data([]^wl_interface{}) },
	{ "attach", "?oii", raw_data([]^wl_interface{&wl_buffer_interface, nil, nil}) },
	{ "damage", "iiii", raw_data([]^wl_interface{nil, nil, nil, nil}) },
	{ "frame", "n", raw_data([]^wl_interface{&wl_callback_interface}) },
	{ "set_opaque_region", "?o", raw_data([]^wl_interface{&wl_region_interface}) },
	{ "set_input_region", "?o", raw_data([]^wl_interface{&wl_region_interface}) },
	{ "commit", "", raw_data([]^wl_interface{}) },
	{ "set_buffer_transform", "i", raw_data([]^wl_interface{nil}) },
	{ "set_buffer_scale", "i", raw_data([]^wl_interface{nil}) },
	{ "damage_buffer", "iiii", raw_data([]^wl_interface{nil, nil, nil, nil}) },
	{ "offset", "ii", raw_data([]^wl_interface{nil, nil}) },
}

wl_surface_events: []wl_message = []wl_message{
	{ "enter", "o", nil },
	{ "leave", "o", nil },
	{ "preferred_buffer_scale", "i", nil },
	{ "preferred_buffer_transform", "u", nil },
}

wl_surface_interface: wl_interface = {}
@(init)
init_wl_surface_interface :: proc() {
	wl_surface_interface = {
		"wl_surface",
		6,
		11,
		&wl_surface_requests[0],
		4,
		&wl_surface_events[0],
	}
}

wl_seat :: struct {}
wl_seat_listener :: struct {
	capabilities: proc(
		data: rawptr,
		wl_seat: ^wl_seat,
		capabilities: c.uint32_t,
	),
	name: proc(
		data: rawptr,
		wl_seat: ^wl_seat,
		name: cstring,
	),
}

wl_seat_add_listener :: proc(
    wl_seat: ^wl_seat,
    listener: ^wl_seat_listener,
    data: rawptr,
) -> c.int {

    return proxy_add_listener(cast(^wl_proxy)wl_seat, auto_cast listener, data)
};

wl_seat_get_pointer :: proc(_wl_seat: ^wl_seat)-> ^wl_pointer {
	id: ^wl_proxy
	id = proxy_marshal_flags(
                cast(^wl_proxy)_wl_seat,
		        0, &wl_pointer_interface, proxy_get_version(cast(^wl_proxy)_wl_seat), 0, nil);


	return cast(^wl_pointer)id;
}

wl_seat_get_keyboard :: proc(_wl_seat: ^wl_seat)-> ^wl_keyboard {
	id: ^wl_proxy
	id = proxy_marshal_flags(
                cast(^wl_proxy)_wl_seat,
		        1, &wl_keyboard_interface, proxy_get_version(cast(^wl_proxy)_wl_seat), 0, nil);


	return cast(^wl_keyboard)id;
}

wl_seat_get_touch :: proc(_wl_seat: ^wl_seat)-> ^wl_touch {
	id: ^wl_proxy
	id = proxy_marshal_flags(
                cast(^wl_proxy)_wl_seat,
		        2, &wl_touch_interface, proxy_get_version(cast(^wl_proxy)_wl_seat), 0, nil);


	return cast(^wl_touch)id;
}

wl_seat_release :: proc(_wl_seat: ^wl_seat)
{
proxy_marshal_flags(
                cast(^wl_proxy)_wl_seat,
		        3, nil, proxy_get_version(cast(^wl_proxy)_wl_seat), WL_MARSHAL_FLAG_DESTROY);

}

wl_seat_requests: []wl_message = []wl_message{
	{ "get_pointer", "n", raw_data([]^wl_interface{&wl_pointer_interface}) },
	{ "get_keyboard", "n", raw_data([]^wl_interface{&wl_keyboard_interface}) },
	{ "get_touch", "n", raw_data([]^wl_interface{&wl_touch_interface}) },
	{ "release", "", raw_data([]^wl_interface{}) },
}

wl_seat_events: []wl_message = []wl_message{
	{ "capabilities", "u", nil },
	{ "name", "s", nil },
}

wl_seat_interface: wl_interface = {}
@(init)
init_wl_seat_interface :: proc() {
	wl_seat_interface = {
		"wl_seat",
		9,
		4,
		&wl_seat_requests[0],
		2,
		&wl_seat_events[0],
	}
}

wl_pointer :: struct {}
wl_pointer_listener :: struct {
	enter: proc(
		data: rawptr,
		wl_pointer: ^wl_pointer,
		serial: c.uint32_t,
		surface: ^wl_surface,
		surface_x: wl_fixed_t,
		surface_y: wl_fixed_t,
	),
	leave: proc(
		data: rawptr,
		wl_pointer: ^wl_pointer,
		serial: c.uint32_t,
		surface: ^wl_surface,
	),
	motion: proc(
		data: rawptr,
		wl_pointer: ^wl_pointer,
		time: c.uint32_t,
		surface_x: wl_fixed_t,
		surface_y: wl_fixed_t,
	),
	button: proc(
		data: rawptr,
		wl_pointer: ^wl_pointer,
		serial: c.uint32_t,
		time: c.uint32_t,
		button: c.uint32_t,
		state: c.uint32_t,
	),
	axis: proc(
		data: rawptr,
		wl_pointer: ^wl_pointer,
		time: c.uint32_t,
		axis: c.uint32_t,
		value: wl_fixed_t,
	),
	frame: proc(
		data: rawptr,
		wl_pointer: ^wl_pointer,
	),
	axis_source: proc(
		data: rawptr,
		wl_pointer: ^wl_pointer,
		axis_source: c.uint32_t,
	),
	axis_stop: proc(
		data: rawptr,
		wl_pointer: ^wl_pointer,
		time: c.uint32_t,
		axis: c.uint32_t,
	),
	axis_discrete: proc(
		data: rawptr,
		wl_pointer: ^wl_pointer,
		axis: c.uint32_t,
		discrete: c.int32_t,
	),
	axis_value120: proc(
		data: rawptr,
		wl_pointer: ^wl_pointer,
		axis: c.uint32_t,
		value120: c.int32_t,
	),
	axis_relative_direction: proc(
		data: rawptr,
		wl_pointer: ^wl_pointer,
		axis: c.uint32_t,
		direction: c.uint32_t,
	),
}

wl_pointer_add_listener :: proc(
    wl_pointer: ^wl_pointer,
    listener: ^wl_pointer_listener,
    data: rawptr,
) -> c.int {

    return proxy_add_listener(cast(^wl_proxy)wl_pointer, auto_cast listener, data)
};

wl_pointer_set_cursor :: proc(_wl_pointer: ^wl_pointer,serial : c.uint32_t,surface : ^wl_surface,hotspot_x : c.int32_t,hotspot_y : c.int32_t)
{
proxy_marshal_flags(
                cast(^wl_proxy)_wl_pointer,
		        0, nil, proxy_get_version(cast(^wl_proxy)_wl_pointer), 0, serial, surface, hotspot_x, hotspot_y);

}

wl_pointer_release :: proc(_wl_pointer: ^wl_pointer)
{
proxy_marshal_flags(
                cast(^wl_proxy)_wl_pointer,
		        1, nil, proxy_get_version(cast(^wl_proxy)_wl_pointer), WL_MARSHAL_FLAG_DESTROY);

}

wl_pointer_requests: []wl_message = []wl_message{
	{ "set_cursor", "u?oii", raw_data([]^wl_interface{nil, &wl_surface_interface, nil, nil}) },
	{ "release", "", raw_data([]^wl_interface{}) },
}

wl_pointer_events: []wl_message = []wl_message{
	{ "enter", "uoff", nil },
	{ "leave", "uo", nil },
	{ "motion", "uff", nil },
	{ "button", "uuuu", nil },
	{ "axis", "uuf", nil },
	{ "frame", "", nil },
	{ "axis_source", "u", nil },
	{ "axis_stop", "uu", nil },
	{ "axis_discrete", "ui", nil },
	{ "axis_value120", "ui", nil },
	{ "axis_relative_direction", "uu", nil },
}

wl_pointer_interface: wl_interface = {}
@(init)
init_wl_pointer_interface :: proc() {
	wl_pointer_interface = {
		"wl_pointer",
		9,
		2,
		&wl_pointer_requests[0],
		11,
		&wl_pointer_events[0],
	}
}

wl_keyboard :: struct {}
wl_keyboard_listener :: struct {
	keymap: proc(
		data: rawptr,
		wl_keyboard: ^wl_keyboard,
		format: c.uint32_t,
		fd: c.int32_t,
		size: c.uint32_t,
	),
	enter: proc(
		data: rawptr,
		wl_keyboard: ^wl_keyboard,
		serial: c.uint32_t,
		surface: ^wl_surface,
		keys: ^wl_array,
	),
	leave: proc(
		data: rawptr,
		wl_keyboard: ^wl_keyboard,
		serial: c.uint32_t,
		surface: ^wl_surface,
	),
	key: proc(
		data: rawptr,
		wl_keyboard: ^wl_keyboard,
		serial: c.uint32_t,
		time: c.uint32_t,
		key: c.uint32_t,
		state: c.uint32_t,
	),
	modifiers: proc(
		data: rawptr,
		wl_keyboard: ^wl_keyboard,
		serial: c.uint32_t,
		mods_depressed: c.uint32_t,
		mods_latched: c.uint32_t,
		mods_locked: c.uint32_t,
		group: c.uint32_t,
	),
	repeat_info: proc(
		data: rawptr,
		wl_keyboard: ^wl_keyboard,
		rate: c.int32_t,
		delay: c.int32_t,
	),
}

wl_keyboard_add_listener :: proc(
    wl_keyboard: ^wl_keyboard,
    listener: ^wl_keyboard_listener,
    data: rawptr,
) -> c.int {

    return proxy_add_listener(cast(^wl_proxy)wl_keyboard, auto_cast listener, data)
};

wl_keyboard_release :: proc(_wl_keyboard: ^wl_keyboard)
{
proxy_marshal_flags(
                cast(^wl_proxy)_wl_keyboard,
		        0, nil, proxy_get_version(cast(^wl_proxy)_wl_keyboard), WL_MARSHAL_FLAG_DESTROY);

}

wl_keyboard_requests: []wl_message = []wl_message{
	{ "release", "", raw_data([]^wl_interface{}) },
}

wl_keyboard_events: []wl_message = []wl_message{
	{ "keymap", "uhu", nil },
	{ "enter", "uoa", nil },
	{ "leave", "uo", nil },
	{ "key", "uuuu", nil },
	{ "modifiers", "uuuuu", nil },
	{ "repeat_info", "ii", nil },
}

wl_keyboard_interface: wl_interface = {}
@(init)
init_wl_keyboard_interface :: proc() {
	wl_keyboard_interface = {
		"wl_keyboard",
		9,
		1,
		&wl_keyboard_requests[0],
		6,
		&wl_keyboard_events[0],
	}
}

wl_touch :: struct {}
wl_touch_listener :: struct {
	down: proc(
		data: rawptr,
		wl_touch: ^wl_touch,
		serial: c.uint32_t,
		time: c.uint32_t,
		surface: ^wl_surface,
		id: c.int32_t,
		x: wl_fixed_t,
		y: wl_fixed_t,
	),
	up: proc(
		data: rawptr,
		wl_touch: ^wl_touch,
		serial: c.uint32_t,
		time: c.uint32_t,
		id: c.int32_t,
	),
	motion: proc(
		data: rawptr,
		wl_touch: ^wl_touch,
		time: c.uint32_t,
		id: c.int32_t,
		x: wl_fixed_t,
		y: wl_fixed_t,
	),
	frame: proc(
		data: rawptr,
		wl_touch: ^wl_touch,
	),
	cancel: proc(
		data: rawptr,
		wl_touch: ^wl_touch,
	),
	shape: proc(
		data: rawptr,
		wl_touch: ^wl_touch,
		id: c.int32_t,
		major: wl_fixed_t,
		minor: wl_fixed_t,
	),
	orientation: proc(
		data: rawptr,
		wl_touch: ^wl_touch,
		id: c.int32_t,
		orientation: wl_fixed_t,
	),
}

wl_touch_add_listener :: proc(
    wl_touch: ^wl_touch,
    listener: ^wl_touch_listener,
    data: rawptr,
) -> c.int {

    return proxy_add_listener(cast(^wl_proxy)wl_touch, auto_cast listener, data)
};

wl_touch_release :: proc(_wl_touch: ^wl_touch)
{
proxy_marshal_flags(
                cast(^wl_proxy)_wl_touch,
		        0, nil, proxy_get_version(cast(^wl_proxy)_wl_touch), WL_MARSHAL_FLAG_DESTROY);

}

wl_touch_requests: []wl_message = []wl_message{
	{ "release", "", raw_data([]^wl_interface{}) },
}

wl_touch_events: []wl_message = []wl_message{
	{ "down", "uuoiff", nil },
	{ "up", "uui", nil },
	{ "motion", "uiff", nil },
	{ "frame", "", nil },
	{ "cancel", "", nil },
	{ "shape", "iff", nil },
	{ "orientation", "if", nil },
}

wl_touch_interface: wl_interface = {}
@(init)
init_wl_touch_interface :: proc() {
	wl_touch_interface = {
		"wl_touch",
		9,
		1,
		&wl_touch_requests[0],
		7,
		&wl_touch_events[0],
	}
}

wl_output :: struct {}
wl_output_listener :: struct {
	geometry: proc(
		data: rawptr,
		wl_output: ^wl_output,
		x: c.int32_t,
		y: c.int32_t,
		physical_width: c.int32_t,
		physical_height: c.int32_t,
		subpixel: c.int32_t,
		make: cstring,
		model: cstring,
		transform: c.int32_t,
	),
	mode: proc(
		data: rawptr,
		wl_output: ^wl_output,
		flags: c.uint32_t,
		width: c.int32_t,
		height: c.int32_t,
		refresh: c.int32_t,
	),
	done: proc(
		data: rawptr,
		wl_output: ^wl_output,
	),
	scale: proc(
		data: rawptr,
		wl_output: ^wl_output,
		factor: c.int32_t,
	),
	name: proc(
		data: rawptr,
		wl_output: ^wl_output,
		name: cstring,
	),
	description: proc(
		data: rawptr,
		wl_output: ^wl_output,
		description: cstring,
	),
}

wl_output_add_listener :: proc(
    wl_output: ^wl_output,
    listener: ^wl_output_listener,
    data: rawptr,
) -> c.int {

    return proxy_add_listener(cast(^wl_proxy)wl_output, auto_cast listener, data)
};

wl_output_release :: proc(_wl_output: ^wl_output)
{
proxy_marshal_flags(
                cast(^wl_proxy)_wl_output,
		        0, nil, proxy_get_version(cast(^wl_proxy)_wl_output), WL_MARSHAL_FLAG_DESTROY);

}

wl_output_requests: []wl_message = []wl_message{
	{ "release", "", raw_data([]^wl_interface{}) },
}

wl_output_events: []wl_message = []wl_message{
	{ "geometry", "iiiiissi", nil },
	{ "mode", "uiii", nil },
	{ "done", "", nil },
	{ "scale", "i", nil },
	{ "name", "s", nil },
	{ "description", "s", nil },
}

wl_output_interface: wl_interface = {}
@(init)
init_wl_output_interface :: proc() {
	wl_output_interface = {
		"wl_output",
		4,
		1,
		&wl_output_requests[0],
		6,
		&wl_output_events[0],
	}
}

wl_region :: struct {}
wl_region_listener :: struct {
}

wl_region_add_listener :: proc(
    wl_region: ^wl_region,
    listener: ^wl_region_listener,
    data: rawptr,
) -> c.int {

    return proxy_add_listener(cast(^wl_proxy)wl_region, auto_cast listener, data)
};

wl_region_destroy :: proc(_wl_region: ^wl_region)
{
proxy_marshal_flags(
                cast(^wl_proxy)_wl_region,
		        0, nil, proxy_get_version(cast(^wl_proxy)_wl_region), WL_MARSHAL_FLAG_DESTROY);

}

wl_region_add :: proc(_wl_region: ^wl_region,x : c.int32_t,y : c.int32_t,width : c.int32_t,height : c.int32_t)
{
proxy_marshal_flags(
                cast(^wl_proxy)_wl_region,
		        1, nil, proxy_get_version(cast(^wl_proxy)_wl_region), 0, x, y, width, height);

}

wl_region_subtract :: proc(_wl_region: ^wl_region,x : c.int32_t,y : c.int32_t,width : c.int32_t,height : c.int32_t)
{
proxy_marshal_flags(
                cast(^wl_proxy)_wl_region,
		        2, nil, proxy_get_version(cast(^wl_proxy)_wl_region), 0, x, y, width, height);

}

wl_region_requests: []wl_message = []wl_message{
	{ "destroy", "", raw_data([]^wl_interface{}) },
	{ "add", "iiii", raw_data([]^wl_interface{nil, nil, nil, nil}) },
	{ "subtract", "iiii", raw_data([]^wl_interface{nil, nil, nil, nil}) },
}

wl_region_events: []wl_message = []wl_message{
}

wl_region_interface: wl_interface = {}
@(init)
init_wl_region_interface :: proc() {
	wl_region_interface = {
		"wl_region",
		1,
		3,
		&wl_region_requests[0],
		0,
		nil,
	}
}

wl_subcompositor :: struct {}
wl_subcompositor_listener :: struct {
}

wl_subcompositor_add_listener :: proc(
    wl_subcompositor: ^wl_subcompositor,
    listener: ^wl_subcompositor_listener,
    data: rawptr,
) -> c.int {

    return proxy_add_listener(cast(^wl_proxy)wl_subcompositor, auto_cast listener, data)
};

wl_subcompositor_destroy :: proc(_wl_subcompositor: ^wl_subcompositor)
{
proxy_marshal_flags(
                cast(^wl_proxy)_wl_subcompositor,
		        0, nil, proxy_get_version(cast(^wl_proxy)_wl_subcompositor), WL_MARSHAL_FLAG_DESTROY);

}

wl_subcompositor_get_subsurface :: proc(_wl_subcompositor: ^wl_subcompositor,surface : ^wl_surface,parent : ^wl_surface)-> ^wl_subsurface {
	id: ^wl_proxy
	id = proxy_marshal_flags(
                cast(^wl_proxy)_wl_subcompositor,
		        1, &wl_subsurface_interface, proxy_get_version(cast(^wl_proxy)_wl_subcompositor), 0, nil, surface, parent);


	return cast(^wl_subsurface)id;
}

wl_subcompositor_requests: []wl_message = []wl_message{
	{ "destroy", "", raw_data([]^wl_interface{}) },
	{ "get_subsurface", "noo", raw_data([]^wl_interface{&wl_subsurface_interface, &wl_surface_interface, &wl_surface_interface}) },
}

wl_subcompositor_events: []wl_message = []wl_message{
}

wl_subcompositor_interface: wl_interface = {}
@(init)
init_wl_subcompositor_interface :: proc() {
	wl_subcompositor_interface = {
		"wl_subcompositor",
		1,
		2,
		&wl_subcompositor_requests[0],
		0,
		nil,
	}
}

wl_subsurface :: struct {}
wl_subsurface_listener :: struct {
}

wl_subsurface_add_listener :: proc(
    wl_subsurface: ^wl_subsurface,
    listener: ^wl_subsurface_listener,
    data: rawptr,
) -> c.int {

    return proxy_add_listener(cast(^wl_proxy)wl_subsurface, auto_cast listener, data)
};

wl_subsurface_destroy :: proc(_wl_subsurface: ^wl_subsurface)
{
proxy_marshal_flags(
                cast(^wl_proxy)_wl_subsurface,
		        0, nil, proxy_get_version(cast(^wl_proxy)_wl_subsurface), WL_MARSHAL_FLAG_DESTROY);

}

wl_subsurface_set_position :: proc(_wl_subsurface: ^wl_subsurface,x : c.int32_t,y : c.int32_t)
{
proxy_marshal_flags(
                cast(^wl_proxy)_wl_subsurface,
		        1, nil, proxy_get_version(cast(^wl_proxy)_wl_subsurface), 0, x, y);

}

wl_subsurface_place_above :: proc(_wl_subsurface: ^wl_subsurface,sibling : ^wl_surface)
{
proxy_marshal_flags(
                cast(^wl_proxy)_wl_subsurface,
		        2, nil, proxy_get_version(cast(^wl_proxy)_wl_subsurface), 0, sibling);

}

wl_subsurface_place_below :: proc(_wl_subsurface: ^wl_subsurface,sibling : ^wl_surface)
{
proxy_marshal_flags(
                cast(^wl_proxy)_wl_subsurface,
		        3, nil, proxy_get_version(cast(^wl_proxy)_wl_subsurface), 0, sibling);

}

wl_subsurface_set_sync :: proc(_wl_subsurface: ^wl_subsurface)
{
proxy_marshal_flags(
                cast(^wl_proxy)_wl_subsurface,
		        4, nil, proxy_get_version(cast(^wl_proxy)_wl_subsurface), 0);

}

wl_subsurface_set_desync :: proc(_wl_subsurface: ^wl_subsurface)
{
proxy_marshal_flags(
                cast(^wl_proxy)_wl_subsurface,
		        5, nil, proxy_get_version(cast(^wl_proxy)_wl_subsurface), 0);

}

wl_subsurface_requests: []wl_message = []wl_message{
	{ "destroy", "", raw_data([]^wl_interface{}) },
	{ "set_position", "ii", raw_data([]^wl_interface{nil, nil}) },
	{ "place_above", "o", raw_data([]^wl_interface{&wl_surface_interface}) },
	{ "place_below", "o", raw_data([]^wl_interface{&wl_surface_interface}) },
	{ "set_sync", "", raw_data([]^wl_interface{}) },
	{ "set_desync", "", raw_data([]^wl_interface{}) },
}

wl_subsurface_events: []wl_message = []wl_message{
}

wl_subsurface_interface: wl_interface = {}
@(init)
init_wl_subsurface_interface :: proc() {
	wl_subsurface_interface = {
		"wl_subsurface",
		1,
		6,
		&wl_subsurface_requests[0],
		0,
		nil,
	}
}
