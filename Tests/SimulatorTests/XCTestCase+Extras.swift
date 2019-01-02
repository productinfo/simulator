import Foundation
import Result
@testable import Simulator
import XCTest

extension XCTestCase {
    func iPhoneDevice(type: String = "iPhone XR") -> Result<Device, AnyError> {
        return Device.list().mapError({ AnyError(description: $0.description) }).flatMap({ (devices) -> Result<Device, AnyError> in
            guard let device = devices.first(where: { $0.name == type && $0.isAvailable == true }) else {
                return .failure(AnyError(description: "Couldn't obtain device of type \(type)"))
            }
            return .success(device)
        })
    }
}
