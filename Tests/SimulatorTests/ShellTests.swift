import Foundation
@testable import Simulator
import XCTest

final class ShellTests: XCTestCase {
    var subject: Shell!

    override func setUp() {
        super.setUp()
        subject = Shell()
    }

    func test_simctl() throws {
        let data = subject.simctl(["help"]).ignoreTaskData().single()?.value ?? Data()
        let output = String(data: data, encoding: .utf8) ?? ""
        XCTAssertTrue(output.contains("Command line utility to control the Simulator"))
    }
}
