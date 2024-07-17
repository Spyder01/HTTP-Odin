package parsers

import "core:strconv"
import "core:strings"
import "core:bytes"
import "core:fmt"
import compress "../compress"

Request :: struct {
	method:         Method,
	endpoint:       string,
	protocol:       Protocol,
	headers:        Headers,
	custom_headers: map[string]string,
	body:           string,
}

parse_request :: proc(raw_request: string) -> (request: Request, error: Error = BasicError.None) {

	arr := strings.split_n(raw_request, "\r\n\r\n", 2)

	if len(arr) < 2 {
		error := ParseError{"Corrupted request packet. Unable to parse the headers and body."}
		return request, error
	}

	requests_and_headers := strings.split_n(arr[0], SEPERATOR, 2)

	if len(requests_and_headers) < 2 {
		error := ParseError{"Corrupted request packet. Unable to parse the headers and body."}
		return request, error
	}

	error = request_line_parser(requests_and_headers[0], &request)
	error = request_header_parser(requests_and_headers[1], &request)
	error = request_body_parser(arr[1], &request)

	return request, error
}


@(private = "file")
request_line_parser :: proc(
	request_line: string,
	request: ^Request,
) -> (
	error: Error = BasicError.None,
) {

	arr := strings.split(request_line, " ")

	if len(arr) < 3 {
		return ParseError{"Corrupted request line."}
	}

	switch arr[0] {
	case "GET":
		request.method = Method.GET
	case "POST":
		request.method = Method.POST
	case "PUT":
		request.method = Method.PUT
	case "PATCH":
		request.method = Method.PATCH
	case "DELETE":
		request.method = Method.DELETE
	case:
		return BasicError.UnknownMethod
	}

	request.endpoint = arr[1]

	switch strings.to_lower(arr[2]) {
	case "http/2":
		request.protocol = Protocol.HTTP2
	case:
		request.protocol = Protocol.HTTP1
	}


	return
}

@(private = "file")
request_header_parser :: proc(
	headers_raw: string,
	request: ^Request,
) -> (
	error: Error = BasicError.None,
) {
	headers_arr := strings.split(headers_raw, SEPERATOR)
    request.headers.AcceptEncoding = []Encoding{Encoding.Identity}
    request.headers.ContentEncoding = Encoding.Identity

	for header in headers_arr {
		header_pair := strings.split_n(header, ":", 2)

		value := strings.trim(header_pair[1], " ")
		key := strings.trim(strings.to_lower(header_pair[0]), " ")

		switch key {
		case "host":
			request.headers.Host = value
		case "content-type":
			error = parse_content_type(value, request)
		case "user-agent":
			request.headers.UserAgent = value
		case "accept":
			request.headers.Accept = value
		case "authorization":
			request.headers.Authorization = value
		case "content-length":
			val, converted := strconv.parse_int(value)
			if !converted {
				continue
			}

			request.headers.ContentLength = val
        case "content-encoding":
            request.headers.ContentEncoding = get_encoding(value)
        case "accept-encoding":
        encodings := [dynamic]Encoding{}

        for encoding in strings.split(value, ",") {
            append_elem(&encodings, get_encoding(encoding))
        }

        request.headers.AcceptEncoding = encodings[:]

		case:
			request.custom_headers[key] = value
		}
	}

	return
}

@(private="file")
get_encoding :: proc(val: string) -> Encoding {
    switch strings.to_lower(val) {
        case "gzip":
            return .GZIP
        case "*":
            return .Any
        case "identity":
            return .Identity
        case "compress":
            return .Compress
        case "br":
            return .Br
        case:
            return .Identity
    }
}

@(private = "file")
parse_content_type :: proc(val: string, request: ^Request) -> (error: Error = BasicError.None) {
	val_arr := strings.split_n(val, "/", 2)

	if len(val_arr) < 2 {
		return ParseError{"Error parsing the content-length"}
	}

	request.headers.ContentType.SubType = val_arr[1]

	type := strings.to_lower(strings.trim(val_arr[0], " "))

	switch type {
	case "image":
		request.headers.ContentType.Type = ContentTypeMain.Image
	case "font":
		request.headers.ContentType.Type = ContentTypeMain.Font
	case "multipart":
		request.headers.ContentType.Type = ContentTypeMain.Multipart
	case "video":
		request.headers.ContentType.Type = ContentTypeMain.Video
	case "application":
		request.headers.ContentType.Type = ContentTypeMain.Application
	case "text":
		request.headers.ContentType.Type = ContentTypeMain.Text
	case:
		return BasicError.UnsupportedContentType
	}

	return
}

@(private = "file")
request_body_parser :: proc(body: string, request: ^Request) -> (error: Error = BasicError.None) {

    switch request.headers.ContentEncoding {
        case .Identity:
            request.body = body
        
        case .GZIP:
			request.body = compress.decode_gzip(body)

		case .Compress:
			request.body = compress.decode_compress(body)
		
		case .Deflate:
			request.body = compress.decode_deflate(body)

		case .Br:
			request.body = compress.decode_br(body)
		
		case .Any:
			request.body = body

    }

	return
}
