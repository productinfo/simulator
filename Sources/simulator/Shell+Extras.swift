import Foundation
import Result
import Shell

var shell = Shell()

extension Shell {
    /// Runs open with the given arguments.
    ///
    /// - Parameter arguments: Arguments to pass to open.
    /// - Returns: A result with a simulator error
    func open(_ arguments: [String]) -> Result<Void, SimulatorError> {
        var arguments = arguments
        arguments.insert("/usr/bin/open", at: 0)
        return sync(arguments).mapError(SimulatorError.shell)
    }

    /// Get the path to Xcode.
    ///
    /// - Returns: Xcode path or a simulator error.
    func xcodePath() -> Result<URL, SimulatorError> {
        let result = capture(["/usr/bin/xcode-select", "-p"])
        return result.map({ URL(fileURLWithPath: $0.chomp(), isDirectory: true) }).mapError(SimulatorError.shell)
    }

    /// Runs simctl and returns its output.
    ///
    /// - Parameter arguments: Arguments to pass to simctl.
    /// - Returns: The command output as a string or a simulator error.
    func captureSimctl(_ arguments: [String]) -> Result<String, SimulatorError> {
        var arguments = arguments
        arguments.insert(contentsOf: ["/usr/bin/xcrun", "simctl"], at: 0)
        return capture(arguments).map({ $0.chomp() }).mapError(SimulatorError.shell)
    }

    /// Runs the simctl command.
    ///
    /// - Parameter arguments: Arguments to pass to simctl.
    /// - Returns: The command result.
    func runSimctl(_ arguments: [String]) -> Result<Void, SimulatorError> {
        var arguments = arguments
        arguments.insert(contentsOf: ["/usr/bin/xcrun", "simctl"], at: 0)

        return sync(arguments).mapError(SimulatorError.shell)
    }
}
