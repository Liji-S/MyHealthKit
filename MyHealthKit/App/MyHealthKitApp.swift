import SwiftUI

@main
struct MyHealthKitApp: App {
    private let container = AppContainer()

    var body: some Scene {
        WindowGroup {
            RootView(container: container)
        }
    }
}

/// Picks the root layout by size class: a sidebar split view on regular-width
/// screens (iPad, or an iPhone Pro Max in landscape), and the familiar
/// tab bar on compact-width screens (iPhone in portrait).
///
/// The coordinator lives here, above both layouts, so navigation state
/// survives a size-class change.
private struct RootView: View {
    let container: AppContainer
    @State private var coordinator = AppCoordinator()
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        let factory = RouteViewFactory(container: container, coordinator: coordinator)
        Group {
            if horizontalSizeClass == .regular {
                RootSplitView(coordinator: coordinator, factory: factory)
            } else {
                RootTabView(coordinator: coordinator, factory: factory)
            }
        }
    }
}

/// iPad / regular-width layout: a sidebar of every top-level destination and
/// a detail column showing whichever one is selected.
private struct RootSplitView: View {
    @Bindable var coordinator: AppCoordinator
    let factory: RouteViewFactory

    var body: some View {
        NavigationSplitView {
            List(AppRoute.allCases, selection: $coordinator.selectedRoute) { route in
                Label(route.title, systemImage: route.systemImage)
                    .tag(route)
            }
            .navigationTitle("MyHealthKit")
        } detail: {
            NavigationStack {
                factory.view(for: coordinator.selectedRoute ?? .dashboard)
            }
        }
    }
}

/// iPhone / compact-width layout: Home and Documents tabs, with Home pushing
/// into the other features via the coordinator's `homePath`.
private struct RootTabView: View {
    @Bindable var coordinator: AppCoordinator
    let factory: RouteViewFactory

    var body: some View {
        TabView(selection: $coordinator.selectedTab) {
            NavigationStack(path: $coordinator.homePath) {
                factory.view(for: .dashboard)
                    .navigationDestination(for: AppRoute.self) { route in
                        factory.view(for: route)
                    }
            }
            .tabItem { Label("Home", systemImage: "house.fill") }
            .tag(AppTab.home)

            NavigationStack {
                factory.view(for: .documentVault)
            }
            .tabItem { Label("Documents", systemImage: "folder.fill") }
            .tag(AppTab.documents)
        }
        .modifier(SidebarTabBarPlacementModifier())
    }
}

/// Opts the root TabView into sidebar placement where the platform offers it
/// (iPhone Duo's inner display, and other large/adaptive layouts) — without
/// this, the tab bar can render as a small floating control instead of a
/// full-width bar on the inner display. No-ops on OS versions that predate
/// the API, so the plain bottom tab bar remains the fallback everywhere else.
private struct SidebarTabBarPlacementModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content.tabViewStyle(.sidebarAdaptable)
        } else {
            content
        }
    }
}
