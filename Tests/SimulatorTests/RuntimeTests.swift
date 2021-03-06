import Foundation
import XCTest

@testable import Simulator

final class RuntimeTests: XCTestCase {
    func test_list() {
        let got = Runtime.list().value
        XCTAssertNotEqual(got?.count, 0)
    }

    func test_latest() {
        let got = Runtime.latest(platform: .iOS).value
        XCTAssertNotNil(got ?? nil)
    }
}
