import Foundation

/// Extracts a specialty filter from a free-text query, e.g. "Arabic speaking
/// dermatologist near me" → specialty: "Dermatology".
protocol ParseDoctorSearchQueryUseCaseProtocol {
    func execute(query: String) async throws -> ParsedDoctorSearchFilters
}

struct ParsedDoctorSearchFilters {
    let specialty: String?
}
