import Foundation

/// Simulator errors.
///
/// - noOutput: Thrown the underlying command doesn't return any output.
/// - shell: Thrown when the underlying command fails.
/// - jsonSerialize: Thrown when the JSON output cannot be parsed.
/// - jsonDecode: Thrown when the JSON output cannot be decoded.
/// - invalidFormat: Thrown when the command output has an invalid/unexpected output.
public enum SimulatorError: Error {
    case noOutput
    case shell(ShellError)
    case jsonSerialize(Error)
    case jsonDecode(Error)
    case invalidFormat
}
