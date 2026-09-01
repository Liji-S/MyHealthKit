import Foundation

struct UpdateMedicationUseCaseImpl: UpdateMedicationUseCaseProtocol {
    private let repository: MedicationRepositoryProtocol
    private let reminderScheduler: RefillReminderSchedulerProtocol

    init(repository: MedicationRepositoryProtocol, reminderScheduler: RefillReminderSchedulerProtocol) {
        self.repository = repository
        self.reminderScheduler = reminderScheduler
    }

    func execute(_ medication: Medication) async throws {
        try repository.update(medication)
        await reminderScheduler.cancelRefillReminder(for: medication)
        await reminderScheduler.scheduleRefillReminder(for: medication)
    }
}
