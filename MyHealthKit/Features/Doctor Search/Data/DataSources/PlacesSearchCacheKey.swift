import Foundation

/// Buckets location to a coarse grid (~500m) so GPS jitter between searches in
/// the same spot still hits the cache instead of missing on tiny coordinate drift.
struct PlacesSearchCacheKey: Hashable {
    private let latitudeBucket: Int
    private let longitudeBucket: Int
    private let radiusBucket: Int

    init(latitude: Double, longitude: Double, radiusInMeters: Double) {
        // ~0.0045 degrees latitude ≈ 500m.
        let gridSize = 0.0045
        latitudeBucket = Int((latitude / gridSize).rounded())
        longitudeBucket = Int((longitude / gridSize).rounded())
        radiusBucket = Int((radiusInMeters / 1000).rounded())
    }

    /// Stable across app launches, unlike Swift's Hasher (randomly seeded per
    /// process) — required for a filename that needs to be found again after
    /// the app restarts.
    var stableIdentifier: String {
        "\(latitudeBucket)_\(longitudeBucket)_\(radiusBucket)"
    }
}
