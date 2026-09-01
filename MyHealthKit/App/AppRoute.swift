import Foundation

/// Top-level navigation destinations. Each feature owns its own sub-route enum;
/// this only covers root-level tab/flow entry points.
enum AppRoute: Hashable {
    case doctorSearch
    case emergencySOS
    case firstAidGuide
    case medicationReminders
}
