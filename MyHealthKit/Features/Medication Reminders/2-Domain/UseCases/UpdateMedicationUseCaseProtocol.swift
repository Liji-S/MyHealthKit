import Foundation

protocol UpdateMedicationUseCaseProtocol {
    func execute(_ medication: Medication) async throws
}
