import Foundation
import NetworkKit

final class GooglePlacesDataSourceImpl: GooglePlacesDataSourceProtocol {
    private let client: NetworkClientProtocol
    /// Still needed here: photo URLs carry the key as a query parameter.
    private let apiKey: String
    private let photoBaseURL = URL(string: "https://places.googleapis.com/v1/")!
    private static let maxResultCount = 20

    init(client: NetworkClientProtocol, apiKey: String) {
        self.client = client
        self.apiKey = apiKey
    }

    func searchMedicalFacilities(
        specialty: String?,
        latitude: Double,
        longitude: Double,
        radiusInMeters: Double,
        forceRefresh: Bool
    ) async throws -> [Doctor] {
        let trimmedSpecialty = specialty?.trimmingCharacters(in: .whitespacesAndNewlines)
        if let trimmedSpecialty, !trimmedSpecialty.isEmpty {
            return try await searchByText(
                specialty: trimmedSpecialty,
                latitude: latitude,
                longitude: longitude,
                radiusInMeters: radiusInMeters
            )
        }
        return try await searchNearby(latitude: latitude, longitude: longitude, radiusInMeters: radiusInMeters)
    }

    private func searchNearby(latitude: Double, longitude: Double, radiusInMeters: Double) async throws -> [Doctor] {
        let request = NearbySearchRequestDTO(
            includedTypes: ["doctor", "hospital", "pharmacy"],
            maxResultCount: Self.maxResultCount,
            locationRestriction: .init(
                circle: .init(
                    center: .init(latitude: latitude, longitude: longitude),
                    radius: radiusInMeters
                )
            )
        )
        let response = try await client.request(SearchNearbyPlacesEndpoint(request: request))
        return response.places.map { $0.toDomain(specialty: "General", apiKey: apiKey, photoBaseURL: photoBaseURL) }
    }

    private func searchByText(specialty: String, latitude: Double, longitude: Double, radiusInMeters: Double) async throws -> [Doctor] {
        let request = TextSearchRequestDTO(
            textQuery: specialty,
            maxResultCount: Self.maxResultCount,
            locationBias: .init(
                circle: .init(
                    center: .init(latitude: latitude, longitude: longitude),
                    radius: radiusInMeters
                )
            )
        )
        let response = try await client.request(SearchPlacesByTextEndpoint(request: request))
        return response.places.map { $0.toDomain(specialty: specialty, apiKey: apiKey, photoBaseURL: photoBaseURL) }
    }
}
