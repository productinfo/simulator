import Foundation
import Result

@testable import Simulator

final class MockXcode: Xcoding {
    var simulatorSDKPathStub: ((Runtime.Platform) -> Result<URL?, SimulatorError>)?
    var runtimeProfilesPathStub: ((Runtime.Platform) -> Result<URL?, SimulatorError>)?

    func simulatorSDKPath(platform: Runtime.Platform) -> Result<URL?, SimulatorError> {
        return simulatorSDKPathStub?(platform) ?? .success(nil)
    }

    func runtimeProfilesPath(platform: Runtime.Platform) -> Result<URL?, SimulatorError> {
        return simulatorSDKPathStub?(platform) ?? .success(nil)
    }
}
