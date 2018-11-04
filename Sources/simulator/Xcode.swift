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

    /// Returns a signal producer that returns the path where the platform simulator
    ///
    /// - Parameters:
    ///   - platform: Platform whose simulator SDK path will be returned
    /// - Returns: Signal producer that returns the path where the platform simulator SDK is located.
    func simulatorSDKPath(platform: Runtime.Platform) -> SignalProducer<URL?, ShellError> {
        guard let simulator = simulator(platform: platform) else {
            return SignalProducer(value: nil)
        }
        return shell.xcodePath()
            .map({ URL(fileURLWithPath: $0, isDirectory: true) })
            .map({ $0.appendingPathComponent("Platforms/\(simulator).platform/Developer/SDKs/\(simulator).sdk/") })
    }

    /// Given a platform, it returns the name of the simulator platform.
    ///
    /// - Parameter platform: Platform.
    /// - Returns: Simulator platform (e.g. iPhoneSimulator.platform)
    func simulator(platform: Runtime.Platform) -> String? {
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
}
