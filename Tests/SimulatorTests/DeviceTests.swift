import Foundation
import Shell
import ShellTesting
import XCTest

@testable import Simulator

final class DeviceTests: XCTestCase {
    var mockShell: MockShell!

    var device = Device(availability: "available",
                        state: "booted",
                        isAvailable: true,
                        name: "Best Device",
                        udid: "744bf402-280f-45cc-899b-1255cbb833bf",
                        availabilityError: nil,
                        runtimeName: "Best Runtime")

    override func tearDown() {
        super.tearDown()
        shell = Shell()
    }

    func test_runtimePlatform() throws {
        let device = try iPhoneDevice()
        XCTAssertEqual(try device.runtimePlatform(), .iOS)
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

    func testLaunch() throws {
        mockShellInstance()
        mockShell.stub(["/usr/bin/xcode-select", "-p"], stdout: ["/xcode/path"], stder: [], code: 0)
        mockShell.succeed(["/usr/bin/open", "-Fgn", "/xcode/path/Applications/Simulator.app", "--args", "-CurrentDeviceUDID", self.device.udid])

        try device.launch()
    }

    func testLaunchApp() throws {
        mockShellInstance()
        let bundleId = "best.app.ever"
        mockShell.stub(["/usr/bin/xcrun", "simctl", "launch", self.device.udid, bundleId], stdout: ["/xcode/path"], stder: [], code: 0)
        try device.launchApp(bundleId)
    }

    func test_wait() throws {
        var device = try iPhoneDevice()
        if device.isBooted {
            _ = try device.kill()
        }
        try device.launch()
        try device.wait(until: { $0.isBooted })
    }

    private func mockShellInstance() {
        mockShell = Shell.mock()
        shell = mockShell
    }
}
