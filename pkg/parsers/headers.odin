package parsers

import "core:strings"
import "core:strconv"

@(private)
transpile_header :: proc(response: ^Response) -> string {
	headers := [dynamic]string{}

	parsed_headers := response.headers

	if parsed_headers.Host != "" {
		append(&headers, header_factory("Host", parsed_headers.Host), SEPERATOR)
	}

	if len(parsed_headers.AcceptEncoding) != 0 {
		accepted_encodings := [dynamic]string{}
		encodings := parsed_headers.AcceptEncoding

		for encoding in encodings {
			append(&accepted_encodings, transpile_encoding(encoding))
		}

		append(
			&headers,
			header_factory("Accepted-Encodings", strings.join(accepted_encodings[:], ",")),
			SEPERATOR,
		)
	}

	if parsed_headers.Authorization != "" {
		append(&headers, header_factory("Authorization", parsed_headers.Authorization), SEPERATOR)
	}

	if parsed_headers.ContentEncoding != nil {
		append(
			&headers,
			header_factory("Content-Encoding", transpile_encoding(parsed_headers.ContentEncoding)),
			SEPERATOR,
		)
	}

	append(
		&headers,
		header_factory("Content-Length", strconv.itoa([]byte{1,2,3}, parsed_headers.ContentLength)),
		SEPERATOR,
	)

	if parsed_headers.UserAgent != "" {
		append(&headers, header_factory("User-Agent", parsed_headers.UserAgent), SEPERATOR)
	}

	if parsed_headers.Server != "" {
		append(&headers, header_factory("Server", parsed_headers.Server), SEPERATOR)
	}

	append(&headers, header_factory("Content-Type", transpile_content_type(parsed_headers.ContentType)), SEPERATOR)

	custom_headers := response.custom_headers

	for key in custom_headers {
		append(&headers, header_factory(key, custom_headers[key]), SEPERATOR)
	}

	return strings.concatenate(headers[:])
}

transpile_encoding :: proc(encoding: Encoding) -> string {
	switch encoding {
	case .Any:
		return "*"
	case .Br:
		return "br"
	case .Compress:
		return "compress"
	case .Deflate:
		return "deflate"
	case .GZIP:
		return "gzip"
	case .Identity:
		return "identity"
	}

	return "identity"
}

@(private = "file")
header_factory :: proc(key: string, value: string) -> string {
	return strings.concatenate([]string{key, ":", value})
}

@(private = "file")
transpile_content_type :: proc(content_type: ContentType)->string {
	return strings.concatenate([]string{transpile_main_content_type(content_type.Type), "/", content_type.SubType})
}

@(private = "file")
transpile_main_content_type :: proc(main_type: ContentTypeMain)->string {
	switch main_type {
		case .Application:
			return "application"
		case .Audio:
			return "audio"
		case .Font:
			return "font"
		case .Image:
			return "image"
		case .Multipart:
			return "multipart"
		case .Text:
			return "text"
		case .Video:
			return "video"
	}

	return "text"
}