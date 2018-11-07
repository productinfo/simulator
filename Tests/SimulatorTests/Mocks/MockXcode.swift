import Foundation
import SwiftShell

@testable import Simulator

final class MockXcode: Xcoding {
    var simulatorSDKPathStub: ((Runtime.Platform) throws -> URL?)?
    var runtimeProfilesPathStub: ((Runtime.Platform) throws -> URL?)?

    func simulatorSDKPath(platform: Runtime.Platform) throws -> URL? {
        return try simulatorSDKPathStub?(platform)
    }

    func runtimeProfilesPath(platform: Runtime.Platform) throws -> URL? {
        return try runtimeProfilesPathStub?(platform)
    }
}
