package http

import "core:net"
import "core:fmt"
import "core:testing"
import "core:strconv"
import "./pkg/parsers"

// @(test)
main :: proc() {
    fmt.println("staring server")

    err := listen_http(net.Endpoint{
        net.IP4_Address{127,0,0,1},
        6789,
    }, proc(request: ^Request, response: ^Response, connection_number: int) {
        fmt.println("Listeting to the connection", connection_number)
        defer write_response(response)

        if request.endpoint == "/api/hello" {
        response.body = "Hello, world"
        response.headers.ContentType = ContentType{
            ContentTypeMain.Text,
            "html"
        }
            response.headers.AcceptEncoding = []Encoding{Encoding.Identity}
            return
        }

        response.status = status_404_NotFound()
        
    }, proc(){
        fmt.println("Server started..")
    })
}
