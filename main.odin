package main

import "core:fmt"
import "core:c"


foreign import lib "system:wayland-client"
// foreign import public "wayland-public.o"


wl_list :: struct {
    prev: ^wl_list,
    next: ^wl_list
}

wl_event_queue :: struct {
    event_list: wl_list, 
    proxy_list: wl_list, 
    display: ^wl_display,
    name: cstring
}

// struct wl_message {
// 	/** Message name */
// 	const char *name;
// 	/** Message signature */
// 	const char *signature;
// 	/** Object argument interfaces */
// 	const struct wl_interface **types;
// };
wl_message :: struct {
    name: cstring,
    signature: cstring,
    types: ^^wl_interface

}

wl_interface :: struct {
    name: cstring,
    version: c.int,
    method_count: c.int,
    methods: ^wl_message,
    event_count: c.int,
    events: ^wl_message
}

Implementation :: #type proc "c" () -> ()
wl_object :: struct {
    interface: ^wl_interface,
    implementation: ^Implementation,
    id: c.uint32_t
}

// struct wl_proxy {
// 	struct wl_object object;
// 	struct wl_display *display;
// 	struct wl_event_queue *queue;
// 	uint32_t flags;
// 	int refcount;
// 	void *user_data;
// 	wl_dispatcher_func_t dispatcher;
// 	uint32_t version;
// 	const char * const *tag;
// 	struct wl_list queue_link; /**< in struct wl_event_queue::proxy_list */
// };

wl_proxy :: struct {
    object: wl_object,
    display: ^wl_display,
    queue: u64, // pointer to wl_event_queue
    flags: c.uint32_t,
    refcount: c.int,
    user_data: u64, // void* pointer
    dispatcher: u64, // wl_dispatcher_func_t dispatcher;
    version: c.uint32_t,
    tag: cstring,
    queue_link: wl_list,
};

wl_ring_buffer :: struct {
    data: cstring,
    head: c.size_t,
    tail: c.size_t,
    size_bits: c.uint32_t,
    max_size_bits: c.uint32_t
}

MAX_FDS_OUT	:: 28
// #define CLEN		(CMSG_LEN(MAX_FDS_OUT * sizeof(int32_t)))

wl_connection :: struct {
    _in: wl_ring_buffer,
    out: wl_ring_buffer,
    fds_in: wl_ring_buffer,
    fds_out: wl_ring_buffer,
    fd: c.int,
    want_flush: c.int,
};

// struct wl_display {
// 	struct wl_proxy proxy;
// 	struct wl_connection *connection;

// 	/* errno of the last wl_display error */
// 	int last_error;

// 	/* When display gets an error event from some object, it stores
// 	 * information about it here, so that client can get this
// 	 * information afterwards */
// 	struct {
// 		/* Code of the error. It can be compared to
// 		 * the interface's errors enumeration. */
// 		uint32_t code;
// 		/* interface (protocol) in which the error occurred */
// 		const struct wl_interface *interface;
// 		/* id of the proxy that caused the error. There's no warranty
// 		 * that the proxy is still valid. It's up to client how it will
// 		 * use it */
// 		uint32_t id;
// 	} protocol_error;
// 	int fd;
// 	struct wl_map objects;
// 	struct wl_event_queue display_queue;
// 	struct wl_event_queue default_queue;
// 	pthread_mutex_t mutex;

// 	int reader_count;
// 	uint32_t read_serial;
// 	pthread_cond_t reader_cond;
// };

wl_display :: struct {
    proxy: wl_proxy,
    connection: ^wl_connection,
    last_error: c.int,
    protocol_error: _wl_protocol_error,
    fd: c.int
}
_wl_protocol_error :: struct {
    code: c.uint32_t,
    interface: ^wl_interface,
    id: c.uint32_t
}

wl_registry :: struct {}

wl_registry_listener :: struct {
    global: proc(rawptr, ^wl_registry, c.uint32_t, cstring, c.uint32_t),
    global_remove: proc(rawptr, ^wl_registry, c.uint32_t)
};


@(default_calling_convention="c")
foreign lib {
    wl_display_connect :: proc(cstring) -> ^wl_display ---
    wl_proxy_marshal_flags :: proc(^wl_proxy, c.uint32_t, ^wl_interface, c.uint32_t, c.uint32_t, #c_vararg ..any) -> ^wl_proxy ---
    wl_proxy_get_version :: proc(^wl_proxy) -> c.uint32_t --- 
    wl_display_roundtrip :: proc(^wl_display) -> c.int --- 
    wl_proxy_add_listener:: proc(^wl_proxy, ^Implementation, rawptr) -> c.int ---
    wl_registry_interface: wl_interface
}

WL_DISPLAY_GET_REGISTRY :: 1

wl_display_get_registry :: proc (display: ^wl_display) -> ^wl_registry
{
     registry: ^wl_proxy = wl_proxy_marshal_flags(
                  cast(^wl_proxy)display, 
                  WL_DISPLAY_GET_REGISTRY, 
                  &wl_registry_interface, 
                  wl_proxy_get_version(cast(^wl_proxy)display), 
                  0, nil
                  );
    return auto_cast registry;
}
// static inline int
// wl_registry_add_listener(struct wl_registry *wl_registry,
// 			 const struct wl_registry_listener *listener, void *data)
// {
// 	return wl_proxy_add_listener((struct wl_proxy *) wl_registry,
// 				     (void (**)(void)) listener, data);
// }

wl_registry_add_listener :: proc (wl_registry: ^wl_registry, listener: ^wl_registry_listener, data: rawptr) -> c.int {

    return wl_proxy_add_listener(cast(^wl_proxy)wl_registry, auto_cast listener, data); 
}


global :: proc(data: rawptr , registry: ^wl_registry, name: c.uint32_t, interface: cstring, version: c.uint32_t) {
    fmt.println(interface);
}
global_remove :: proc(data: rawptr , registry: ^wl_registry, name: c.uint32_t) {
}

main::proc() {
    display := wl_display_connect(nil);
    fmt.println(display);

    registry := wl_display_get_registry(display);

    fmt.println(display);
    fmt.println(registry);


    listener := wl_registry_listener {
        global= global,
        global_remove= global_remove
    };
    wl_registry_add_listener(registry, &listener, nil);

    x := wl_display_roundtrip(display);
    fmt.println(x);
}
