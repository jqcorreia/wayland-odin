package wayland

import "core:c"

zwlr_layer_shell_v1 :: struct {}
zwlr_layer_shell_v1_listener :: struct {
}

zwlr_layer_shell_v1_add_listener :: proc(
    zwlr_layer_shell_v1: ^zwlr_layer_shell_v1,
    listener: ^zwlr_layer_shell_v1_listener,
    data: rawptr,
) -> c.int {

    return proxy_add_listener(cast(^wl_proxy)zwlr_layer_shell_v1, cast(^Implementation)listener, data)
};

zwlr_layer_shell_v1_get_layer_surface :: proc "c" (_zwlr_layer_shell_v1: ^zwlr_layer_shell_v1,surface : ^wl_surface,output : ^wl_output,layer : zwlr_layer_shell_v1_layer,namespace : cstring)-> ^zwlr_layer_surface_v1 {
	id: ^wl_proxy
	id = proxy_marshal_flags(
                cast(^wl_proxy)_zwlr_layer_shell_v1,
		        0, &zwlr_layer_surface_v1_interface, proxy_get_version(cast(^wl_proxy)_zwlr_layer_shell_v1), 0, nil, surface, output, layer, namespace);


	return cast(^zwlr_layer_surface_v1)id;
}

zwlr_layer_shell_v1_destroy :: proc "c" (_zwlr_layer_shell_v1: ^zwlr_layer_shell_v1)
{
proxy_marshal_flags(
                cast(^wl_proxy)_zwlr_layer_shell_v1,
		        1, nil, proxy_get_version(cast(^wl_proxy)_zwlr_layer_shell_v1), WL_MARSHAL_FLAG_DESTROY);

}

zwlr_layer_shell_v1_requests: []wl_message = []wl_message{
	{ "get_layer_surface", "no?ous", raw_data([]^wl_interface{&zwlr_layer_surface_v1_interface, &wl_surface_interface, &wl_output_interface, nil, nil}) },
	{ "destroy", "", raw_data([]^wl_interface{}) },
}

zwlr_layer_shell_v1_events: []wl_message = []wl_message{
}

zwlr_layer_shell_v1_interface: wl_interface = {}
@(init)
init_zwlr_layer_shell_v1_interface :: proc() {
	zwlr_layer_shell_v1_interface = {
		"zwlr_layer_shell_v1",
		5,
		2,
		&zwlr_layer_shell_v1_requests[0],
		0,
		nil,
	}
}

zwlr_layer_shell_v1_error :: enum {
	ALREADY_CONSTRUCTED = 2,
	ROLE = 0,
	INVALID_LAYER = 1,
}

zwlr_layer_shell_v1_layer :: enum {
	OVERLAY = 3,
	BOTTOM = 1,
	TOP = 2,
	BACKGROUND = 0,
}

zwlr_layer_surface_v1 :: struct {}
zwlr_layer_surface_v1_listener :: struct {
	configure: proc "c" (
		data: rawptr,
		zwlr_layer_surface_v1: ^zwlr_layer_surface_v1,
		serial: c.uint32_t,
		width: c.uint32_t,
		height: c.uint32_t,
	),
	closed: proc "c" (
		data: rawptr,
		zwlr_layer_surface_v1: ^zwlr_layer_surface_v1,
	),
}

zwlr_layer_surface_v1_add_listener :: proc(
    zwlr_layer_surface_v1: ^zwlr_layer_surface_v1,
    listener: ^zwlr_layer_surface_v1_listener,
    data: rawptr,
) -> c.int {

    return proxy_add_listener(cast(^wl_proxy)zwlr_layer_surface_v1, cast(^Implementation)listener, data)
};

zwlr_layer_surface_v1_set_size :: proc "c" (_zwlr_layer_surface_v1: ^zwlr_layer_surface_v1,width : c.uint32_t,height : c.uint32_t)
{
proxy_marshal_flags(
                cast(^wl_proxy)_zwlr_layer_surface_v1,
		        0, nil, proxy_get_version(cast(^wl_proxy)_zwlr_layer_surface_v1), 0, width, height);

}

zwlr_layer_surface_v1_set_anchor :: proc "c" (_zwlr_layer_surface_v1: ^zwlr_layer_surface_v1,anchor : zwlr_layer_surface_v1_anchor)
{
proxy_marshal_flags(
                cast(^wl_proxy)_zwlr_layer_surface_v1,
		        1, nil, proxy_get_version(cast(^wl_proxy)_zwlr_layer_surface_v1), 0, anchor);

}

zwlr_layer_surface_v1_set_exclusive_zone :: proc "c" (_zwlr_layer_surface_v1: ^zwlr_layer_surface_v1,zone : c.int32_t)
{
proxy_marshal_flags(
                cast(^wl_proxy)_zwlr_layer_surface_v1,
		        2, nil, proxy_get_version(cast(^wl_proxy)_zwlr_layer_surface_v1), 0, zone);

}

