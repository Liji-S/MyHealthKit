import Foundation

/// Abstracts local notification scheduling so Domain/UseCase code never imports
/// UserNotifications directly.
protocol RefillReminderSchedulerProtocol {
    func requestAuthorization() async
    func scheduleRefillReminder(for medication: Medication) async
    func cancelRefillReminder(for medication: Medication) async
}
