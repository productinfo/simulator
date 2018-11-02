import Foundation
@testable import Simulator

final class MockSimCtl: SimCtling {
    
    private var stubs: [[String]: Any] =  [:]
    
    func simctl(_ arguments: String...) throws -> String {
        guard let stub = stubs[arguments] else {
            throw AnyError()
        }
        let data = try JSONSerialization.data(withJSONObject: stub, options: [])
        return String.init(data: data, encoding: .utf8) ?? ""
    }
    
    func stub(_ arguments: String..., with: Any) {
        stubs[arguments] = with
    }
    
}
