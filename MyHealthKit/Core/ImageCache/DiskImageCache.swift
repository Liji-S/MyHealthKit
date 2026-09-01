import CryptoKit
import Foundation

/// Actor-isolated so concurrent reads from multiple views can't race on the
/// in-memory index or the in-flight task table.
///
/// Reentrancy note: a plain "check cache, then await the network, then store"
/// sequence is NOT safe inside an actor — the `await` is a suspension point,
/// so a second caller for the same URL can enter the actor while the first is
/// still downloading, triggering a duplicate fetch. We close that window by
/// registering the in-flight Task synchronously (no await) before any
/// suspension happens, so concurrent callers for the same URL join the same
/// task instead of starting their own.
actor DiskImageCache: ImageCacheProtocol {
    private let session: URLSession
    private let cacheDirectory: URL

    private var inFlightTasks: [URL: Task<Data, Error>] = [:]

    // FileManager.default is documented as safe to use from any thread, so we
    // reference it directly rather than storing an instance as actor state —
    // avoids crossing a non-Sendable type across the actor boundary.
    private var fileManager: FileManager { .default }

    init(session: URLSession = .shared) {
        self.session = session
        let cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        self.cacheDirectory = cachesDirectory.appendingPathComponent("ImageCache", isDirectory: true)
        try? FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }

    func image(for url: URL, headers: [String: String]) async throws -> Data {
        let fileURL = diskLocation(for: url)

        if let cached = try? Data(contentsOf: fileURL) {
            return cached
        }

        if let existingTask = inFlightTasks[url] {
            return try await existingTask.value
        }

        let task = Task<Data, Error> { [session] in
            var request = URLRequest(url: url)
            for (field, value) in headers {
                request.setValue(value, forHTTPHeaderField: field)
            }
            let (data, _) = try await session.data(for: request)
            return data
        }
        inFlightTasks[url] = task
        defer { inFlightTasks[url] = nil }

        let data = try await task.value
        try? data.write(to: fileURL, options: .atomic)
        return data
    }

    private func diskLocation(for url: URL) -> URL {
        let hash = SHA256.hash(data: Data(url.absoluteString.utf8))
        let fileName = hash.map { String(format: "%02x", $0) }.joined()
        return cacheDirectory.appendingPathComponent(fileName)
    }
}
