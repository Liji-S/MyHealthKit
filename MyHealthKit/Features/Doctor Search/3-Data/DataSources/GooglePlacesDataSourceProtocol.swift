import Foundation

protocol GooglePlacesDataSourceProtocol {
    /// Searches for medical facilities near the given location. When
    /// `specialty` is non-nil/non-empty, performs a text search for that
    /// specialty (e.g. "dermatologist") biased to the location instead of a
    /// generic nearby-facilities lookup.
    func searchMedicalFacilities(
        specialty: String?,
        latitude: Double,
        longitude: Double,
        radiusInMeters: Double,
        forceRefresh: Bool
    ) async throws -> [Doctor]
}
