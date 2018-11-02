import Foundation
@testable import Simulator
import XCTest

final class DeviceTests: XCTestCase {
    var simctl: MockSimCtl!

    override func setUp() {
        super.setUp()
        simctl = MockSimCtl()
    }

    func test_list_returns_a_non_empty_list() throws {
        let got = try Device.list()
        XCTAssertNotEqual(got.count, 0)
    }

    func test_list_maps_the_devices() throws {
        simctl.stub("list", "-j", "devices", with: [
            "devices": [
                "iOS 12.1": [
                    [
                        "availability": "(unavailable, runtime profile not found)",
                        "state": "Shutdown",
                        "isAvailable": false,
                        "name": "iPhone 6 Plus",
                        "udid": "xxx",
                        "availabilityError": "runtime profile not found",
                    ],
                ],
            ],
        ])
        let got = try Device.list(simctl: simctl)
        XCTAssertEqual(got.count, 1)

        XCTAssertEqual(got.first?.availability, "(unavailable, runtime profile not found)")
        XCTAssertEqual(got.first?.state, "Shutdown")
        XCTAssertEqual(got.first?.isAvailable, false)
        XCTAssertEqual(got.first?.name, "iPhone 6 Plus")
        XCTAssertEqual(got.first?.udid, "xxx")
        XCTAssertEqual(got.first?.availabilityError, "runtime profile not found")
        XCTAssertEqual(got.first?.runtimeName, "iOS 12.1")
    }
}
