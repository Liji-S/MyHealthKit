import Foundation

/// Request body for Places API (New) `places:searchNearby`.
nonisolated struct NearbySearchRequestDTO: Encodable, Sendable {
    let includedTypes: [String]
    let maxResultCount: Int
    let locationRestriction: LocationRestriction

    struct LocationRestriction: Encodable, Sendable {
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
