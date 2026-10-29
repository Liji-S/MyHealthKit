import Foundation
import NetworkKit

/// `POST places:searchNearby` — medical facilities within a radius.
nonisolated struct SearchNearbyPlacesEndpoint: Endpoint {
    typealias Response = PlacesSearchResponseDTO
    let request: NearbySearchRequestDTO

    var path: String { "places:searchNearby" }
    var method: HTTPMethod { .post }
    var headers: HTTPHeaders { [GooglePlacesFieldMask.headerName: GooglePlacesFieldMask.searchResults] }
    var body: RequestBody? { .json(request) }
    /// A search only reads data, so it is safe to retry despite being a POST.
    var retryPolicy: (any RetryPolicy)? { ExponentialBackoffRetryPolicy(retriesNonIdempotentRequests: true) }
}
