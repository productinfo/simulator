import Foundation
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

    func test_runtimeProfilesPath() throws {
        shell.xcodePathStub = { "/xcode" }
        guard let got = try subject.runtimeProfilesPath(platform: .iOS) else {
            XCTFail("Expected simulatorSDKPath to return a value")
            return
        }
        XCTAssertEqual(got, URL(fileURLWithPath: "/xcode/Platforms/iPhoneOS.platform/Developer/Library/CoreSimulator/Profiles/Runtimes"))
    }

    func test_runtimeProfilesPath_when_platformHasNoSimulator() throws {
        XCTAssertNil(try subject.runtimeProfilesPath(platform: .unknown))
    }

    func test_simulatorSDKPath() throws {
        shell.xcodePathStub = { "/xcode" }
        guard let got = try subject.simulatorSDKPath(platform: .iOS) else {
            XCTFail("Expected simulatorSDKPath to return a value")
            return
        }
        XCTAssertEqual(got, URL(fileURLWithPath: "/xcode/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk"))
    }

    func test_simulatorSDKPath_when_platformHasNoSimulators() throws {
        XCTAssertNil(try subject.simulatorSDKPath(platform: .unknown))
    }

    func test_devicePlatform() throws {
        XCTAssertEqual(subject.devicePlatform(platform: .iOS), "iPhoneOS")
        XCTAssertEqual(subject.devicePlatform(platform: .watchOS), "WatchOS")
        XCTAssertEqual(subject.devicePlatform(platform: .tvOS), "AppleTVOS")
    }

    func test_simulatorPlatform() {
        XCTAssertEqual(subject.simulatorPlatform(platform: .iOS), "iPhoneSimulator")
        XCTAssertEqual(subject.simulatorPlatform(platform: .watchOS), "WatchSimulator")
        XCTAssertEqual(subject.simulatorPlatform(platform: .tvOS), "AppleTVSimulator")
    }
}
