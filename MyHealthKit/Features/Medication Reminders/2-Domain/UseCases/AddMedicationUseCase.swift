import Foundation

struct AddMedicationUseCaseImpl: AddMedicationUseCaseProtocol {
    private let repository: MedicationRepositoryProtocol
    private let reminderScheduler: RefillReminderSchedulerProtocol

    init(repository: MedicationRepositoryProtocol, reminderScheduler: RefillReminderSchedulerProtocol) {
        self.repository = repository
        self.reminderScheduler = reminderScheduler
    }

    func execute(_ medication: Medication) async throws {
        try repository.add(medication)
        await reminderScheduler.requestAuthorization()
        await reminderScheduler.scheduleRefillReminder(for: medication)
    }
}
