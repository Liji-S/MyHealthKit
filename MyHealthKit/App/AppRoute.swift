import Foundation

/// Top-level navigation destinations. Each feature owns its own sub-route enum;
/// this only covers root-level tab/flow entry points.
///
/// Also drives the iPad sidebar (NavigationSplitView) in addition to the
/// iPhone TabView/push-navigation flow, so it includes `dashboard` and
/// `documentVault` as selectable top-level destinations alongside the
/// routes reachable by pushing from the Dashboard.
enum AppRoute: Hashable, CaseIterable, Identifiable {
    case dashboard
    case doctorSearch
    case emergencySOS
    case firstAidGuide
    case medicationReminders
    case documentVault

    var id: Self { self }

    var title: String {
        switch self {
        case .dashboard: "Home"
        case .doctorSearch: "Find a Doctor"
        case .emergencySOS: "Emergency SOS"
        case .firstAidGuide: "First Aid"
        case .medicationReminders: "Medications"
        case .documentVault: "Documents"
        }
    }

    var systemImage: String {
        switch self {
        case .dashboard: "house.fill"
        case .doctorSearch: "stethoscope"
        case .emergencySOS: "sos"
        case .firstAidGuide: "cross.case.fill"
        case .medicationReminders: "pills.fill"
        case .documentVault: "folder.fill"
        }
    }
}
