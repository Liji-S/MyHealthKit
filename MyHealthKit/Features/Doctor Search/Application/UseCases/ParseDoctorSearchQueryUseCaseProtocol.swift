import Foundation

/// Refines a free-text query into a search phrase for Places' text search,
/// e.g. "Arabic speaking dermatologist near me" → searchQuery: "Arabic
/// speaking dermatologist". Keeps qualifiers (language, gender, etc.)
/// intact rather than reducing the query to a bare specialty, since Places'
/// text search can match on that descriptive text.
protocol ParseDoctorSearchQueryUseCaseProtocol {
    func execute(query: String) async throws -> ParsedDoctorSearchFilters
}

struct ParsedDoctorSearchFilters {
    let searchQuery: String?
}
