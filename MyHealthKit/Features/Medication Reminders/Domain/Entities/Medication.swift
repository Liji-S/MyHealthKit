import Foundation

struct Medication: Identifiable, Hashable {
    let id: UUID
    var name: String
    var dosage: String
    var initialSupply: Int
    var startDate: Date
    var dailyDoseCount: Int
    var refillThreshold: Int

    /// Supply is never persisted directly — it's derived from how many days have
    /// elapsed since startDate, so it stays correct without any background task.
    func remainingSupply(asOf date: Date = Date()) -> Int {
        let daysElapsed = Calendar.current.dateComponents([.day], from: startDate, to: date).day ?? 0
        let consumed = max(0, daysElapsed) * dailyDoseCount
        return max(0, initialSupply - consumed)
    }

    func isLowOnSupply(asOf date: Date = Date()) -> Bool {
        remainingSupply(asOf: date) <= refillThreshold
    }

    /// The date remainingSupply first reaches the refill threshold — nil if the
    /// medication has no daily consumption (dailyDoseCount == 0) or is already low.
    var refillDueDate: Date? {
        guard dailyDoseCount > 0 else { return nil }
        let dosesUntilThreshold = initialSupply - refillThreshold
        guard dosesUntilThreshold > 0 else { return nil }
        let daysUntilThreshold = Int(ceil(Double(dosesUntilThreshold) / Double(dailyDoseCount)))
        return Calendar.current.date(byAdding: .day, value: daysUntilThreshold, to: startDate)
    }
    
}
