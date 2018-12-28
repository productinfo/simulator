import Foundation

public enum SimulatorError: Error, CustomStringConvertible {
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

    /// Thrown when the method times out.
    case timeoutError

    public var description: String {
        switch self {
        case .noOutput:
            return "The command returned no output"
        case let .jsonSerialize(error):
            return "Error serializing the JSON output: \(error)"
        case let .jsonDecode(error):
            return "Error decoding the JSON output: \(error)"
        case .invalidFormat:
            return "Unexpected output format"
        case .deviceTypeNotFound:
            return "Device type not found"
        case .runtimeNotFound:
            return "Runtime not found"
        case .runtimeProfileNotFound:
            return "Runtime profile not found"
        case .invalidLaunchCtlListOutput:
            return "Invalid launchctl output"
        case .xcodeNotFound:
            return "Xcode not found running xcode-select"
        case let .shellError(error):
            if let error = error {
                return "Error running command: \(error)"
            } else {
                return "Error running command"
            }
        case .timeoutError:
            return "Timeout error"
        }
    }
}
