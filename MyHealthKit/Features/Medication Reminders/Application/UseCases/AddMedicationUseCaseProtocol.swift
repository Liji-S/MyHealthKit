import Foundation

protocol AddMedicationUseCaseProtocol {
    func execute(_ medication: Medication) async throws
}
