import Foundation
import Observation

@Observable
final class MedicationRemindersViewModel {
    private(set) var medications: [Medication] = []
    private(set) var errorMessage: String?

    private let fetchUseCase: FetchMedicationsUseCaseProtocol
    private let addUseCase: AddMedicationUseCaseProtocol
    private let updateUseCase: UpdateMedicationUseCaseProtocol
    private let deleteUseCase: DeleteMedicationUseCaseProtocol

    init(
        fetchUseCase: FetchMedicationsUseCaseProtocol,
        addUseCase: AddMedicationUseCaseProtocol,
        updateUseCase: UpdateMedicationUseCaseProtocol,
        deleteUseCase: DeleteMedicationUseCaseProtocol
    ) {
        self.fetchUseCase = fetchUseCase
        self.addUseCase = addUseCase
        self.updateUseCase = updateUseCase
        self.deleteUseCase = deleteUseCase
    }

    func loadMedications() {
        do {
            medications = try fetchUseCase.execute()
            errorMessage = nil
        } catch {
            errorMessage = "Couldn't load your medications."
        }
    }

    /// Returns false (and does not save) if a medication with this name already exists.
    @discardableResult
    func addMedication(
        name: String,
        dosage: String,
        currentSupply: Int,
        dailyDoseCount: Int,
        refillThreshold: Int
    ) async -> Bool {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !isDuplicateName(trimmedName, excluding: nil) else { return false }

        let medication = Medication(
            id: UUID(),
            name: name,
            dosage: dosage,
            initialSupply: currentSupply,
            startDate: Calendar.current.startOfDay(for: Date()),
            dailyDoseCount: dailyDoseCount,
            refillThreshold: refillThreshold
        )
        do {
            try await addUseCase.execute(medication)
            loadMedications()
            return true
        } catch {
            errorMessage = "Couldn't add that medication."
            return false
        }
    }

    /// Returns false (and does not save) if another medication already uses this name.
    @discardableResult
    func updateMedication(
        _ original: Medication,
        name: String,
        dosage: String,
        currentSupply: Int,
        dailyDoseCount: Int,
        refillThreshold: Int
    ) async -> Bool {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !isDuplicateName(trimmedName, excluding: original.id) else { return false }

        let updated = Medication(
            id: original.id,
            name: name,
            dosage: dosage,
            initialSupply: currentSupply,
            startDate: Calendar.current.startOfDay(for: Date()),
            dailyDoseCount: dailyDoseCount,
            refillThreshold: refillThreshold
        )
        do {
            try await updateUseCase.execute(updated)
            loadMedications()
            return true
        } catch {
            errorMessage = "Couldn't update that medication."
            return false
        }
    }

    func delete(_ medication: Medication) async {
        do {
            try await deleteUseCase.execute(medication)
            loadMedications()
        } catch {
            errorMessage = "Couldn't delete that medication."
        }
    }

    private func isDuplicateName(_ name: String, excluding excludedID: UUID?) -> Bool {
        medications.contains {
            $0.id != excludedID && $0.name.localizedCaseInsensitiveCompare(name) == .orderedSame
        }
    }
}
