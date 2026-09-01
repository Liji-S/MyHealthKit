import Foundation

protocol ImageCacheProtocol {
    func image(for url: URL, headers: [String: String]) async throws -> Data
}

extension ImageCacheProtocol {
    func image(for url: URL) async throws -> Data {
        try await image(for: url, headers: [:])
    }
}
