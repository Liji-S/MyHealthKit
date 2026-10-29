import Foundation

/// A place as returned by Places API (New), limited to the fields in `GooglePlacesFieldMask`.
nonisolated struct PlaceDTO: Decodable, Sendable {
    let id: String
    let displayName: DisplayName?
    let primaryType: String?
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
            kind: kind,
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

    /// Individual practitioners are listed with primary type `doctor`; hospitals
    /// and clinics usually carry `doctor` only as a secondary type, so the
    /// primary type is what tells them apart.
    private var kind: ProviderKind {
        switch primaryType {
        case "doctor":
            return .doctor
        case let type? where type.contains("hospital"):
            return .hospital
        case "pharmacy", "drugstore":
            return .pharmacy
        default:
            return .clinic
        }
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
