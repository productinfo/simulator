import Foundation
@testable import Simulator
import XCTest

extension XCTestCase {
    /// Returns an iPhone device from the system to be used from the tests.
    ///
    /// - Returns: Device instance from the system.
    /// - Throws: An error if simctl errors or the iPhone device can't be found.
    func iPhoneDevice(type: String = "iPhone XR") throws -> Device {
        guard let device = try Device.list().first(where: { $0.name == type && $0.isAvailable == true }) else {
            throw AnyError(description: "Couldn't find a valid iPhone")
        }
        return device
    }

    /// Tries to run the closure and if it throws, it prints and re-throws the error.
    ///
    /// - Parameter closure: Closure to be run.
    /// - Throws: If the given closure throws.
    func XCTTry(_ closure: @autoclosure () throws -> Void) throws {
        do {
            try closure()
        } catch {
            print(error)
            throw error
        }
    }

    /// Tries to run the closure and if it throws, it prints and re-throws the error.
    ///
    /// - Parameter closure: Closure to be run.
    /// - Returns: The value returned by the closure.
    /// - Throws: If the given closure throws.
    func XCTTry<T>(_ closure: @autoclosure () throws -> T) throws -> T {
        do {
            return try closure()
        } catch {
            print(error)
            throw error
        }
    }
}
