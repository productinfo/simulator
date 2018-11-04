import Foundation
import XCTest

@testable import Simulator

final class RuntimeTests: XCTestCase {
    func test_list() {
        let got = Runtime.Reactive.list().single()?.value ?? []
        XCTAssertNotEqual(got.count, 0)
    }
}
