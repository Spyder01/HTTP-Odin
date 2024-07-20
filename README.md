# HTTP-Odin

HTTP-Odin is a lightweight HTTP server library implemented in Odin.

## Features

- Simple HTTP server setup and request handling.
- Support for handling different HTTP methods and routing.
- Response generation with HTTP status codes and content types.
- Connection event handling including start, end, error events, and custom events.

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

- **`Response`**: Represents an HTTP response.
    ```odin
    Response :: struct {
        status:         Status,
        headers:        Headers,
        custom_headers: map[string]string,
        protocol:       Protocol,
        body:           string,
        conn:           net.TCP_Socket,
    }
    ```
    - **`status`**: The HTTP status code for the response (e.g., 200 OK).
    - **`headers`**: Standard headers included in the response.
    - **`custom_headers`**: Additional custom headers.
    - **`protocol`**: The HTTP protocol version used.
    - **`body`**: The body content of the response.
    - **`conn`**: The TCP socket connection used for sending the response.

- **`Request`**: Represents an HTTP request.
    ```odin
    Request :: struct {
        method:         Method,
        endpoint:       string,
        protocol:       Protocol,
        headers:        Headers,
        custom_headers: map[string]string,
        body:           string,
    }
    ```
    - **`method`**: The HTTP method used (e.g., GET, POST).
    - **`endpoint`**: The request endpoint (e.g., `/api/hello`).
    - **`protocol`**: The HTTP protocol version used.
    - **`headers`**: Standard headers included in the request.
    - **`custom_headers`**: Additional custom headers.
    - **`body`**: The body of the request.

- **`Status`**: Defines HTTP status codes and phrases.
- **`ContentType`**: Represents the content type of the response.
- **`HTTPMethod`**: Defines HTTP methods like GET, POST, etc.
- **`Encoding`**: Represents content encodings like gzip, identity, etc.
- **`ConnectionEvent`**: Represents events related to a connection.
    ```odin
    ConnectionEvent :: struct {
        interrupt: bool,
        connection_number: int,
        error_registry: ^ErrorRegistry,
        listeners: map[string][dynamic]^Listener,
    }
    ```

### Functions

- **`listen_http(endpoint: net.Endpoint, handler: HandlerFunc, connect_event: ^ConnectionEvent = nil) -> Error`**: Starts listening on the specified endpoint and handles incoming requests.
- **`write_response(response: ^Response) -> Error`**: Writes the HTTP response back to the client.

### Connection Event Methods

- **`dispatch_event(event: ^ConnectionEvent, event_name: string) -> int`**: Dispatches an event to all registered listeners.
- **`add_event_listener(event: ^ConnectionEvent, event_name: string, listener: ^Listener)`**: Adds an event listener for a specific event name.
- **`register_error(event: ^ConnectionEvent, err: Error)`**: Registers an error and triggers the error event.
- **`default_connection_event() -> ConnectionEvent`**: Creates a default `ConnectionEvent` with initial settings.
- **`interrupt_connection(event: ^ConnectionEvent)`**: Sets the `interrupt` flag in the `ConnectionEvent` to true, stopping further processing.

### Event Types

- **`"start"` Event**: Triggered when the server starts. Useful for logging and initialization tasks.
- **`"end"` Event**: Triggered when the server stops. Useful for cleanup tasks and logging.
- **`"error"` Event**: Triggered when an error occurs. Useful for error handling and logging.
- **Custom Events**: You can define and dispatch your own custom events. To use custom events:
    - Use `add_event_listener(event, "custom_event_name", &custom_event_listener)` to add a listener for your custom event.
    - Use `dispatch_event(event, "custom_event_name")` to trigger your custom event.

#### Example Usage

```odin
import "core:fmt"
import "./pkg/core"

// Custom event listener
custom_event_listener :: proc(event: ^ConnectionEvent) {
    fmt.println("Custom event triggered with connection number", event.connection_number)
}

// Error listener
error_listener :: proc(event: ^ConnectionEvent) {
    fmt.eprintln(event.error_registry.latest_error)
}

// Server start listener
on_server_start :: proc(event: ^ConnectionEvent) {
    fmt.println("Server starting...")
}

// Server end listener
on_server_end :: proc(event: ^ConnectionEvent) {
    fmt.println("Server ending...")
}

main :: proc() {
    event := default_connection_event()

    on_server_start_event := EventListener(on_server_start)
    on_server_end_event := EventListener(on_server_end)
    custom_event_listener := EventListener(custom_event_listener)
    add_event_listener(&event, "start", &on_server_start_event)
    add_event_listener(&event, "end", &on_server_end_event)
    add_event_listener(&event, "custom_event", &custom_event_listener)

    fmt.println("Starting server...")

    err := listen_http(net.Endpoint{
        net.IP4_Address{127, 0, 0, 1},
        6789,
    }, proc(request: ^Request, response: ^Response, event: ^ConnectionEvent) {
        fmt.println("Listening to connection", event.connection_number)
        defer write_response(response)

        error_event_listener := EventListener(error_listener)
        add_event_listener(event, "error", &error_event_listener)

        // Example of triggering a custom event
        dispatch_event(event, "custom_event")

        if request.endpoint == "/api/hello" {
            response.body = "Hello, world"
            response.headers.ContentType = ContentType{
                ContentTypeMain.Text,
                "html",
            }
            response.headers.AcceptEncoding = []Encoding{Encoding.Identity}
            return
        }

        if request.endpoint == "/server" {
            interrupt_connection(event)
            return
        }

        response.status = status_404_NotFound()
    }, &event)

    if err != nil {
        fmt.println(err)
    }
}
```

## Improvements

- Add support for concurrent requests.
- Implement an HTTP client.
- Optimize performance.
- Add test cases and more examples.

## Contributing

Contributions are welcome! Fork the repository and submit a pull request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
