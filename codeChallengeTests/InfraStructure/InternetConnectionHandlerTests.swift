

@testable import codeChallenge
import XCTest

final class InternetConnectionHandlerTests: XCTestCase {
    
    private var internetConnectionHandler: InternetConnectionHandler!
    private func verifyConnectionMock(_ error: URLError.Code) -> Error {
        if error == .notConnectedToInternet {
            return ServiceError.noConnection
        }
        if error == .timedOut {
            return ServiceError.timeOut
        } else {
            return ServiceError.other
        }
    }
    
    private func verifyError(_ error: URLError.Code, equalTo expectedError: ServiceError) {
        let result = verifyConnectionMock(error) as? ServiceError
        XCTAssertEqual(result, expectedError)
    }
    
    override func setUp() {
        super.setUp()
        self.internetConnectionHandler = InternetConnectionHandler()
    }
    
    override func tearDown() {
        self.internetConnectionHandler = nil
        super.tearDown()
    }
    
    func test_shouldReturn_notConnectedError_when_hasNoConnection() {
        let notConnected = URLError.notConnectedToInternet
        verifyError(notConnected, equalTo: .noConnection)
    }
    
    func test_shouldReturn_timeOutError_when_timedOut() {
        let timedOut = URLError.timedOut
        verifyError(timedOut, equalTo: .timeOut)
    }
    
    func test_shouldReturn_otherError_when_error() {
        let unknown = URLError.unknown
        verifyError(unknown, equalTo: .other)
    }
}
