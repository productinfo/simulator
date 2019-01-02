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

    override func tearDown() {
        super.tearDown()
        shell = Shell()
    }

    func test_runtimeProfilesPath() {
        mockShell.stub(["/usr/bin/xcode-select", "-p"], stdout: ["/xcode"], stder: [], code: 0)
        let got = subject.runtimeProfilesPath(platform: .iOS)
        XCTAssertEqual(got.value, URL(fileURLWithPath: "/xcode/Platforms/iPhoneOS.platform/Developer/Library/CoreSimulator/Profiles/Runtimes"))
    }

    func test_runtimeProfilesPath_when_platformHasNoSimulator() {
        let got = subject.runtimeProfilesPath(platform: .unknown)
        XCTAssertNil(got.value ?? nil)
    }

    func test_simulatorSDKPath() {
        mockShell.stub(["/usr/bin/xcode-select", "-p"], stdout: ["/xcode"], stder: [], code: 0)
        let got = subject.simulatorSDKPath(platform: .iOS)
        XCTAssertEqual(got.value, URL(fileURLWithPath: "/xcode/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk"))
    }

    func test_simulatorSDKPath_when_platformHasNoSimulators() {
        let got = subject.simulatorSDKPath(platform: .unknown)
        XCTAssertNil(got.value ?? nil)
    }

    func test_devicePlatform() {
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
