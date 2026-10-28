import Foundation
import NetworkKit

extension NetworkEnvironment {
    /// Places API (New). The API key and bundle ID go on every request.
    static func googlePlaces(apiKey: String) -> NetworkEnvironment {
        var headers: HTTPHeaders = ["X-Goog-Api-Key": apiKey]
        // Required for iOS-app-restricted keys — Google's server verifies the
        // calling app's bundle ID against the key's restriction using this header.
        if let bundleIdentifier = Bundle.main.bundleIdentifier {
            headers["X-Ios-Bundle-Identifier"] = bundleIdentifier
        }
        #if DEBUG
        let logLevel: NetworkLogLevel = .basic
        #else
        let logLevel: NetworkLogLevel = .off
        #endif
        return NetworkEnvironment(
            name: "google-places",
            baseURL: URL(string: "https://places.googleapis.com/v1")!,
            defaultHeaders: headers,
            logLevel: logLevel
        )
    }
}
