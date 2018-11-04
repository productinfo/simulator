import Foundation
import Result
@testable import Simulator
import XCTest

final class XcodeTests: XCTestCase {
    var shell: MockShell!
    var subject: Xcode!

    override func setUp() {
        super.setUp()
        shell = MockShell()
        subject = Xcode(shell: shell)
    }

    func test_simulatorSDKPath() throws {
        shell.xcodePathStub = {
            .success("/xcode")
        }
        guard let got = subject.simulatorSDKPath(platform: .iOS).single() else {
            XCTFail("Expected simulatorSDKPath to return a value")
            return
        }
        let value = try XCTTry(try got.dematerialize())
        XCTAssertEqual(value, URL(fileURLWithPath: "/xcode/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk"))
    }

    func test_simulatorSDKPath_when_platformHasNoSimulators() throws {
        guard let got = subject.simulatorSDKPath(platform: .unknown).single() else {
            XCTFail("Expected simulatorSDKPath to return a value")
            return
        }
        let value = try XCTTry(try got.dematerialize())
        XCTAssertNil(value)
    }

    func test_simulator() {
        XCTAssertEqual(subject.simulator(platform: .iOS), "iPhoneSimulator")
        XCTAssertEqual(subject.simulator(platform: .watchOS), "WatchSimulator")
        XCTAssertEqual(subject.simulator(platform: .tvOS), "AppleTVSimulator")
    }
}
