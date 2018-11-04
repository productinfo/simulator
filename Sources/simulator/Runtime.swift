import Foundation

/// This class represents a simctl runtime. In Xcode, a runtime is a pair of an OS and its version, for example iOS 12.1
public struct Runtime: Decodable, Equatable {
    /// The path where the runtime bundle is.
    /// Example: /Applications/Xcode.app/Contents/Developer/Platforms/WatchOS.platform/Developer/Library/CoreSimulator/Profiles/Runtimes/watchOS.simruntime
    let bundlePath: URL?

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

    /// Coding keys
    enum CodingKeys: String, CodingKey {
        case bundlePath
        case availabilityError
        case buildVersion
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
}

// },
// {
//    "bundlePath" : "\/Applications\/Xcode.app\/Contents\/Developer\/Platforms\/WatchOS.platform\/Developer\/Library\/CoreSimulator\/Profiles\/Runtimes\/watchOS.simruntime",
//    "availabilityError" : "",
//    "buildversion" : "16R591",
//    "availability" : "(available)",
//    "isAvailable" : true,
//    "identifier" : "com.apple.CoreSimulator.SimRuntime.watchOS-5-1",
//    "version" : "5.1",
//    "name" : "watchOS 5.1"
// }
// ]

// attr_reader :availability, :buildversion, :identifier, :name, :type, :version
