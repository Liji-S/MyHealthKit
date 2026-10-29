import Foundation

/// Request body for Places API (New) `places:searchText`.
nonisolated struct TextSearchRequestDTO: Encodable, Sendable {
    let textQuery: String
    /// Place type to restrict results to, e.g. `doctor`. Omitted from the JSON when nil.
    let includedType: String?
    /// When true, only places of `includedType` are returned instead of merely preferred.
    let strictTypeFiltering: Bool?
    let maxResultCount: Int
    let locationBias: LocationBias

    struct LocationBias: Encodable, Sendable {
        let circle: Circle
    }
    struct Circle: Encodable, Sendable {
        let center: Center
        let radius: Double
    }
    struct Center: Encodable, Sendable {
        let latitude: Double
        let longitude: Double
    }
}
