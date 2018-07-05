

import Foundation

final class InternetConnectionHandler {

    func verifyConnection(_ error: Error) -> Error {
        guard let urlError = error as? URLError else { return ServiceError.other }

        if urlError.code == .notConnectedToInternet {
            return ServiceError.noConnection
        }
        if urlError.code == .timedOut {
            return ServiceError.timeOut
        } else {
            return ServiceError.other
        }
    }
}
