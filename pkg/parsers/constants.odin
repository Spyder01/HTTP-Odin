package parsers


ParseError :: struct {
    message: string,
}

BasicError :: enum {
    None,
    UnknownMethod,
    UnsupportedContentType
}


Error :: union{
    ParseError,
    BasicError
}

@(private)
SEPERATOR :: "\r\n"

ContentTypeMain :: enum {
    Text,
    Image,
    Application,
    Multipart,
    Audio,
    Video,
    Font,
}

ContentType :: struct {
    Type: ContentTypeMain,
    SubType: string,
}

Encoding :: enum{
    GZIP,
    Compress,
    Deflate,
    Br,
    Identity,
    Any,
}

Headers :: struct {
    ContentType: ContentType,
    Host: string,
    UserAgent: string,
    Accept: string,
    Authorization: string,
    ContentLength: int,
    AcceptEncoding: []Encoding,
    ContentEncoding: Encoding,
    Server: string,
}

Method :: enum {
    GET,
    POST,
    PUT,
    PATCH,
    DELETE
}

Protocol :: enum {
    HTTP1,
    HTTP2,
}
