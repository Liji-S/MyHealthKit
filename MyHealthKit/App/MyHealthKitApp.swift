import SwiftUI

@main
struct MyHealthKitApp: App {
    private let container = AppContainer()

    var body: some Scene {
        WindowGroup {
            RootTabView(container: container)
        }
    }
}

private struct RootTabView: View {
    let container: AppContainer

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
    }

    @ViewBuilder
    private func destination(for route: AppRoute) -> some View {
        switch route {
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
