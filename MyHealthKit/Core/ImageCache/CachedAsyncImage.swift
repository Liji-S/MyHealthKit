import SwiftUI

enum CachedImagePhase {
    case loading
    case failed
}

/// Drop-in replacement for AsyncImage that persists downloads to disk via
/// ImageCacheProtocol, instead of re-fetching on every appearance.
struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    let url: URL?
    let cache: ImageCacheProtocol
    var headers: [String: String] = [:]
    @ViewBuilder let content: (Image) -> Content
    @ViewBuilder let placeholder: (CachedImagePhase) -> Placeholder

    @State private var uiImage: UIImage?
    @State private var phase: CachedImagePhase = .loading

    var body: some View {
        placeholder(phase)
            .overlay {
                if let uiImage {
                    content(Image(uiImage: uiImage))
                }
            }
            .task(id: url) {
                guard let url else {
                    phase = .failed
                    return
                }
                phase = .loading
                if let data = try? await cache.image(for: url, headers: headers), let loaded = UIImage(data: data) {
                    uiImage = loaded
                } else {
                    phase = .failed
                }
            }
    }
}
