import Foundation

/// Actor-isolated disk cache for Places search results, keyed by a coarse
/// location/radius bucket (see PlacesSearchCacheKey) with a 24h TTL.
///
/// Same reentrancy discipline as DiskImageCache: in-flight fetches are
/// registered synchronously before any `await`, so concurrent callers for the
/// same bucket join one fetch instead of issuing duplicate Places requests.
actor PlacesSearchCache {
    private let cacheDirectory: URL
    private let ttl: TimeInterval

    private var inFlightTasks: [PlacesSearchCacheKey: Task<[Doctor], Error>] = [:]

    // FileManager.default is documented as safe to use from any thread, so we
    // reference it directly rather than storing an instance as actor state —
    // avoids crossing a non-Sendable type across the actor boundary.
    private var fileManager: FileManager { .default }

    init(ttl: TimeInterval = 60 * 60 * 24) {
        self.ttl = ttl
        let cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        self.cacheDirectory = cachesDirectory.appendingPathComponent("PlacesSearchCache", isDirectory: true)
        try? FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }

    func results(
        for key: PlacesSearchCacheKey,
        bypassCache: Bool = false,
        fetch: @escaping () async throws -> [Doctor]
    ) async throws -> [Doctor] {
        if !bypassCache, let cached = readFromDisk(key: key) {
            return cached
        }

        if let existingTask = inFlightTasks[key] {
            return try await existingTask.value
        }

        let task = Task<[Doctor], Error> {
            try await fetch()
        }
        inFlightTasks[key] = task
        defer { inFlightTasks[key] = nil }

        let doctors = try await task.value
        writeToDisk(key: key, doctors: doctors)
        return doctors
    }

    private func readFromDisk(key: PlacesSearchCacheKey) -> [Doctor]? {
        let fileURL = diskLocation(for: key)
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        guard let entry = try? JSONDecoder().decode(CacheEntry.self, from: data) else { return nil }
        guard Date().timeIntervalSince(entry.storedAt) < ttl else { return nil }
        return entry.doctors
    }

    private func writeToDisk(key: PlacesSearchCacheKey, doctors: [Doctor]) {
        let entry = CacheEntry(storedAt: Date(), doctors: doctors)
        guard let data = try? JSONEncoder().encode(entry) else { return }
        try? data.write(to: diskLocation(for: key), options: .atomic)
    }

    private func diskLocation(for key: PlacesSearchCacheKey) -> URL {
        cacheDirectory.appendingPathComponent(key.stableIdentifier)
    }

    private struct CacheEntry: Codable {
        let storedAt: Date
        let doctors: [Doctor]
    }
}
