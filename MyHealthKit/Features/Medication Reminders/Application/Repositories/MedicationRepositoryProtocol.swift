import Foundation

protocol MedicationRepositoryProtocol {
    func fetchAll() throws -> [Medication]
    func add(_ medication: Medication) throws
    func update(_ medication: Medication) throws
    func delete(_ medication: Medication) throws
}
