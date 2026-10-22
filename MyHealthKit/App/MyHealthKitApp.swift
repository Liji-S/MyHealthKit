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
private struct RootView: View {
    let container: AppContainer
    @State private var coordinator = AppCoordinator()
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        Group {
            if horizontalSizeClass == .regular {
                RootSplitView(container: container, coordinator: coordinator)
            } else {
                RootTabView(container: container, coordinator: coordinator)
            }
        }
    }
}

/// iPad / regular-width layout: a sidebar of every top-level destination and
/// a detail column showing whichever one is selected.
private struct RootSplitView: View {
    let container: AppContainer
    @Bindable var coordinator: AppCoordinator

    var body: some View {
        NavigationSplitView {
            List(AppRoute.allCases, selection: $coordinator.selectedRoute) { route in
                Label(route.title, systemImage: route.systemImage)
                    .tag(route)
            }
            .navigationTitle("MyHealthKit")
        } detail: {
            NavigationStack {
                destination(for: coordinator.selectedRoute ?? .dashboard)
            }
        }
    }

    @ViewBuilder
    private func destination(for route: AppRoute) -> some View {
        switch route {
        case .dashboard:
            DashboardView(viewModel: container.dashboard.makeDashboardViewModel()) { route in
                coordinator.selectedRoute = route
            }
        case .doctorSearch:
            DoctorSearchView(viewModel: container.doctorSearch.makeDoctorSearchViewModel())
        case .emergencySOS:
            EmergencySOSView(viewModel: container.emergencySOS.makeEmergencySOSViewModel())
        case .firstAidGuide:
            FirstAidGuideView(viewModel: container.firstAid.makeFirstAidGuideViewModel())
        case .medicationReminders:
            MedicationRemindersView(viewModel: container.medicationReminders.makeMedicationRemindersViewModel())
        case .documentVault:
            DocumentVaultView(
                viewModel: container.documentVault.makeDocumentVaultViewModel(),
                makeSummaryViewModel: { container.documentVault.makeSummaryViewModel() }
            )
        }
    }
}

/// iPhone / compact-width layout: Home and Documents tabs, with Home pushing
/// into the other features via its own NavigationStack.
private struct RootTabView: View {
    let container: AppContainer
    let coordinator: AppCoordinator

    @State private var homePath = NavigationPath()
    @State private var documentsPath = NavigationPath()

    var body: some View {
        TabView {
            NavigationStack(path: $homePath) {
                DashboardView(viewModel: container.dashboard.makeDashboardViewModel()) { route in
                    homePath.append(route)
                }
                .navigationDestination(for: AppRoute.self) { route in
                    destination(for: route)
                }
            }
            .tabItem { Label("Home", systemImage: "house.fill") }

            NavigationStack(path: $documentsPath) {
                DocumentVaultView(
                    viewModel: container.documentVault.makeDocumentVaultViewModel(),
                    makeSummaryViewModel: { container.documentVault.makeSummaryViewModel() }
                )
            }
            .tabItem { Label("Documents", systemImage: "folder.fill") }
        }
        .modifier(SidebarTabBarPlacementModifier())
    }

    @ViewBuilder
    private func destination(for route: AppRoute) -> some View {
        switch route {
        case .dashboard, .documentVault:
            // Not reachable here: Dashboard only pushes its four quick-action
            // routes, and Documents is its own tab rather than a pushed route.
            EmptyView()
        case .doctorSearch:
            DoctorSearchView(viewModel: container.doctorSearch.makeDoctorSearchViewModel())
        case .emergencySOS:
            EmergencySOSView(viewModel: container.emergencySOS.makeEmergencySOSViewModel())
        case .firstAidGuide:
            FirstAidGuideView(viewModel: container.firstAid.makeFirstAidGuideViewModel())
        case .medicationReminders:
            MedicationRemindersView(viewModel: container.medicationReminders.makeMedicationRemindersViewModel())
        }
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
