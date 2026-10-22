import Foundation
import Observation

/// Root-level navigation state shared between the iPhone (TabView) and iPad
/// (NavigationSplitView) layouts, so selecting a destination from one place
/// — e.g. a Dashboard quick-action tile — means the same thing regardless of
/// which layout is currently active.
@Observable
final class AppCoordinator {
    var selectedRoute: AppRoute? = .dashboard
}
