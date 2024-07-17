package http

import "core:net"
import "core:fmt"
import "core:testing"

// @(test)
main :: proc() {
    fmt.println("staring server")

    err := listen_http(net.Endpoint{
        net.IP4_Address{127,0,0,1},
        6789,
    }, proc(request: ^Request, response: ^Response) {
        fmt.println("Listeting to the server")
        write_response(response)
    })

    fmt.println("ERROROROROROROROROR", err)
    // assert(err == nil)
}