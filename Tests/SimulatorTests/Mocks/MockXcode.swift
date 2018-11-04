import Foundation
import ReactiveSwift
import ReactiveTask
import Result

@testable import Simulator

final class MockXcode: Xcoding {
    var simulatorSDKPathStub: ((Runtime.Platform) -> Result<URL?, ShellError>)?
    var runtimeProfilesPathStub: ((Runtime.Platform) -> Result<URL?, ShellError>)?

    func simulatorSDKPath(platform: Runtime.Platform) -> SignalProducer<URL?, ShellError> {
        if let result = simulatorSDKPathStub?(platform) {
            return SignalProducer(result: result)
        } else {
            return SignalProducer(value: nil)
        }
    }

    func runtimeProfilesPath(platform: Runtime.Platform) -> SignalProducer<URL?, ShellError> {
        if let result = runtimeProfilesPathStub?(platform) {
            return SignalProducer(result: result)
        } else {
            return SignalProducer(value: nil)
        }
    }
}
