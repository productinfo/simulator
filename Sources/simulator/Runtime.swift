import Foundation
import Result
import Shell

/// This class represents a simctl runtime. In Xcode, a runtime is a pair of an OS and its version, for example iOS 12.1
public struct Runtime: Decodable, Equatable {
    /// Runtime platform.
    ///
    /// - iOS: iOS
    /// - watchOS: watchOS
    /// - tvOS: tvOS descriptiontvOS
    public enum Platform: String {
        case iOS
        case watchOS
        case tvOS
        case unknown
    }

    /// The path where the runtime bundle is.
    /// Example: /Applications/Xcode.app/Contents/Developer/Platforms/WatchOS.platform/Developer/Library/CoreSimulator/Profiles/Runtimes/watchOS.simruntime
    public let bundlePath: String?

    /// If the runtime is not available, this string includes a description of explaining why it's not available.
    public let availabilityError: String?

    /// The build version of the runtime.
    /// Example: 16R591
    public let buildVersion: String

    /// Describes the availability of the runtime.\
    /// Example: (available)
    public let availability: String

    /// True when the runtime is available.
    public let isAvailable: Bool?

    /// Uniquely identifies the runtime.
    /// Example: com.apple.CoreSimulator.SimRuntime.watchOS-5-1
    public let identifier: String

    /// Runtime version.
    /// Example: 5.1
    public let version: String

    /// Runtime name.
    /// Example: watchOS 5.1
    public let name: String

    /// Returns the runtime platform.
    public var platform: Platform {
        return name.split(separator: " ").first.flatMap({ Platform(rawValue: String($0)) }) ?? .unknown
    }

    /// Coding keys
    enum CodingKeys: String, CodingKey {
        case bundlePath
        case availabilityError
        case buildVersion = "buildversion"
        case availability
        case isAvailable
        case identifier
        case version
        case name
    }

    // MARK: - Equatable

    /// Compares two runtimes returning true if the two runtimes are equal.
    ///
    /// - Parameters:
    ///   - lhs: First runtime to be compared.
    ///   - rhs: Runtime to be compared with.
    /// - Returns: True if the two runtimes are the same.
    public static func == (lhs: Runtime, rhs: Runtime) -> Bool {
        return lhs.bundlePath == rhs.bundlePath &&
            lhs.availabilityError == rhs.availabilityError &&
            lhs.buildVersion == rhs.buildVersion &&
            lhs.availability == rhs.availability &&
            lhs.isAvailable == rhs.isAvailable &&
            lhs.identifier == rhs.identifier &&
            lhs.version == rhs.version &&
            lhs.name == rhs.name
    }

    /// Returns the list of runtimes from the system.
    ///
    /// - Returns: List or runtimes or a simulator error.
    public static func list() -> Result<[Runtime], SimulatorError> {
        let decoder = JSONDecoder()
        let outputResult = shell.captureSimctl(["list", "-j", "runtimes"])
        if outputResult.error != nil { return .failure(outputResult.error!) }

        let data = outputResult.value!.data(using: .utf8) ?? Data()
        let jsonResult = Result {
            try JSONSerialization.jsonObject(with: data, options: [])
        }.mapError(SimulatorError.jsonSerialize)
        if jsonResult.error != nil { return .failure(jsonResult.error!) }

        guard let dictionary = jsonResult.value! as? [String: Any],
            let runtimes = dictionary["runtimes"] as? [[String: Any]] else {
            return .failure(.invalidFormat)
        }

        let runtimesDataResult = Result {
            try JSONSerialization.data(withJSONObject: runtimes, options: [])
        }.mapError(SimulatorError.jsonSerialize)
        if runtimesDataResult.error != nil { return .failure(runtimesDataResult.error!) }

        return Result {
            try decoder.decode([Runtime].self, from: runtimesDataResult.value!)
        }
    }

    /// Returns the latest runtime of a given platform.
    /// This is useful, for example, to determine the latest available runtime we can run our tests on.
    ///
    /// - Parameter platform: Platform whose latest runtime will be obtained.
    /// - Returns: Latest available runtime or a simulator error
    public static func latest(platform: Platform) -> Result<Runtime?, SimulatorError> {
        let listResult = list()
        if listResult.error != nil { return .failure(listResult.error!) }
        let runtime = listResult.value!
            .filter({ $0.platform == platform })
            .sorted(by: { $0.version < $1.version })
            .last
        return .success(runtime)
    }
}
