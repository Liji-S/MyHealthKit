import SwiftUI

/// The one place that maps an `AppRoute` to its screen, used by both root
/// layouts. Features never build each other's views; they report navigation
/// through callbacks (e.g. Dashboard's `onNavigate`) that end up in the
/// coordinator.
@MainActor
struct RouteViewFactory {
    let container: AppContainer
    let coordinator: AppCoordinator

    @ViewBuilder
    func view(for route: AppRoute) -> some View {
        switch route {
        case .dashboard:
            DashboardView(viewModel: container.dashboard.makeDashboardViewModel()) { route in
                coordinator.open(route)
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
