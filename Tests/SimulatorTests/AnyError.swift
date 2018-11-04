import Foundation

/// Error to be used for testing purposes
struct AnyError: Error {
    /// Error description.
    let description: String

    /// Initializes the error.
    ///
    /// - Parameter description: Error description.
    init(description: String = "") {
        self.description = description
    }
}
