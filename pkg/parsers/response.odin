package parsers

import compress "../compress"
import "core:net"
import "core:strconv"
import "core:strings"

Response :: struct {
	status:         Status,
	headers:        Headers,
	custom_headers: map[string]string,
	protocol:       Protocol,
	body:           string,
	conn:           net.TCP_Socket,
}

@(private = "file")
transpiler_status :: proc(response: ^Response) -> string {
	buffer: []byte = []byte{0, 0, 0}
	status := response.status
	str := strings.concatenate(
		[]string {
			strconv.itoa(buffer, status.code),
			" ",
			status.label,
			" (",
			status.reason_phrase,
			")",
		},
	)

	return str
}

@(private)
transpile_protocol :: proc(response: ^Response) -> string {
	switch response.protocol {
	case .HTTP1:
		return "HTTP/1.1"
	case .HTTP2:
		return "HTTP/2"
	}

	return "HTTP/1.1"
}


@(private = "file")
transpile_body :: proc(resposne: ^Response) -> string {
	body := encode_content(resposne)

	resposne.headers.ContentLength = len(body)
	return body
}

@(private = "file")
encode_content :: proc(response: ^Response) -> string {
	body := response.body

	switch response.headers.ContentEncoding {
	case .Any:
		return body
	case .Identity:
		return body

	case .Br:
		return compress.encode_br(body)

	case .Compress:
		return compress.encode_compress(body)

	case .Deflate:
		return compress.encode_deflate(body)

	case .GZIP:
		return compress.encode_gzip(body)
	}

	return body
}

transpile_response :: proc(response: ^Response) -> string {

	body := transpile_body(response)
	data := strings.concatenate(
		[]string {
			transpile_protocol(response),
			" ",
			transpiler_status(response),
			SEPERATOR,
			transpile_header(response),
			SEPERATOR,
			body,
		},
	)

	return data
}
