import Foundation
import NetworkKit

/// `POST places:searchText` — places matching a specialty, biased towards a location.
nonisolated struct SearchPlacesByTextEndpoint: Endpoint {
    typealias Response = PlacesSearchResponseDTO
    let request: TextSearchRequestDTO

    var path: String { "places:searchText" }
    var method: HTTPMethod { .post }
    var headers: HTTPHeaders { [GooglePlacesFieldMask.headerName: GooglePlacesFieldMask.searchResults] }
    var body: RequestBody? { .json(request) }
    /// A search only reads data, so it is safe to retry despite being a POST.
    var retryPolicy: (any RetryPolicy)? { ExponentialBackoffRetryPolicy(retriesNonIdempotentRequests: true) }
}
