import Foundation
import Shell

public enum SimulatorError: Error, CustomStringConvertible {
    /// Thrown the underlying command doesn't return any output.
    case noOutput

    /// Thrown when the JSON output cannot be parsed.
    case jsonSerialize(Error)

    /// Thrown when the JSON output cannot be decoded.
    case jsonDecode(Error)

    /// Thrown when a plist file cannot be decoded.
    case plistSerialize(Error)

    /// Thrown when the command output has an invalid/unexpected output.
    case invalidFormat

    /// Thrown when a device type cannot be obtained.
    case deviceTypeNotFound

    /// Thrown when a device runtime cannot be found.
    case runtimeNotFound

    /// Thrown when the simulator runtime profile cannot be found.
    case runtimeProfileNotFound

    /// Thrown when Xcode is not found using xcode-select
    case xcodeNotFound

    /// Thrown when a command exits unsuccessfully
    case shell(ShellError)

    /// Thrown when the method times out.
    case timeoutError

    /// Thrown by the file manager.
    case fileManager(Error)

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
        case .xcodeNotFound:
            return "Xcode not found running xcode-select"
        case let .shell(error):
            return "Error running command: \(error)"
        case .timeoutError:
            return "Timeout error"
        case let .plistSerialize(error):
            return "Error serializing plist file: \(error)"
        case let .fileManager(error):
            return "File manager error: \(error)"
        }
    }
}
