import Foundation
import ReactiveTask

/// Protocol that defines the interface of an entity that runs simctl commands.
protocol SimCtling {
    /// Runs simctl with the given arguments.
    ///
    /// - Parameter arguments: Arguments to be passed to simctl.
    /// - Returns: The output from the command.
    /// - Throws: A SimCtlError if the execution fails.
    func simctl(_ arguments: String...) throws -> String
}

/// Error that can be thrown when running the simctl command.
///
/// - noResult: Thrown when the command doesn't output anything.
/// - invalidOutputFormat: Thrown when the output doesn't have the expected .utf8 format.
enum SimCtlError: Error {
    case noResult
    case invalidOutputFormat
}

/// Struct that conforms the SimCtling providing a default implementation.
struct SimCtl: SimCtling {
    /// Runs simctl with the given arguments.
    ///
    /// - Parameter arguments: Arguments to be passed to simctl.
    /// - Returns: The output from the command.
    /// - Throws: A SimCtlError if the execution fails.
    func simctl(_ arguments: String...) throws -> String {
        var arguments = arguments
        arguments.insert("simctl", at: 0)

        let task = Task("/usr/bin/xcrun", arguments: arguments).launch()

        guard let output = task.ignoreTaskData().single() else {
            throw SimCtlError.noResult
        }
        switch output {
        case let .failure(error):
            throw error
        case let .success(value):
            guard let outputString = String(data: value, encoding: .utf8) else {
                throw SimCtlError.invalidOutputFormat
            }
            return outputString
        }
    }
}
