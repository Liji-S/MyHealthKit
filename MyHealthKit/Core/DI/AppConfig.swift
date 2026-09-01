import Foundation

/// Reads secrets from the build configuration (Info.plist / xcconfig), never hardcoded.
enum AppConfig {
    static var googlePlacesAPIKey: String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "GOOGLE_PLACES_API_KEY") as? String, !key.isEmpty else {
            assertionFailure("GOOGLE_PLACES_API_KEY missing from Info.plist / xcconfig")
            return ""
        }
        return key
    }

    /// Simulator can reach the Mac's Ollama server via localhost. A physical device
    /// needs the Mac's LAN IP instead — override OLLAMA_HOST in Secrets.xcconfig.
    /// Stored as host:port only (no scheme) because xcconfig treats "//" as the
    /// start of a comment and silently truncates anything after it.
    static var ollamaBaseURL: URL {
        let raw = Bundle.main.object(forInfoDictionaryKey: "OLLAMA_HOST") as? String
        let host = (raw?.isEmpty == false ? raw! : "localhost:11434")
        let fallback = "http://localhost:11434"
        return URL(string: "http://\(host)") ?? URL(string: fallback)!
    }

    static var ollamaModel: String {
        let raw = Bundle.main.object(forInfoDictionaryKey: "OLLAMA_MODEL") as? String
        return (raw?.isEmpty == false ? raw! : "llama3.1:8b")
    }
}
