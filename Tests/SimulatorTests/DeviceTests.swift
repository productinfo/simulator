import Foundation
@testable import Simulator
import XCTest

final class DeviceTests: XCTestCase {
    var shell: MockShell!

    override func setUp() {
        super.setUp()
        shell = MockShell()
    }

    func test_deviceType() throws {
        let device = try iPhoneDevice()
        let deviceType = try device.deviceType()
        XCTAssertEqual(deviceType, "com.apple.CoreSimulator.SimDeviceType.iPhone-XR")
    }

    func test_globalPreferences() throws {
        let device = try iPhoneDevice()
        let globalPreferences = try device.globalPreferences()
        XCTAssertTrue(globalPreferences.keys.contains("AppleLocale"))
        XCTAssertTrue(globalPreferences.keys.contains("AppleLanguages"))
    }

    func test_plist() throws {
        let device = try iPhoneDevice()
        let plist = try device.plist()
        XCTAssertTrue(plist.keys.contains("deviceType"))
        XCTAssertTrue(plist.keys.contains("runtime"))
        XCTAssertTrue(plist.keys.contains("UDID"))
        XCTAssertTrue(plist.keys.contains("name"))
        XCTAssertTrue(plist.keys.contains("state"))
    }

    func test_runtimePath() throws {
        let device = try iPhoneDevice()
        XCTAssertNoThrow(try device.runtimePath())
    }

    func test_launchCtlPath() throws {
        let device = try iPhoneDevice()
        let path = try device.launchCtlPath()
        XCTAssertTrue(FileManager.default.fileExists(atPath: path.path))
    }

    func test_runtime() throws {
        let device = try iPhoneDevice()
        XCTAssertNoThrow(try device.runtime())
    }

    func test_services() throws {
        let device = try iPhoneDevice()
        let services = try device.services()
        try print(device.runtimePath())
        XCTAssertTrue(services.contains(where: { $0.label == "com.apple.storeagent.daemon" }))
        XCTAssertNotEqual(services.count, 0)
    }

    func test_globalPreferencesPlistPath() throws {
        let device = try iPhoneDevice()
        let got = device.globalPreferencesPlistPath()
        XCTAssertEqual(got, device.homePath().appendingPathComponent("data/Library/Preferences/.GlobalPreferences.plist"))
    }

    func test_devicePlistPath() throws {
        let device = try iPhoneDevice()
        let got = device.devicePlistPath()
        XCTAssertEqual(got, device.homePath().appendingPathComponent("device.plist"))
    }

    func test_homePath() throws {
        let device = try iPhoneDevice()
        XCTAssertEqual(device.homePath(), Device.devicesPath().appendingPathComponent(device.udid))
    }

    func test_list_returns_a_non_empty_list() throws {
        let got = try Device.list()
        XCTAssertNotEqual(got.count, 0)
    }
}
