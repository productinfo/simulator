import Foundation

/// It represents a service running on a simulator.
public struct Service: Equatable {
    /// Service PID.
    let pid: String

    /// Service status ( 0 == not running)
    let status: Int

    /// Service label
    /// Example: com.apple.storedownloadd.daemon
    let label: String

    /// Initializes the service with its attributes.
    ///
    /// - Parameters:
    ///   - pid: Service PID.
    ///   - status: Service status ( 0 == not running)
    ///   - label: Service label.
    init(pid: String,
         status: Int,
         label: String) {
        self.pid = pid
        self.status = status
        self.label = label
    }

    /// Compares two instances of a Service and returns true if the two instances are the same.
    ///
    /// - Parameters:
    ///   - lhs: First instance to be compared.
    ///   - rhs: Instance to be compared with.
    /// - Returns: True if both instances are equal.
    public static func == (lhs: Service, rhs: Service) -> Bool {
        return lhs.pid == rhs.pid &&
            lhs.status == rhs.status &&
            lhs.label == rhs.label
    }
}
