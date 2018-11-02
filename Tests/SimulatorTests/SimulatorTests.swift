import Foundation
@testable import Simulator
import XCTest

final class SimCtlTests: XCTestCase {
    var subject: SimCtl!

    override func setUp() {
        super.setUp()
        subject = SimCtl()
    }

    func test_simctl() throws {
        let data = try subject.simctl("help")
        let output = String(data: data, encoding: .utf8) ?? ""
        XCTAssertTrue(output.contains("Command line utility to control the Simulator"))
    }
}
