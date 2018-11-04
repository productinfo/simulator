import Foundation
import XCTest

@testable import Simulator

final class RuntimeTests: XCTestCase {
    func test_list() throws {
        let got = try XCTTry(Runtime.list())
        XCTAssertNotEqual(got.count, 0)
    }

    func test_latest() throws {
        let got = try XCTTry(Runtime.latest(platform: .iOS))
        XCTAssertNotNil(got)
    }
}
