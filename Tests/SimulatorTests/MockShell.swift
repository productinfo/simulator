import Foundation
import ReactiveSwift
import ReactiveTask
import Result
@testable import Simulator

final class MockShell: Shelling {
    var openStub: (([String]) -> Result<Void, ShellError>)?
    var simctlStub: (([String]) -> Result<TaskEvent<Data>, ShellError>)?
    var xcrunStub: (([String]) -> Result<TaskEvent<Data>, ShellError>)?
    var whichStub: ((String) -> Result<String, ShellError>)?
    var runStub: ((String, [String]) -> Result<TaskEvent<Data>, ShellError>)?

    func stubSimctl(_ arguments: [String], result: Result<Any, ShellError>) {
        simctlStub = { _arguments in
            if arguments == _arguments {
                return result.map({ (json) -> TaskEvent<Data> in
                    TaskEvent.success(try! JSONSerialization.data(withJSONObject: json, options: []))
                })
            } else {
                return Result.failure(ShellError.taskError(TaskError.posixError(1)))
            }
        }
    }

    func open(_ arguments: [String]) -> SignalProducer<Void, ShellError> {
        if let result = openStub?(arguments) {
            return SignalProducer(result: result)
        } else {
            return SignalProducer(value: ())
        }
    }

    func simctl(_ arguments: [String]) -> SignalProducer<TaskEvent<Data>, ShellError> {
        if let result = simctlStub?(arguments) {
            return SignalProducer(result: result)
        } else {
            return SignalProducer(error: ShellError.taskError(TaskError.posixError(1)))
        }
    }

    func xcrun(_ arguments: [String]) -> SignalProducer<TaskEvent<Data>, ShellError> {
        if let result = xcrunStub?(arguments) {
            return SignalProducer(result: result)
        } else {
            return SignalProducer(error: ShellError.taskError(TaskError.posixError(1)))
        }
    }

    func which(_ name: String) -> SignalProducer<String, ShellError> {
        if let result = whichStub?(name) {
            return SignalProducer(result: result)
        } else {
            return SignalProducer(error: ShellError.taskError(TaskError.posixError(1)))
        }
    }

    func run(launchPath: String, arguments: [String]) -> SignalProducer<TaskEvent<Data>, ShellError> {
        if let result = runStub?(launchPath, arguments) {
            return SignalProducer(result: result)
        } else {
            return SignalProducer(error: ShellError.taskError(TaskError.posixError(1)))
        }
    }
}
