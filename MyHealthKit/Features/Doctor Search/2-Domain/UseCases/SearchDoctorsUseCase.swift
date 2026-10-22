import Foundation

struct SearchDoctorsUseCaseImpl: SearchDoctorsUseCaseProtocol {
    private let repository: DoctorRepositoryProtocol

    init(repository: DoctorRepositoryProtocol) {
        self.repository = repository
    }

    func execute(criteria: SearchCriteria, forceRefresh: Bool) async throws -> [Doctor] {
        try await repository.search(criteria: criteria, forceRefresh: forceRefresh)
    }
}
