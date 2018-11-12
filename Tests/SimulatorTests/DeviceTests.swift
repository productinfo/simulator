import Foundation
@testable import Simulator
import XCTest

final class DeviceTests: XCTestCase {
    var shell: MockShell!
    var device = Device(availability: "available",
                        state: "booted",
                        isAvailable: true,
                        name: "Best Device",
                        udid: "744bf402-280f-45cc-899b-1255cbb833bf",
                        availabilityError: nil,
                        runtimeName: "Best Runtime")

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
    
    func testLaunch() throws {
        Device.shell = shell
        
        let xcodePath = "/xcode/path"
        shell.xcodePathStub = {
            return xcodePath
        }
        
        shell.openStub = { (arguments: [String]) in
            XCTAssertEqual(arguments, ["-Fgn", "/xcode/path/Applications/Simulator.app", "-CurrentDeviceUDID", self.device.udid])
        }
        
        try device.launch()
        Device.shell = Shell.shared
    }
    
    func testLaunchApp() throws {
        Device.shell = shell
        let bundleId = "best.app.ever"
        
        shell.xcrunStub = { (arguments: [String]) -> ShellOutput  in
            XCTAssertEqual(arguments, ["launch", self.device.udid, bundleId])
            return ShellOutput()
        }
        
        try device.launchApp(bundleId)
        Device.shell = Shell.shared
    }
}
