import Foundation
import ReactiveTask

/// Protocol that defines the interface of an entity that runs shell commands.
protocol Shelling {
    /// Runs simctl with the given arguments.
    ///
    /// - Parameter arguments: Arguments to be passed to simctl.
    /// - Returns: The output from the command.
    /// - Throws: A SimCtlError if the execution fails.
    func simctl(_ arguments: String...) throws -> Data
}

/// Error that can be thrown when running the simctl command.
///
/// - noResult: Thrown when the command doesn't output anything.
/// - invalidOutputFormat: Thrown when the output doesn't have the expected .utf8 format.
enum SimCtlError: Error {
    case noResult
}

/// Struct that conforms the Shelling providing a default implementation.
struct Shell: Shelling {
    /// Shared instance of Shell.
    public static let shared: Shelling = Shell()

    /// Runs simctl with the given arguments.
    ///
    /// - Parameter arguments: Arguments to be passed to simctl.
    /// - Returns: The output from the command.
    /// - Throws: A SimCtlError if the execution fails.
    func simctl(_ arguments: String...) throws -> Data {
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
            return value
        }
    }
}
