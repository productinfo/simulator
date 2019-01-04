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

    func test_runtimePlatform() {
        let device = iPhoneDevice()
        XCTAssertEqual(device.value?.runtimePlatform().value, .iOS)
    }

    func test_deviceType() {
        let device = iPhoneDevice()
        let deviceType = device.value?.deviceType()
        XCTAssertEqual(deviceType?.value, "com.apple.CoreSimulator.SimDeviceType.iPhone-XR")
    }

    func test_globalPreferences() {
        let device = iPhoneDevice()
        let globalPreferences = device.value?.globalPreferences().value
        XCTAssertEqual(globalPreferences?.keys.contains("AppleLocale"), true)
        XCTAssertEqual(globalPreferences?.keys.contains("AppleLanguages"), true)
    }

    func test_plist() {
        let device = iPhoneDevice()
        let plist = device.value?.plist().value
        XCTAssertEqual(plist?.keys.contains("deviceType"), true)
        XCTAssertEqual(plist?.keys.contains("runtime"), true)
        XCTAssertEqual(plist?.keys.contains("UDID"), true)
        XCTAssertEqual(plist?.keys.contains("name"), true)
        XCTAssertEqual(plist?.keys.contains("state"), true)
    }

    func test_runtimePath() {
        let device = iPhoneDevice().value
        XCTAssertNil(device?.runtimePath().error)
    }

    func test_launchCtlPath() {
        let device = iPhoneDevice().value
        guard let path = device?.launchCtlPath().value?.path else {
            XCTFail("Could not obtain launchctl path")
            return
        }
        XCTAssertTrue(FileManager.default.fileExists(atPath: path))
    }

    func test_runtime() {
        let device = iPhoneDevice().value
        XCTAssertNil(device?.runtime().error)
    }

    func test_services() {
        let device = iPhoneDevice().value
        let services = device?.services().value
        XCTAssertEqual(services?.contains(where: { $0.label == "com.apple.storeagent.daemon" }), true)
        XCTAssertNotEqual(services?.count, 0)
    }

    func test_globalPreferencesPlistPath() {
        let device = iPhoneDevice().value
        let got = device?.globalPreferencesPlistPath()
        XCTAssertEqual(got, device?.homePath().appendingPathComponent("data/Library/Preferences/.GlobalPreferences.plist"))
    }

    func test_devicePlistPath() {
        let device = iPhoneDevice().value
        let got = device?.devicePlistPath()
        XCTAssertEqual(got, device?.homePath().appendingPathComponent("device.plist"))
    }

    func test_homePath() {
        let device = iPhoneDevice().value
        XCTAssertNotNil(device)
        XCTAssertEqual(device?.homePath(), Device.devicesPath().appendingPathComponent(device!.udid))
    }

    func test_list_returns_a_non_empty_list() {
        let got = Device.list().value
        XCTAssertNotEqual(got?.count, 0)
    }

    func testLaunch() {
        mockShellInstance()
        mockShell.stub(["/usr/bin/xcode-select", "-p"], stdout: ["/xcode/path"], stder: [], code: 0)
        mockShell.succeed(["/usr/bin/open", "-Fgn", "/xcode/path/Applications/Simulator.app", "--args", "-CurrentDeviceUDID", self.device.udid])

        XCTAssertNil(device.launch().error)
    }

    func testLaunchApp() {
        mockShellInstance()
        let bundleId = "best.app.ever"
        mockShell.stub(["/usr/bin/xcrun", "simctl", "launch", self.device.udid, bundleId], stdout: ["/xcode/path"], stder: [], code: 0)
        XCTAssertNil(device.launchApp(bundleId).error)
    }

    func test_wait() {
        var device = iPhoneDevice().value
        if device?.isBooted == true {
            _ = device?.kill()
        }
        _ = device?.launch()
        let got = device?.wait(until: { $0.isBooted })
        XCTAssertNil(got?.error)
    }

    private func mockShellInstance() {
        mockShell = Shell.mock()
        shell = mockShell
    }
}
