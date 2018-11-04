import Foundation
import ReactiveSwift

protocol Xcoding {
    /// Returns a signal producer that returns the path where the platform simulator
    ///
    /// - Parameters:
    ///   - platform: Platform whose simulator SDK path will be returned
    /// - Returns: Signal producer that returns the path where the platform simulator SDK is located.
    func simulatorSDKPath(platform: Runtime.Platform) -> SignalProducer<URL?, ShellError>
}

/// Struct that provides some helper methods to read information from the Xcode environment.
struct Xcode: Xcoding {
    // MARK: - Attributes

    /// Shell instance to run commands.
    private let shell: Shelling

    // MARK: - Init

    /// Initializes the Xcode instance.
    ///
    /// - Parameter shell: Shell instance to run commands on.
    init(shell: Shelling = Shell.shared) {
        self.shell = shell
    }

    /// Returns a signal producer that returns the path where the platform simulator runtimes are located.
    ///
    /// - Parameter platform: Platform whose runtime profiles will be returned.
    /// - Returns: Signal producer that returns the path.
    func runtimeProfilesPath(platform: Runtime.Platform) -> SignalProducer<URL?, ShellError> {
        guard let device = devicePlatform(platform: platform) else {
            return SignalProducer(value: nil)
        }
        return shell.xcodePath()
            .map({ URL(fileURLWithPath: $0, isDirectory: true) })
            .map({ $0.appendingPathComponent("Platforms/\(device).platform/Developer/Library/CoreSimulator/Profiles/Runtimes/") })
    }

    /// Returns a signal producer that returns the path where the platform simulator
    ///
    /// - Parameters:
    ///   - platform: Platform whose simulator SDK path will be returned
    /// - Returns: Signal producer that returns the path where the platform simulator SDK is located.
    func simulatorSDKPath(platform: Runtime.Platform) -> SignalProducer<URL?, ShellError> {
        guard let simulator = simulatorPlatform(platform: platform) else {
            return SignalProducer(value: nil)
        }
        return shell.xcodePath()
            .map({ URL(fileURLWithPath: $0, isDirectory: true) })
            .map({ $0.appendingPathComponent("Platforms/\(simulator).platform/Developer/SDKs/\(simulator).sdk/") })
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
