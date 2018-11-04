import Foundation
import XCTest

extension XCTestCase {
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
