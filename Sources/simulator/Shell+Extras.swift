import Foundation
import Shell
import Result

var shell = Shell()

extension Shell {
    /// Runs open with the given arguments.
    ///
    /// - Parameter arguments: Arguments to pass to open.
    /// - Throws: An error if the command cannot be launched.
    func open(_ arguments: [String]) throws {
        var arguments = arguments
        arguments.insert("/usr/bin/open", at: 0)

        try sync(arguments).dematerialize()
    }

    /// Returns the path to Xcode.
    ///
    /// - Returns: Xcode path.
    /// - Throws: A SimulatorError if Xcode can't be found in the system.
    func xcodePath() throws -> URL {
        let result = try capture(["/usr/bin/xcode-select", "-p"])
        let path = try result.dematerialize().chomp()
        return URL(fileURLWithPath: path, isDirectory: true)
    }

    /// Runs simctl and returns its output.
    ///
    /// - Parameter arguments: Arguments to pass to simctl.
    /// - Returns: The command output.
    /// - Throws: A SimulatorError if the command fails.
    func captureSimctl(_ arguments: [String]) throws -> String {
        var arguments = arguments
        arguments.insert(contentsOf: ["/usr/bin/xcrun", "simctl"], at: 0)
        return try capture(arguments).dematerialize().chomp()
    }

    /// Runs the simctl command.
    ///
    /// - Parameter arguments: Arguments to pass to simctl.
    /// - Throws: A SimulatorError if the command fails.
    func runSimctl(_ arguments: [String]) throws {
        var arguments = arguments
        arguments.insert(contentsOf: ["/usr/bin/xcrun", "simctl"], at: 0)

        try sync(arguments).dematerialize()
    }
}
