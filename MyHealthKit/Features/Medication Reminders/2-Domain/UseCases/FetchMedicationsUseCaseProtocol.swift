import Foundation

protocol FetchMedicationsUseCaseProtocol {
    func execute() throws -> [Medication]
}
