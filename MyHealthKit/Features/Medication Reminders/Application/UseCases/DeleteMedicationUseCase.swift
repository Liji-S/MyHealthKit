import Foundation

struct DeleteMedicationUseCaseImpl: DeleteMedicationUseCaseProtocol {
    private let repository: MedicationRepositoryProtocol
    private let reminderScheduler: RefillReminderSchedulerProtocol

    init(repository: MedicationRepositoryProtocol, reminderScheduler: RefillReminderSchedulerProtocol) {
        self.repository = repository
        self.reminderScheduler = reminderScheduler
    }

    func execute(_ medication: Medication) async throws {
        await reminderScheduler.cancelRefillReminder(for: medication)
        try repository.delete(medication)
    }
}
