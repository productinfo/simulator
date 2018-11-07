import Foundation

@testable import Simulator
@testable import SwiftShell

final class MockShell: Shelling {
    var openStub: (([String]) throws -> Void)?
    var simctlStub: (([String]) throws -> ShellOutput)?
    var xcrunStub: (([String]) throws -> ShellOutput)?
    var whichStub: ((String) throws -> String)?
    var runStub: ((String, [String]) -> ShellOutput)?
    var xcodePathStub: (() throws -> String)?

    func open(_ arguments: [String]) throws {
        try openStub?(arguments)
    }

    func simctl(_ arguments: [String]) throws -> ShellOutput {
        return try simctlStub?(arguments) ?? ShellOutput()
    }

    func xcrun(_ arguments: [String]) throws -> ShellOutput {
        return try xcrunStub?(arguments) ?? ShellOutput()
    }

    func which(_ name: String) throws -> String {
        return try whichStub?(name) ?? ""
    }

    func run(launchPath: String, arguments: [String]) -> ShellOutput {
        return runStub?(launchPath, arguments) ?? ShellOutput()
    }

    func xcodePath() throws -> String {
        return try xcodePathStub?() ?? ""
    }
}
