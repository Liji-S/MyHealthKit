import Foundation

/// Single Responsibility: orchestrates one search operation, nothing else.
protocol SearchDoctorsUseCaseProtocol {
    func execute(criteria: SearchCriteria, forceRefresh: Bool) async throws -> [Doctor]
}
