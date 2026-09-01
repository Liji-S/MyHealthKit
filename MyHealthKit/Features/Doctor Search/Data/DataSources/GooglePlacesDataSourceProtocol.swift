import Foundation

protocol GooglePlacesDataSourceProtocol {
    func nearbyMedicalFacilities(
        latitude: Double,
        longitude: Double,
        radiusInMeters: Double,
        forceRefresh: Bool
    ) async throws -> [Doctor]
}