zwlr_layer_surface_v1_set_margin :: proc "c" (_zwlr_layer_surface_v1: ^zwlr_layer_surface_v1,top : c.int32_t,right : c.int32_t,bottom : c.int32_t,left : c.int32_t)
{
proxy_marshal_flags(
                cast(^wl_proxy)_zwlr_layer_surface_v1,
		        3, nil, proxy_get_version(cast(^wl_proxy)_zwlr_layer_surface_v1), 0, top, right, bottom, left);

}

zwlr_layer_surface_v1_set_keyboard_interactivity :: proc "c" (_zwlr_layer_surface_v1: ^zwlr_layer_surface_v1,keyboard_interactivity : zwlr_layer_surface_v1_keyboard_interactivity)
{
proxy_marshal_flags(
                cast(^wl_proxy)_zwlr_layer_surface_v1,
		        4, nil, proxy_get_version(cast(^wl_proxy)_zwlr_layer_surface_v1), 0, keyboard_interactivity);

}

zwlr_layer_surface_v1_get_popup :: proc "c" (_zwlr_layer_surface_v1: ^zwlr_layer_surface_v1,popup : ^xdg_popup)
{
proxy_marshal_flags(
                cast(^wl_proxy)_zwlr_layer_surface_v1,
		        5, nil, proxy_get_version(cast(^wl_proxy)_zwlr_layer_surface_v1), 0, popup);

}

zwlr_layer_surface_v1_ack_configure :: proc "c" (_zwlr_layer_surface_v1: ^zwlr_layer_surface_v1,serial : c.uint32_t)
{
proxy_marshal_flags(
                cast(^wl_proxy)_zwlr_layer_surface_v1,
		        6, nil, proxy_get_version(cast(^wl_proxy)_zwlr_layer_surface_v1), 0, serial);

}

zwlr_layer_surface_v1_destroy :: proc "c" (_zwlr_layer_surface_v1: ^zwlr_layer_surface_v1)
{
proxy_marshal_flags(
                cast(^wl_proxy)_zwlr_layer_surface_v1,
		        7, nil, proxy_get_version(cast(^wl_proxy)_zwlr_layer_surface_v1), WL_MARSHAL_FLAG_DESTROY);

}

zwlr_layer_surface_v1_set_layer :: proc "c" (_zwlr_layer_surface_v1: ^zwlr_layer_surface_v1,layer : zwlr_layer_shell_v1_layer)
{
proxy_marshal_flags(
                cast(^wl_proxy)_zwlr_layer_surface_v1,
		        8, nil, proxy_get_version(cast(^wl_proxy)_zwlr_layer_surface_v1), 0, layer);

}

zwlr_layer_surface_v1_set_exclusive_edge :: proc "c" (_zwlr_layer_surface_v1: ^zwlr_layer_surface_v1,edge : zwlr_layer_surface_v1_anchor)
{
proxy_marshal_flags(
                cast(^wl_proxy)_zwlr_layer_surface_v1,
		        9, nil, proxy_get_version(cast(^wl_proxy)_zwlr_layer_surface_v1), 0, edge);

}

zwlr_layer_surface_v1_requests: []wl_message = []wl_message{
	{ "set_size", "uu", raw_data([]^wl_interface{nil, nil}) },
	{ "set_anchor", "u", raw_data([]^wl_interface{nil}) },
	{ "set_exclusive_zone", "i", raw_data([]^wl_interface{nil}) },
	{ "set_margin", "iiii", raw_data([]^wl_interface{nil, nil, nil, nil}) },
	{ "set_keyboard_interactivity", "u", raw_data([]^wl_interface{nil}) },
	{ "get_popup", "o", raw_data([]^wl_interface{&xdg_popup_interface}) },
	{ "ack_configure", "u", raw_data([]^wl_interface{nil}) },
	{ "destroy", "", raw_data([]^wl_interface{}) },
	{ "set_layer", "u", raw_data([]^wl_interface{nil}) },
	{ "set_exclusive_edge", "u", raw_data([]^wl_interface{nil}) },
}

zwlr_layer_surface_v1_events: []wl_message = []wl_message{
	{ "configure", "uuu", raw_data([]^wl_interface{nil, nil, nil}) },
	{ "closed", "", raw_data([]^wl_interface{}) },
}

zwlr_layer_surface_v1_interface: wl_interface = {}
@(init)
init_zwlr_layer_surface_v1_interface :: proc() {
	zwlr_layer_surface_v1_interface = {
		"zwlr_layer_surface_v1",
		5,
		10,
		&zwlr_layer_surface_v1_requests[0],
		2,
		&zwlr_layer_surface_v1_events[0],
	}
}

zwlr_layer_surface_v1_keyboard_interactivity :: enum {
	EXCLUSIVE = 1,
	ON_DEMAND = 2,
	NONE = 0,
}

zwlr_layer_surface_v1_error :: enum {
	INVALID_ANCHOR = 2,
	INVALID_SURFACE_STATE = 0,
	INVALID_KEYBOARD_INTERACTIVITY = 3,
	INVALID_EXCLUSIVE_EDGE = 4,
	INVALID_SIZE = 1,
}

zwlr_layer_surface_v1_anchor :: enum {
	TOP = 1,
	LEFT = 4,
	RIGHT = 8,
	BOTTOM = 2,
}

