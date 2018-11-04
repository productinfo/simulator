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

    func test_runtimeProfilesPath() throws {
        shell.xcodePathStub = {
            .success("/xcode")
        }
        guard let got = subject.runtimeProfilesPath(platform: .iOS).single() else {
            XCTFail("Expected simulatorSDKPath to return a value")
            return
        }
        let value = try XCTTry(try got.dematerialize())
        XCTAssertEqual(value, URL(fileURLWithPath: "/xcode/Platforms/iPhoneOS.platform/Developer/Library/CoreSimulator/Profiles/Runtimes"))
    }

    func test_runtimeProfilesPath_when_platformHasNoSimulator() throws {
        guard let got = subject.runtimeProfilesPath(platform: .unknown).single() else {
            XCTFail("Expected simulatorSDKPath to return a value")
            return
        }
        let value = try XCTTry(try got.dematerialize())
        XCTAssertNil(value)
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
