import Foundation
import Shell
import ShellTesting
import XCTest

@testable import Simulator

final class XcodeTests: XCTestCase {
    var subject: Xcode!
    var mockShell: MockShell!

    override func setUp() {
        super.setUp()
        mockShell = Shell.mock()
        shell = mockShell

        subject = Xcode(shell: shell)
    }

    func test_runtimeProfilesPath() throws {
        mockShell.stub(["/usr/bin/xcode-select", "-p"], stdout: ["/xcode"], stder: [], code: 0)
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
        mockShell.stub(["/usr/bin/xcode-select", "-p"], stdout: ["/xcode"], stder: [], code: 0)
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
