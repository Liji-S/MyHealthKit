import Foundation
import Observation

@Observable
final class AppCoordinator: CoordinatorProtocol {
    typealias Route = AppRoute

    var path: [AppRoute] = []
}
