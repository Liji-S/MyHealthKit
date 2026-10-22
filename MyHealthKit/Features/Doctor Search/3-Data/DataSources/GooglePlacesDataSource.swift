import Foundation

enum GooglePlacesDataSourceError: Error {
    case invalidResponse
    case requestFailed(statusCode: Int)
}

final class GooglePlacesDataSourceImpl: GooglePlacesDataSourceProtocol {
    private let apiKey: String
    private let session: URLSession
    private let nearbyEndpoint = URL(string: "https://places.googleapis.com/v1/places:searchNearby")!
    private let textSearchEndpoint = URL(string: "https://places.googleapis.com/v1/places:searchText")!
    private let photoBaseURL = URL(string: "https://places.googleapis.com/v1/")!

    private static let fieldMask = [
        "places.id", "places.displayName", "places.formattedAddress", "places.location",
        "places.internationalPhoneNumber", "places.rating", "places.userRatingCount",
        "places.websiteUri", "places.photos"
    ].joined(separator: ",")

    init(apiKey: String, session: URLSession = .shared) {
        self.apiKey = apiKey
        self.session = session
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
        var request = baseRequest(url: nearbyEndpoint)
        let body = NearbySearchRequestBody(
            includedTypes: ["doctor", "hospital", "pharmacy"],
            maxResultCount: 20,
            locationRestriction: .init(
                circle: .init(
                    center: .init(latitude: latitude, longitude: longitude),
                    radius: radiusInMeters
                )
            )
        )
        request.httpBody = try JSONEncoder().encode(body)
        let places = try await send(request)
        return places.map { $0.toDomain(specialty: "General", apiKey: apiKey, photoBaseURL: photoBaseURL) }
    }

    private func searchByText(specialty: String, latitude: Double, longitude: Double, radiusInMeters: Double) async throws -> [Doctor] {
        var request = baseRequest(url: textSearchEndpoint)
        let body = TextSearchRequestBody(
            textQuery: specialty,
            maxResultCount: 20,
            locationBias: .init(
                circle: .init(
                    center: .init(latitude: latitude, longitude: longitude),
                    radius: radiusInMeters
                )
            )
        )
        request.httpBody = try JSONEncoder().encode(body)
        let places = try await send(request)
        return places.map { $0.toDomain(specialty: specialty, apiKey: apiKey, photoBaseURL: photoBaseURL) }
    }

    private func baseRequest(url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "X-Goog-Api-Key")
        // Required for iOS-app-restricted keys — Google's server verifies the
        // calling app's bundle ID against the key's restriction using this header.
        request.setValue(Bundle.main.bundleIdentifier, forHTTPHeaderField: "X-Ios-Bundle-Identifier")
        request.setValue(Self.fieldMask, forHTTPHeaderField: "X-Goog-FieldMask")
        return request
    }

    private func send(_ request: URLRequest) async throws -> [PlaceDTO] {
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GooglePlacesDataSourceError.invalidResponse
        }
        guard httpResponse.statusCode == 200 else {
            throw GooglePlacesDataSourceError.requestFailed(statusCode: httpResponse.statusCode)
        }
        let decoded = try JSONDecoder().decode(NearbySearchResponse.self, from: data)
        return decoded.places
    }
}

// MARK: - Request/Response DTOs (Places API v1 "New")

private struct NearbySearchRequestBody: Encodable {
    let includedTypes: [String]
    let maxResultCount: Int
    let locationRestriction: LocationRestriction

    struct LocationRestriction: Encodable {
        let circle: Circle
    }
    struct Circle: Encodable {
        let center: Center
        let radius: Double
    }
    struct Center: Encodable {
        let latitude: Double
        let longitude: Double
    }
}

private struct TextSearchRequestBody: Encodable {
    let textQuery: String
    let maxResultCount: Int
    let locationBias: LocationBias

    struct LocationBias: Encodable {
        let circle: Circle
    }
    struct Circle: Encodable {
        let center: Center
        let radius: Double
    }
    struct Center: Encodable {
        let latitude: Double
        let longitude: Double
    }
}

private struct NearbySearchResponse: Decodable {
    let places: [PlaceDTO]
}

private struct PlaceDTO: Decodable {
    let id: String
    let displayName: DisplayName?
    let formattedAddress: String?
    let location: Location?
    let internationalPhoneNumber: String?
    let rating: Double?
    let userRatingCount: Int?
    let websiteUri: String?
    let photos: [PhotoDTO]?

    struct DisplayName: Decodable { let text: String }
    struct Location: Decodable { let latitude: Double; let longitude: Double }
    struct PhotoDTO: Decodable { let name: String }

    func toDomain(specialty: String, apiKey: String, photoBaseURL: URL) -> Doctor {
        Doctor(
            id: id,
            name: displayName?.text ?? "Unknown",
            specialty: specialty,
            latitude: location?.latitude ?? 0,
            longitude: location?.longitude ?? 0,
            phone: internationalPhoneNumber ?? "",
            address: formattedAddress ?? "",
            rating: rating,
            userRatingCount: userRatingCount,
            websiteURL: websiteUri.flatMap { URL(string: $0) },
            photoURL: photoURL(apiKey: apiKey, photoBaseURL: photoBaseURL)
        )
    }

    private func photoURL(apiKey: String, photoBaseURL: URL) -> URL? {
        guard let photoName = photos?.first?.name else { return nil }
        var components = URLComponents(url: photoBaseURL.appendingPathComponent("\(photoName)/media"), resolvingAgainstBaseURL: false)
        components?.queryItems = [
            URLQueryItem(name: "maxWidthPx", value: "400"),
            URLQueryItem(name: "key", value: apiKey)
        ]
        return components?.url
    }
}
