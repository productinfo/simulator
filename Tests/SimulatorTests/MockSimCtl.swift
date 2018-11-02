import Foundation
@testable import Simulator

final class MockSimCtl: SimCtling {
    private var stubs: [[String]: Any] = [:]

    func simctl(_ arguments: String...) throws -> Data {
        guard let stub = stubs[arguments] else {
            throw AnyError()
        }
        return try JSONSerialization.data(withJSONObject: stub, options: [])
    }

    func stub(_ arguments: String..., with: Any) {
        stubs[arguments] = with
    }
}
