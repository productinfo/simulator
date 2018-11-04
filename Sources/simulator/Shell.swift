import Foundation
import ReactiveSwift
import ReactiveTask

/// Contains all the errors that are returned by the Shell signal producers.
///
/// - taskError: Error returned by the underlying task run in the system.
/// - nonUtf8Output: Thrown when an output expected to be of type utf8 has a different type.
enum ShellError: Error {
    case taskError(TaskError)
    case nonUtf8Output
}

/// Protocol that defines the interface of an entity that runs shell commands.
protocol Shelling {
    /// Runs the open command with the given arguments.
    ///
    /// - Parameter arguments: Arguments to be passed to the open command.
    /// - Returns: A signal producer that runs the command.
    func open(_ arguments: [String]) -> SignalProducer<Void, ShellError>

    /// Runs simctl with the given arguments.
    ///
    /// - Parameter arguments: Arguments to be passed to simctl.
    /// - Returns: A signal producer that runs the simctl command.
    func simctl(_ arguments: [String]) -> SignalProducer<TaskEvent<Data>, ShellError>

    /// Runs xcrun with the given arguments.
    ///
    /// - Parameter arguments: Arguments to be passed to xcrun.
    /// - Returns: A signal producer that runs the xcrun command.
    func xcrun(_ arguments: [String]) -> SignalProducer<TaskEvent<Data>, ShellError>

    /// Returns a signal producer that runs the which command with the given name.
    /// If the tool with the given name is available in the environment, the producer will return
    /// the path to the tool.
    ///
    /// - Parameter name: Argument to be passed to the which command.
    /// - Returns: A signal producer that runs the command.
    func which(_ name: String) -> SignalProducer<String, ShellError>

    /// Returns a signal producer that runs the given command on the shell.
    ///
    /// - Parameters:
    ///   - launchPath: Path to be launched.
    ///   - arguments: List of arguments to be passed to the command.
    /// - Returns: A signal producer that triggers the command when subscribers subscribe to it.
    func run(launchPath: String, arguments: [String]) -> SignalProducer<TaskEvent<Data>, ShellError>
}

/// Struct that conforms the Shelling providing a default implementation.
struct Shell: Shelling {
    /// Shared instance of Shell.
    public static let shared: Shelling = Shell()

    // MARK: - Shelling

    /// Runs the open command with the given arguments.
    ///
    /// - Parameter arguments: Arguments to be passed to the open command.
    /// - Returns: A signal producer that runs the command.
    func open(_ arguments: [String]) -> SignalProducer<Void, ShellError> {
        return run(launchPath: "/usr/bin/open", arguments: arguments).map(value: ())
    }

    /// Runs simctl with the given arguments.
    ///
    /// - Parameter arguments: Arguments to be passed to simctl.
    /// - Returns: A signal producer that runs the simctl command.
    func simctl(_ arguments: [String]) -> SignalProducer<TaskEvent<Data>, ShellError> {
        var arguments = ["simctl"]
        arguments.append(contentsOf: arguments)
        return xcrun(arguments)
    }

    /// Runs xcrun with the given arguments.
    ///
    /// - Parameter arguments: Arguments to be passed to xcrun.
    /// - Returns: A signal producer that runs the xcrun command.
    func xcrun(_ arguments: [String]) -> SignalProducer<TaskEvent<Data>, ShellError> {
        return xcrunPath()
            .flatMap(.latest, { (path: String) -> SignalProducer<TaskEvent<Data>, ShellError> in
                self.run(launchPath: path, arguments: arguments)
            })
    }

    /// Returns a signal producer that runs the which command with the given name.
    /// If the tool with the given name is available in the environment, the producer will return
    /// the path to the tool.
    ///
    /// - Parameter name: Argument to be passed to the which command.
    /// - Returns: A signal producer that runs the command.
    func which(_ name: String) -> SignalProducer<String, ShellError> {
        return run(launchPath: "/usr/bin/which", arguments: [name])
            .ignoreTaskData()
            .flatMap(.latest, { (data: Data) -> SignalProducer<String, ShellError> in
                guard let path: String = String(data: data, encoding: .utf8) else {
                    return SignalProducer(error: ShellError.nonUtf8Output)
                }
                return SignalProducer(value: path)
            })
    }

    /// Returns a signal producer that runs the given command on the shell.
    ///
    /// - Parameters:
    ///   - launchPath: Path to be launched.
    ///   - arguments: List of arguments to be passed to the command.
    /// - Returns: A signal producer that triggers the command when subscribers subscribe to it.
    func run(launchPath: String, arguments: [String]) -> SignalProducer<TaskEvent<Data>, ShellError> {
        return Task(launchPath, arguments: arguments).launch().mapError({ ShellError.taskError($0) })
    }

    // MARK: - Fileprivate

    /// Returns a signal producer that returns the path of xcrun.
    ///
    /// - Returns: Path where xcrun is located in the system.
    fileprivate func xcrunPath() -> SignalProducer<String, ShellError> {
        return which("xcrun")
    }
}
