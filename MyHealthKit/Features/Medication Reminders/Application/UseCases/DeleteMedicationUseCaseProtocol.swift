import Foundation

protocol DeleteMedicationUseCaseProtocol {
    func execute(_ medication: Medication) async throws
}
