import Foundation
import UserNotifications

final class UserNotificationsRefillScheduler: RefillReminderSchedulerProtocol {
    private let center = UNUserNotificationCenter.current()

    func requestAuthorization() async {
        _ = try? await center.requestAuthorization(options: [.alert, .sound, .badge])
    }

    func scheduleRefillReminder(for medication: Medication) async {
        guard let dueDate = medication.refillDueDate else { return }

        let content = UNMutableNotificationContent()
        content.title = "Refill Reminder"
        content.body = "\(medication.name) is running low. Time to order a refill."
        content.sound = .default

        var components = Calendar.current.dateComponents([.year, .month, .day], from: dueDate)
        components.hour = 9
        components.minute = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(
            identifier: identifier(for: medication),
            content: content,
            trigger: trigger
        )
        try? await center.add(request)
    }

    func cancelRefillReminder(for medication: Medication) async {
        center.removePendingNotificationRequests(withIdentifiers: [identifier(for: medication)])
    }

    private func identifier(for medication: Medication) -> String {
        "medication-refill-\(medication.id.uuidString)"
    }
}
