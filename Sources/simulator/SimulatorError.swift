import Foundation

public enum SimulatorError: Error {
    /// Thrown the underlying command doesn't return any output.
    case noOutput

    /// Thrown when the JSON output cannot be parsed.
    case jsonSerialize(Error)

    /// Thrown when the JSON output cannot be decoded.
    case jsonDecode(Error)

    /// Thrown when the command output has an invalid/unexpected output.
    case invalidFormat

    /// Thrown when a device type cannot be obtained.
    case deviceTypeNotFound

    /// Thrown when a device runtime cannot be found.
    case runtimeNotFound

    /// Thrown when the simulator runtime profile cannot be found.
    case runtimeProfileNotFound

    /// Thrown when the output from the launchtl list command cannot be parsed.
    case invalidLaunchCtlListOutput

    /// Thrown when Xcode is not found using xcode-select
    case xcodeNotFound

    /// Thrown when a command exits unsuccessfully
    case shellError(String?)
}
