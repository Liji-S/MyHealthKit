import Foundation

/// The response fields requested from Places API (New). Google bills by the fields asked for,
/// so this lists only what `PlaceDTO` decodes.
nonisolated enum GooglePlacesFieldMask {
    static let headerName = "X-Goog-FieldMask"

    static let searchResults = [
        "places.id", "places.displayName", "places.formattedAddress", "places.location",
        "places.internationalPhoneNumber", "places.rating", "places.userRatingCount",
        "places.websiteUri", "places.photos"
    ].joined(separator: ",")
}
