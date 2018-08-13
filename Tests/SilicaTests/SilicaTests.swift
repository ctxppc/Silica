import XCTest
@testable import Silica

final class SilicaTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Silica().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
