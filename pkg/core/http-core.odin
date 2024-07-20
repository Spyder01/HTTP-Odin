package core

import "core:net"
import "core:strings"

import parsers "../parsers"

Options :: struct {
    port: int, 
    host: string
}



HandlerFunc :: proc (request: ^parsers.Request, response: ^parsers.Response, event: ^ConnectionEvent) 
OnServerStart :: proc()

connect :: proc (endpoint: net.Endpoint, handler: HandlerFunc, event: ^ConnectionEvent = nil)-> Error {
    socket := net.listen_tcp(endpoint) or_return
    defer net.close(socket)

    dispatch_event(event, "start")
    defer dispatch_event(event, "end")

    for !event.interrupt {
        event.connection_number += 1

        conn, _, err := net.accept_tcp(socket)

        if event == nil && err != nil {
            return err
        }

        if err != nil {
            register_error(event, err)
        }

        request := make([]byte, 1024)
        n, recv_err := net.recv_tcp(conn, request)

        if event == nil && recv_err != nil {
            return recv_err
        }

        if recv_err != nil {
            register_error(event, recv_err)
        }

        handler_err := handle_connection(conn, handler, string(request[:n]), endpoint, event)
        
        if event == nil && handler_err != nil {
            return handler_err
        }

        if handler_err != nil {
            register_error(event, recv_err)
        }
    }

    return nil
}

@(private="file")
handle_connection :: proc(conn: net.TCP_Socket, handler: HandlerFunc, request_data: string, endpoint: net.Endpoint, event: ^ConnectionEvent = nil)->Error {
    defer net.close(conn)

    request, err := parsers.parse_request(request_data)

    if err == parsers.BasicError.None {
        err = nil
    }

    if err != nil {
        return err
    }

    response := default_response_factory(endpoint)
    response.conn = conn

    handler(&request, &response, event)
    return nil
}

write_response :: proc(response: ^parsers.Response)->(error: Error = nil) {

    if response.headers.ContentLength != 0 {
        response.headers.ContentLength = len(response.body)
    }

    data := [dynamic]byte{}
    
    data_str := parsers.transpile_response(response)

    for char in data_str {
        append(&data, byte(char))
    }

     _ = net.send_tcp(response.conn, data[:]) or_return

     return
}

@(private="file")
default_response_factory :: proc(endpoint: net.Endpoint)->(response: parsers.Response) {

    response.status = parsers.status_200_OK()
    response.protocol = parsers.Protocol.HTTP1
    response.headers = default_response_header_factory(endpoint)

    return 
}

@(private="file")
default_response_header_factory :: proc(endpoint: net.Endpoint)->(header: parsers.Headers) {
    header.ContentEncoding = parsers.Encoding.Identity
    header.AcceptEncoding = []parsers.Encoding{parsers.Encoding.Identity}
    header.Host = net.endpoint_to_string(endpoint)

    header.ContentType = parsers.ContentType{
        parsers.ContentTypeMain.Text,
        "html"
    }


    return
}