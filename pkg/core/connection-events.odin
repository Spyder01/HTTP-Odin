package core

import "core:net"
import "../parsers"


Error :: union {
    parsers.Error,
    parsers.ParseError,
    net.Network_Error,
}

ErrorEventName :: "error"

ErrorRegistry :: struct {
    latest_error: Error,
    errors: [dynamic]Error,
}

Listener :: proc(event: ^ConnectionEvent)

ConnectionEvent :: struct {
    interrupt: bool,
    connection_number: int,
    error_registry: ^ErrorRegistry,
    listeners: map[string][dynamic]^Listener,
}

default_connection_event :: proc ()->ConnectionEvent {
    event := ConnectionEvent{}

    event.interrupt = false
    event.connection_number = 0
    event.error_registry = &ErrorRegistry{nil, [dynamic]Error{}}

    return event
} 

interrupt_connection :: proc(event: ^ConnectionEvent) {
    event.interrupt = true;
}

register_error :: proc (event: ^ConnectionEvent, err: Error) {
    event.error_registry.latest_error = err
    append(&event.error_registry.errors, err)

    dispatch_event(event, ErrorEventName)
}

dispatch_event :: proc(event: ^ConnectionEvent, event_name: string)->int {
    listeners, found := event.listeners[event_name]

    if !found {
        return 1
    }

    for listener in listeners {
        listener^(event)
    }

    return 0
}

add_event_listeners :: proc(event: ^ConnectionEvent, event_name: string, listener: ^Listener) {
    listeners, found := event.listeners[event_name]

    if !found {
        event.listeners[event_name] = [dynamic]^Listener{listener}
        return
    }

    append(&event.listeners[event_name], listener)
}
