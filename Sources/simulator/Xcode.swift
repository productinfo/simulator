import Foundation
import Shell

protocol Xcoding {
    /// Returns the path to the platform simulator SDK.
    ///
    /// - Parameter platform: Simulator platform.
    /// - Returns: Path to the simulator SDK.
    /// - Throws: An error if the path cannot be obtained.
    func simulatorSDKPath(platform: Runtime.Platform) throws -> URL?

    /// Returns the path where the platform simulator runtimes are located.
    ///
    /// - Parameter platform: Platform whose runtime profiles will be returned.
    /// - Returns: Path to the simulator runtimes.
    /// - Throws: An error if the path cannot be obtained.
    func runtimeProfilesPath(platform: Runtime.Platform) throws -> URL?
}

/// Struct that provides some helper methods to read information from the Xcode environment.
struct Xcode: Xcoding {
    // MARK: - Attributes

    /// Shell instance to run commands.
    private let shell: Shell

    // MARK: - Init

    /// Initializes the Xcode instance.
    ///
    /// - Parameter shell: Shell instance to run commands on.
    init(shell: Shell = Shell()) {
        self.shell = shell
    }

    /// Returns the path to the platform simulator SDK.
    ///
    /// - Parameter platform: Simulator platform.
    /// - Returns: Path to the simulator SDK.
    /// - Throws: An error if the path cannot be obtained.
    func runtimeProfilesPath(platform: Runtime.Platform) throws -> URL? {
        guard let device = devicePlatform(platform: platform) else {
            return nil
        }
        return try shell.xcodePath().appendingPathComponent("Platforms/\(device).platform/Developer/Library/CoreSimulator/Profiles/Runtimes/")
    }

    /// Returns the path where the platform simulator runtimes are located.
    ///
    /// - Parameter platform: Platform whose runtime profiles will be returned.
    /// - Returns: Path to the simulator runtimes.
    /// - Throws: An error if the path cannot be obtained.
    func simulatorSDKPath(platform: Runtime.Platform) throws -> URL? {
        guard let simulator = simulatorPlatform(platform: platform) else {
            return nil
        }
        return try shell.xcodePath().appendingPathComponent("Platforms/\(simulator).platform/Developer/SDKs/\(simulator).sdk/")
    }

    /// Given a platform, it returns the name of the simulator platform to look it up in the Developer/Platforms directory.
    ///
    /// - Parameter platform: Platform.
    /// - Returns: Simulator platform (e.g. iPhoneSimulator.platform)
    func simulatorPlatform(platform: Runtime.Platform) -> String? {
        switch platform {
        case .iOS:
            return "iPhoneSimulator"
        case .watchOS:
            return "WatchSimulator"
        case .tvOS:
            return "AppleTVSimulator"
        default:
            return nil
        }
    }

    /// Given a platform, it returns the device name to look it up in the Developer/Platforms directory.
    ///
    /// - Parameter platform: Platform.
    /// - Returns: Device platform name.
    func devicePlatform(platform: Runtime.Platform) -> String? {
        switch platform {
        case .iOS:
            return "iPhoneOS"
        case .watchOS:
            return "WatchOS"
        case .tvOS:
            return "AppleTVOS"
        default:
            return nil
        }
    }
}
