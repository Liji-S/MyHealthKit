import Foundation

struct FetchMedicationsUseCaseImpl: FetchMedicationsUseCaseProtocol {
    private let repository: MedicationRepositoryProtocol

    init(repository: MedicationRepositoryProtocol) {
        self.repository = repository
    }

    func execute() throws -> [Medication] {
        try repository.fetchAll()
    }
}
