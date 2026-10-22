import Foundation

struct Doctor: Identifiable, Hashable, Codable {
    /// Google Places' own place ID (stable across requests) so SwiftUI's
    /// ForEach identity doesn't churn every time results are re-fetched or
    /// re-decoded from cache — a fresh random ID per parse broke tap handling
    /// on list rows whose views got needlessly recycled.
    let id: String
    let name: String
    let specialty: String
    let latitude: Double
    let longitude: Double
    let phone: String
    let address: String
    let rating: Double?
    let userRatingCount: Int?
    let websiteURL: URL?
    let photoURL: URL?
}
