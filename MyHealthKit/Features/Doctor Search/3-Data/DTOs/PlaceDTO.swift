import Foundation

/// A place as returned by Places API (New), limited to the fields in `GooglePlacesFieldMask`.
nonisolated struct PlaceDTO: Decodable, Sendable {
    let id: String
    let displayName: DisplayName?
    let formattedAddress: String?
    let location: Location?
    let internationalPhoneNumber: String?
    let rating: Double?
    let userRatingCount: Int?
    let websiteUri: String?
    let photos: [PhotoDTO]?

    struct DisplayName: Decodable, Sendable { let text: String }
    struct Location: Decodable, Sendable { let latitude: Double; let longitude: Double }
    struct PhotoDTO: Decodable, Sendable { let name: String }

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
