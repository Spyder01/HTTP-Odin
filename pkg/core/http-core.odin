package core

import "core:net"
import "core:strings"

import parsers "../parsers"

Options :: struct {
    port: int, 
    host: string
}

Error :: union {
    parsers.Error,
    parsers.ParseError,
    net.Network_Error,
}

ErrorRegistry :: struct {
    latest_error: Error,
    error_stack: []Error    
}

ConnectionEvent :: struct {
    error_registry: ^ErrorRegistry,
}

HandlerFunc :: proc (request: ^parsers.Request, response: ^parsers.Response, connection_number: int) 
OnServerStart :: proc()

connect :: proc (endpoint: net.Endpoint, handler: HandlerFunc, onServerStart: OnServerStart = proc(){}, connect_event: ^ConnectionEvent = nil)-> Error {
    socket := net.listen_tcp(endpoint) or_return
    defer net.close(socket)

    onServerStart()

    connection_number := 0
    for {
        connection_number += 1

        conn, _, err := net.accept_tcp(socket)

        if connect_event == nil && err != nil {
            return err
        }

        if err != nil {
            connect_event.error_registry.latest_error = err
            // Some error registry stuff
        }

        request := make([]byte, 1024)
        n, recv_err := net.recv_tcp(conn, request)

        if connect_event == nil && recv_err != nil {
            return recv_err
        }

        handler_err := handle_connection(conn, handler, string(request[:n]), endpoint, connection_number)
        
        if connect_event == nil && handler_err != nil {
            return handler_err
        }
    }

    return nil
}

@(private="file")
handle_connection :: proc(conn: net.TCP_Socket, handler: HandlerFunc, request_data: string, endpoint: net.Endpoint, connection_number: int)->Error {
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

    handler(&request, &response, connection_number)
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