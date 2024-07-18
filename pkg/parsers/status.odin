package parsers

Status :: struct {
	reason_phrase: string,
	code:          int,
	label:         string,
}

// Function to generate HTTP status for 200 OK
status_200_OK :: proc(label: string = "Success") -> Status {
	return Status{label, 200, "OK"}
}

// Function to generate HTTP status for 201 Created
status_201_Created :: proc(label: string = "Resource Created") -> Status {
	return Status{label, 201, "Created"}
}

// Function to generate HTTP status for 400 Bad Request
status_400_BadRequest :: proc(label: string = "Bad Request") -> Status {
	return Status{label, 400, "Bad Request"}
}

// Function to generate HTTP status for 401 Unauthorized
status_401_Unauthorized :: proc(label: string = "Unauthorized") -> Status {
	return Status{label, 401, "Unauthorized"}
}

// Function to generate HTTP status for 403 Forbidden
status_403_Forbidden :: proc(label: string = "Forbidden") -> Status {
	return Status{label, 403, "Forbidden"}
}

// Function to generate HTTP status for 404 Not Found
status_404_NotFound :: proc(label: string = "Not Found") -> Status {
	return Status{label, 404, "Not Found"}
}

// Function to generate HTTP status for 500 Internal Server Error
status_500_InternalServerError :: proc(label: string = "Internal Server Error") -> Status {
	return Status{label, 500, "Internal Server Error"}
}

// Function to generate HTTP status for 502 Bad Gateway
status_502_BadGateway :: proc(label: string = "Bad Gateway") -> Status {
	return Status{label, 502, "Bad Gateway"}
}

// Function to generate HTTP status for 503 Service Unavailable
status_503_ServiceUnavailable :: proc(label: string = "Service Unavailable") -> Status {
	return Status{label, 503, "Service Unavailable"}
}