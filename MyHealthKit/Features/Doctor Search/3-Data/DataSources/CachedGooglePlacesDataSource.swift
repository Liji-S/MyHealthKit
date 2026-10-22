import Foundation

/// Decorates a GooglePlacesDataSourceProtocol with a 24h disk cache, so repeat
/// searches in the same area/radius don't re-hit the Places API every time.
final class CachedGooglePlacesDataSource: GooglePlacesDataSourceProtocol {
    private let wrapped: GooglePlacesDataSourceProtocol
    private let cache: PlacesSearchCache
    private let logger: AppLoggerProtocol

    init(wrapping wrapped: GooglePlacesDataSourceProtocol, cache: PlacesSearchCache, logger: AppLoggerProtocol) {
        self.wrapped = wrapped
        self.cache = cache
        self.logger = logger
    }

    func searchMedicalFacilities(
        specialty: String?,
        latitude: Double,
        longitude: Double,
        radiusInMeters: Double,
        forceRefresh: Bool
    ) async throws -> [Doctor] {
        let key = PlacesSearchCacheKey(specialty: specialty, latitude: latitude, longitude: longitude, radiusInMeters: radiusInMeters)
        var servedFromCache = true
        let results = try await cache.results(for: key, bypassCache: forceRefresh) { [wrapped] in
            servedFromCache = false
            return try await wrapped.searchMedicalFacilities(
                specialty: specialty,
                latitude: latitude,
                longitude: longitude,
                radiusInMeters: radiusInMeters,
                forceRefresh: forceRefresh
            )
        }
        logger.debug(servedFromCache ? "Places cache hit for \(key.stableIdentifier)" : "Places cache miss, fetched \(results.count) results")
        return results
    }
}
