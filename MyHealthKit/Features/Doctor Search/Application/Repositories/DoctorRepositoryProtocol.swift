import Foundation

/// Application-layer output port. No knowledge of SwiftData, URLSession, or
/// Google Places — implemented in the Data layer (Dependency Inversion Principle).
protocol DoctorRepositoryProtocol {
    func search(criteria: SearchCriteria, forceRefresh: Bool) async throws -> [Doctor]
}
