

enum ServiceError: Error {
    case noConnection
    case timeOut
    case jsonParse
    case internalServerError
    case other
}
