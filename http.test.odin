package http

import "core:net"
import "core:fmt"
import "core:testing"
import "core:strconv"
import "./pkg/parsers"

error_listener :: proc(event: ^ConnectionEvent) {
    fmt.eprintln(event.error_registry.latest_error)
}

on_server_start :: proc(event: ^ConnectionEvent) {
    fmt.println("Sever starting")
}

on_server_end :: proc(event: ^ConnectionEvent) {
    fmt.println("Server ending")
}


// @(test)
main :: proc() {

    event := default_connection_event()

    on_server_start_event := EventListener(on_server_start)
    on_server_ends := EventListener(on_server_end)
    add_event_listener(&event, "start", &on_server_start_event)
    add_event_listener(&event, "end", &on_server_ends)

    fmt.println("staring server")

    err := listen_http(net.Endpoint{
        net.IP4_Address{127,0,0,1},
        6789,
    }, proc(request: ^Request, response: ^Response, event: ^ConnectionEvent) {
        fmt.println("Listeting to the connection", event.connection_number)
        defer write_response(response)

        error_event_listsner := EventListener(error_listener)
        add_event_listener(event, "error", &error_event_listsner)

        if request.endpoint == "/api/hello" {
        response.body = "Hello, world"
        response.headers.ContentType = ContentType{
            ContentTypeMain.Text,
            "html"
        }
            response.headers.AcceptEncoding = []Encoding{Encoding.Identity}
            return
        }

        if request.endpoint == "/server"  {
            interrupt_connection(event)
            return
        }

        response.status = status_404_NotFound()
        
    }, &event)

    if err != nil {
        fmt.println(err)
    }
}
