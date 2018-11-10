import Foundation
import SwiftShell

/// This structs wraps the SwiftShell RunOutput to facilitate testing.
/// The RunOutput doesn't provide any initializer that that initializes the result with its properties.
public struct ShellOutput {
    /// Standard output string.
    let stdout: String

    /// Standard error string.
    let stderror: String

    /// Command exit code.
    let exitcode: Int

    /// True if the command succeeded.
    let succeeded: Bool

    /// Command error.
    let error: Error?

    /// Initializes the shell output with the SwiftShell RunOutput
    ///
    /// - Parameter output: Output from running a shell command.
    init(_ output: RunOutput) {
        stdout = output.stdout
        stderror = output.stderror
        exitcode = output.exitcode
        succeeded = output.succeeded
        error = output.error
    }

    /// Initializes the ShellOutput with its attributes.
    ///
    /// - Parameters:
    ///   - stdout: Standard output string.
    ///   - stderror: Standard error string.
    ///   - exitcode: Command exit code.
    ///   - succeeded: True if the command succeeded.
    ///   - error: Command error.
    init(stdout: String = "",
         stderror: String = "",
         exitcode: Int = 0,
         succeeded: Bool = true,
         error: Error? = nil) {
        self.stdout = stdout
        self.stderror = stderror
        self.exitcode = exitcode
        self.succeeded = succeeded
        self.error = error
    }
}

/// Protocol that defines the interface of an entity that runs shell commands.
protocol Shelling {
    /// Runs the open command with the given arguments.
    ///
    /// - Parameter arguments: Arguments to be passed to open.
    /// - Throws: A CommandError if the open command fails.
    func open(_ arguments: [String]) throws

    /// Runs simctl with the given arguments.
    ///
    /// - Parameter arguments: Arguments to be passed to simctl.
    /// - Returns: The command output.
    /// - Throws: A CommandError if the command fails.
    func simctl(_ arguments: [String]) throws -> ShellOutput

    /// Runs xcrun with the given arguments.
    ///
    /// - Parameter arguments: Arguments to be passed to xcrun.
    /// - Returns: The output from running the command.
    /// - Throws: A CommandError if the command fails.
    func xcrun(_ arguments: [String]) throws -> ShellOutput
    /// It runs which with the given tool.
    ///
    /// - Parameter name: Name of the tool.
    /// - Returns: Which result.
    /// - Throws: CommandError if the command fails.
    func which(_ name: String) throws -> String
    /// Runs a command in the shell.
    ///
    /// - Parameters:
    ///   - launchPath: Path to be launched.
    ///   - arguments: List of arguments to be passed to the command.
    /// - Returns: The output from running the command.
    func run(launchPath: String, arguments: [String]) -> ShellOutput

    /// It returns the Xcode path using xcode-select.
    ///
    /// - Returns: Xcode path.
    /// - Throws: CommandError if the command fails.
    func xcodePath() throws -> String
}

/// Struct that conforms the Shelling providing a default implementation.
public struct Shell: Shelling {
    /// Shared instance of Shell.
    public static let shared = Shell()

    // MARK: - Shelling

    /// Runs the open command with the given arguments.
    ///
    /// - Parameter arguments: Arguments to be passed to open.
    /// - Throws: A CommandError if the open command fails.
    public func open(_ arguments: [String]) throws {
        let output = run(launchPath: "/usr/bin/open", arguments: arguments)
        if let error = output.error {
            throw error
        }
    }

    /// Runs simctl with the given arguments.
    ///
    /// - Parameter arguments: Arguments to be passed to simctl.
    /// - Returns: The command output.
    /// - Throws: A CommandError if the command fails.
    public func simctl(_ arguments: [String]) throws -> ShellOutput {
        var arguments = arguments
        arguments.insert("simctl", at: 0)
        return try xcrun(arguments)
    }

    /// Runs xcrun with the given arguments.
    ///
    /// - Parameter arguments: Arguments to be passed to xcrun.
    /// - Returns: The output from running the command.
    /// - Throws: A CommandError if the command fails.
    public func xcrun(_ arguments: [String]) throws -> ShellOutput {
        let path = try xcrunPath()
        return run(launchPath: path, arguments: arguments)
    }

    /// It runs which with the given tool.
    ///
    /// - Parameter name: Name of the tool.
    /// - Returns: Which result.
    /// - Throws: CommandError if the command fails.
    public func which(_ name: String) throws -> String {
        let output = run(launchPath: "/usr/bin/which", arguments: [name])
        if let error = output.error {
            throw error
        }
        return output.stdout.spm_chomp()
    }

    /// Runs a command in the shell.
    ///
    /// - Parameters:
    ///   - launchPath: Path to be launched.
    ///   - arguments: List of arguments to be passed to the command.
    /// - Returns: The output from running the command.
    public func run(launchPath: String, arguments: [String]) -> ShellOutput {
        return ShellOutput(SwiftShell.run(launchPath, arguments))
    }

    /// It returns the Xcode path using xcode-select.
    ///
    /// - Returns: Xcode path.
    /// - Throws: CommandError if the command fails.
    public func xcodePath() throws -> String {
        let output = run(launchPath: "/usr/bin/xcode-select", arguments: ["-p"])
        if let error = output.error {
            throw error
        }
        return output.stdout.spm_chomp()
    }

    // MARK: - Fileprivate

    /// Returns the path to xcrun.
    ///
    /// - Returns: Path where xcrun is located in the system.
    fileprivate func xcrunPath() throws -> String {
        return try which("xcrun")
    }
}
