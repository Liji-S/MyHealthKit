import Foundation

/// Response body shared by `places:searchNearby` and `places:searchText`.
nonisolated struct PlacesSearchResponseDTO: Decodable, Sendable {
    let places: [PlaceDTO]
}
