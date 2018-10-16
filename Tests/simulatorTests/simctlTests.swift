import Foundation
@testable import simulator
import XCTest

final class SimCtlTests: XCTestCase {
    var subject: SimCtl!

    override func setUp() {
        super.setUp()
        subject = SimCtl()
    }

    func test_simctl() throws {
        let got = try subject.simctl("help")
        XCTAssertTrue(got.contains("Command line utility to control the Simulator"))
    }
}
