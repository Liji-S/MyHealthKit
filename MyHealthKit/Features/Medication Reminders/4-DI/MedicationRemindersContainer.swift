import Foundation
import SwiftData

@MainActor
final class MedicationRemindersContainer {
    private let modelContext: ModelContext

    private lazy var reminderScheduler: RefillReminderSchedulerProtocol = UserNotificationsRefillScheduler()

    private lazy var medicationRepository: MedicationRepositoryProtocol = MedicationRepositoryImpl(
        modelContext: modelContext
    )

    lazy var fetchMedicationsUseCase: FetchMedicationsUseCaseProtocol = FetchMedicationsUseCaseImpl(
        repository: medicationRepository
    )

    private lazy var addMedicationUseCase: AddMedicationUseCaseProtocol = AddMedicationUseCaseImpl(
        repository: medicationRepository,
        reminderScheduler: reminderScheduler
    )

    private lazy var updateMedicationUseCase: UpdateMedicationUseCaseProtocol = UpdateMedicationUseCaseImpl(
        repository: medicationRepository,
        reminderScheduler: reminderScheduler
    )

    private lazy var deleteMedicationUseCase: DeleteMedicationUseCaseProtocol = DeleteMedicationUseCaseImpl(
        repository: medicationRepository,
        reminderScheduler: reminderScheduler
    )

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func makeMedicationRemindersViewModel() -> MedicationRemindersViewModel {
        MedicationRemindersViewModel(
            fetchUseCase: fetchMedicationsUseCase,
            addUseCase: addMedicationUseCase,
            updateUseCase: updateMedicationUseCase,
            deleteUseCase: deleteMedicationUseCase
        )
    }
}
