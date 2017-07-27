import XCTest
@testable import NicogramCore

class ArgumentTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }

    func testExtractVideId() {
        let url = "http://www.nicovideo.jp/watch/sm8628149"
        XCTAssertEqual(extractVideoId(url), "sm8628149")
    }

    func testParseArguments() {
        let arguments = ["Nicogram", "http://www.nicovideo.jp/watch/sm8628149", "--email", "xxxxx@sample.com", "--password", "ABC012"]
        let result = try! parseArguments(arguments)
        XCTAssertEqual(result.0, "xxxxx@sample.com")
        XCTAssertEqual(result.1, "ABC012")
        XCTAssertEqual(result.2, "http://www.nicovideo.jp/watch/sm8628149")
    }
}

extension ArgumentTests {
    static var allTests : [(String, (ArgumentTests) -> () throws -> Void)] {
        return [
            ("testExtractVideId", testExtractVideId),
            ("testParseArguments", testParseArguments)
        ]
    }
}