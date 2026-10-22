import Foundation
import SwiftData

@Model
final class MedicationRecord {
    @Attribute(.unique) var id: UUID
    var name: String
    var dosage: String
    var initialSupply: Int
    var startDate: Date
    var dailyDoseCount: Int
    var refillThreshold: Int

    init(
        id: UUID,
        name: String,
        dosage: String,
        initialSupply: Int,
        startDate: Date,
        dailyDoseCount: Int,
        refillThreshold: Int
    ) {
        self.id = id
        self.name = name
        self.dosage = dosage
        self.initialSupply = initialSupply
        self.startDate = startDate
        self.dailyDoseCount = dailyDoseCount
        self.refillThreshold = refillThreshold
    }
}
