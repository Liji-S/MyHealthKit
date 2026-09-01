import Foundation

enum GooglePlacesDataSourceError: Error {
    case invalidResponse
    case requestFailed(statusCode: Int)
}

final class GooglePlacesDataSourceImpl: GooglePlacesDataSourceProtocol {
    private let apiKey: String
    private let session: URLSession
    private let endpoint = URL(string: "https://places.googleapis.com/v1/places:searchNearby")!
    private let photoBaseURL = URL(string: "https://places.googleapis.com/v1/")!

    init(apiKey: String, session: URLSession = .shared) {
        self.apiKey = apiKey
        self.session = session
    }

    func nearbyMedicalFacilities(
        latitude: Double,
        longitude: Double,
        radiusInMeters: Double,
        forceRefresh: Bool
    ) async throws -> [Doctor] {
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "X-Goog-Api-Key")
        // Required for iOS-app-restricted keys — Google's server verifies the
        // calling app's bundle ID against the key's restriction using this header.
        request.setValue(Bundle.main.bundleIdentifier, forHTTPHeaderField: "X-Ios-Bundle-Identifier")
        request.setValue(
            [
                "places.id", "places.displayName", "places.formattedAddress", "places.location",
                "places.internationalPhoneNumber", "places.rating", "places.userRatingCount",
                "places.websiteUri", "places.photos"
            ].joined(separator: ","),
            forHTTPHeaderField: "X-Goog-FieldMask"
        )

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

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GooglePlacesDataSourceError.invalidResponse
        }
        guard httpResponse.statusCode == 200 else {
            throw GooglePlacesDataSourceError.requestFailed(statusCode: httpResponse.statusCode)
        }

        let decoded = try JSONDecoder().decode(NearbySearchResponse.self, from: data)
        return decoded.places.map { $0.toDomain(apiKey: apiKey, photoBaseURL: photoBaseURL) }
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

    func toDomain(apiKey: String, photoBaseURL: URL) -> Doctor {
        Doctor(
            id: id,
            name: displayName?.text ?? "Unknown",
            specialty: "General",
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
