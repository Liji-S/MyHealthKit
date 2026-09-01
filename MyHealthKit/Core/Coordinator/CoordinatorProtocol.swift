import Foundation

/// Conformed by each feature's coordinator (POP: shared contract, no shared state).
protocol CoordinatorProtocol: AnyObject {
    associatedtype Route: Hashable
    var path: [Route] { get set }

    func push(_ route: Route)
    func pop()
    func popToRoot()
}

extension CoordinatorProtocol {
    func push(_ route: Route) {
        path.append(route)
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func popToRoot() {
        path.removeAll()
    }
}
