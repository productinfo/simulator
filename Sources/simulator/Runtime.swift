import Foundation
import ReactiveSwift
import ReactiveTask
import Result

/// This class represents a simctl runtime. In Xcode, a runtime is a pair of an OS and its version, for example iOS 12.1
public struct Runtime: Decodable, Equatable {
    /// Runtime platform.
    ///
    /// - iOS: iOS
    /// - watchOS: watchOS
    /// - tvOS: tvOS descriptiontvOS
    enum Platform: String {
        case iOS
        case watchOS
        case tvOS
        case unknown
    }

    /// The path where the runtime bundle is.
    /// Example: /Applications/Xcode.app/Contents/Developer/Platforms/WatchOS.platform/Developer/Library/CoreSimulator/Profiles/Runtimes/watchOS.simruntime
    let bundlePath: String?

    /// If the runtime is not available, this string includes a description of explaining why it's not available.
    let availabilityError: String?

    /// The build version of the runtime.
    /// Example: 16R591
    let buildVersion: String

    /// Describes the availability of the runtime.\
    /// Example: (available)
    let availability: String

    /// True when the runtime is available.
    let isAvailable: Bool?

    /// Uniquely identifies the runtime.
    /// Example: com.apple.CoreSimulator.SimRuntime.watchOS-5-1
    let identifier: String

    /// Runtime version.
    /// Example: 5.1
    let version: String

    /// Runtime name.
    /// Example: watchOS 5.1
    let name: String

    /// Returns the runtime platform.
    var platform: Platform {
        return name.split(separator: "/").first.flatMap({ Platform(rawValue: String($0)) }) ?? .unknown
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

    /// Returns the lit of runtimes from the system.
    ///
    /// - Returns: List of runtimes.
    /// - Throws: A SimulatorError if the runtimes cannot be fetched.
    public static func list() throws -> [Runtime] {
        return try Reactive.list().single()?.dematerialize() ?? []
    }

    public enum Reactive {
        /// Returns a signal producer that gets the list of runtimes from the system.
        ///
        /// - Returns: Signal producer that returns the list of runtimes.
        public static func list() -> SignalProducer<[Runtime], SimulatorError> {
            return list(shell: Shell.shared)
        }

        /// Returns a signal producer that gets the list of runtimes from the system.
        ///
        /// - Parameter shell: Shell to run simctl commands.
        /// - Returns: Signal producer that returns the list of runtimes.
        static func list(shell: Shelling) -> SignalProducer<[Runtime], SimulatorError> {
            let decoder = JSONDecoder()
            return shell.simctl(["list", "-j", "runtimes"])
                .ignoreTaskData()
                .mapError({ SimulatorError.shell($0) })
                .attemptMap({ (data) -> Result<Any, SimulatorError> in
                    do {
                        return try Result.success(JSONSerialization.jsonObject(with: data, options: []))
                    } catch {
                        return Result.failure(SimulatorError.jsonSerialize(error))
                    }
                })
                .attemptMap({ (object) -> Result<[[String: Any]], SimulatorError> in
                    guard let dictionary = object as? [String: Any],
                        let runtimes = dictionary["runtimes"] as? [[String: Any]] else {
                        return Result.failure(SimulatorError.invalidFormat)
                    }
                    return Result.success(runtimes)
                })
                .attemptMap { (runtimes) -> Result<[Runtime], SimulatorError> in
                    do {
                        let runtimesData = try JSONSerialization.data(withJSONObject: runtimes, options: [])
                        return Result.success(try decoder.decode([Runtime].self, from: runtimesData))
                    } catch {
                        return Result.failure(SimulatorError.jsonDecode(error))
                    }
                }
        }
    }
}
