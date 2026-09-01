import Foundation
import SwiftData

final class MedicationRepositoryImpl: MedicationRepositoryProtocol {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchAll() throws -> [Medication] {
        let descriptor = FetchDescriptor<MedicationRecord>(
            sortBy: [SortDescriptor(\.name)]
        )
        let records = try modelContext.fetch(descriptor)
        return records.map { toDomain($0) }
    }

    func add(_ medication: Medication) throws {
        let record = MedicationRecord(
            id: medication.id,
            name: medication.name,
            dosage: medication.dosage,
            initialSupply: medication.initialSupply,
            startDate: medication.startDate,
            dailyDoseCount: medication.dailyDoseCount,
            refillThreshold: medication.refillThreshold
        )
        modelContext.insert(record)
        try modelContext.save()
    }

    func update(_ medication: Medication) throws {
        let targetID = medication.id
        let descriptor = FetchDescriptor<MedicationRecord>(
            predicate: #Predicate { $0.id == targetID }
        )
        guard let record = try modelContext.fetch(descriptor).first else { return }
        record.name = medication.name
        record.dosage = medication.dosage
        record.initialSupply = medication.initialSupply
        record.startDate = medication.startDate
        record.dailyDoseCount = medication.dailyDoseCount
        record.refillThreshold = medication.refillThreshold
        try modelContext.save()
    }

    func delete(_ medication: Medication) throws {
        let targetID = medication.id
        let descriptor = FetchDescriptor<MedicationRecord>(
            predicate: #Predicate { $0.id == targetID }
        )
        guard let record = try modelContext.fetch(descriptor).first else { return }
        modelContext.delete(record)
        try modelContext.save()
    }

    private func toDomain(_ record: MedicationRecord) -> Medication {
        Medication(
            id: record.id,
            name: record.name,
            dosage: record.dosage,
            initialSupply: record.initialSupply,
            startDate: record.startDate,
            dailyDoseCount: record.dailyDoseCount,
            refillThreshold: record.refillThreshold
        )
    }
}
