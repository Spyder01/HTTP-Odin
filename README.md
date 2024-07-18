# HTTP-Odin

HTTP-Odin is a lightweight HTTP server library implemented in Odin.

## Features

- Simple HTTP server setup and request handling.
- Support for handling different HTTP methods and routing.
- Response generation with HTTP status codes and content types.

## Installation

Clone the repository:

```bash
git clone https://github.com/Spyder01/HTTP-Odin.git
```

## Usage

### Setting up the HTTP Server

```odin
import "core:net"
import "core:fmt"
import "core:strconv"
import "./pkg/parsers"

// Define HTTP handlers
listen_http(net.Endpoint{
    net.IP4_Address{127, 0, 0, 1},
    6789,
}, proc(request: ^Request, response: ^Response, connection_number: int) {
    fmt.println("Listening to connection", connection_number)
    defer write_response(response)

    // Example route handling
    if request.endpoint == "/api/hello" {
        response.body = "Hello, world"
        response.headers.ContentType = ContentType{
            ContentTypeMain.Text,
            "html",
        }
        response.headers.AcceptEncoding = []Encoding{Encoding.Identity}
        return
    }

    // Handle 404 Not Found
    response.status = status_404_NotFound()
}, proc(){
    fmt.println("Server started...")
})
```

### Creating HTTP Status Methods

The library provides convenience methods to create HTTP status codes and phrases:

- `status_200_OK(label: string = "OK") -> Status`: Generates HTTP 200 OK status.
- `status_201_Created(label: string = "Created") -> Status`: Generates HTTP 201 Created status.
- `status_400_BadRequest(label: string = "Bad Request") -> Status`: Generates HTTP 400 Bad Request status.
- `status_401_Unauthorized(label: string = "Unauthorized") -> Status`: Generates HTTP 401 Unauthorized status.
- `status_403_Forbidden(label: string = "Forbidden") -> Status`: Generates HTTP 403 Forbidden status.
- `status_404_NotFound(label: string = "Not Found") -> Status`: Generates HTTP 404 Not Found status.
- `status_500_InternalServerError(label: string = "Internal Server Error") -> Status`: Generates HTTP 500 Internal Server Error status.
- `status_502_BadGateway(label: string = "Bad Gateway") -> Status`: Generates HTTP 502 Bad Gateway status.
- `status_503_ServiceUnavailable(label: string = "Service Unavailable") -> Status`: Generates HTTP 503 Service Unavailable status.

#### Examples

```odin
// Example usage of HTTP status method creators
response.status = status_200_OK("Success")       // HTTP 200 OK with custom label
response.status = status_201_Created()           // HTTP 201 Created with default label
response.status = status_400_BadRequest("Invalid Request")  // HTTP 400 Bad Request with custom label
response.status = status_401_Unauthorized()      // HTTP 401 Unauthorized with default label
response.status = status_403_Forbidden()         // HTTP 403 Forbidden with default label
response.status = status_404_NotFound("Resource Not Found")  // HTTP 404 Not Found with custom label
response.status = status_500_InternalServerError()  // HTTP 500 Internal Server Error with default label
response.status = status_502_BadGateway()        // HTTP 502 Bad Gateway with default label
response.status = status_503_ServiceUnavailable("Maintenance Mode")  // HTTP 503 Service Unavailable with custom label
```

## API Reference

### Types

- `Response`: Represents an HTTP response.
- `Request`: Represents an HTTP request.
- `Status`: Defines HTTP status codes and phrases.
- `ContentType`: Represents the content type of the response.
- `HTTPMethod`: Defines HTTP methods like GET, POST, etc.
- `Encoding`: Represents content encodings like gzip, identity, etc.

### Functions

- `listen_http(endpoint: net.Endpoint, handler: HandlerFunc, connect_event: ^ConnectionEvent = nil) -> Error`: Starts listening on the specified endpoint and handles incoming requests.
- `write_response(response: ^Response) -> Error`: Writes the HTTP response back to the client.

## Imporvements
- Add support for conccurrent requests
- Add reactive pub-sub based error-handling, interrupts, and other events.
- Add http-client implementation.
- Performance optimization.

## Contributing

Contributions are welcome! Fork the repository and submit a pull request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

