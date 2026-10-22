import Foundation
import Observation

/// Single owner of root-level navigation state, shared by the iPhone
/// (TabView) and iPad (NavigationSplitView) layouts.
///
/// Only `selectedTab` and `homePath` are stored; the sidebar selection is
/// derived from them. That keeps both layouts in sync, so switching size
/// class (rotation, iPad multitasking) doesn't lose where the user was, and
/// `open(_:)` works the same from a Dashboard tile, a deep link, a shortcut
/// or a notification tap.
@MainActor
@Observable
final class AppCoordinator {
    var selectedTab: AppTab = .home
    var homePath: [AppRoute] = []

    /// The destination currently on screen. Setting it is the same as `open(_:)`,
    /// which lets the sidebar `List` bind to it directly.
    var selectedRoute: AppRoute? {
        get {
            switch selectedTab {
            case .documents: .documentVault
            case .home: homePath.last ?? .dashboard
            }
        }
        set {
            open(newValue ?? .dashboard)
        }
    }

    /// Shows `route` from anywhere, replacing whatever was pushed before.
    func open(_ route: AppRoute) {
        switch route {
        case .dashboard:
            selectedTab = .home
            homePath = []
        case .documentVault:
            selectedTab = .documents
        case .doctorSearch, .emergencySOS, .firstAidGuide, .medicationReminders:
            selectedTab = .home
            homePath = [route]
        }
    }

    func pop() {
        guard !homePath.isEmpty else { return }
        homePath.removeLast()
    }

    func popToRoot() {
        homePath.removeAll()
    }
}
