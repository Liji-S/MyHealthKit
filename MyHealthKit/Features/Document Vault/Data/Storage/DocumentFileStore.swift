import Foundation

enum DocumentFileStoreError: Error {
    case couldNotAccessSecurityScopedResource
}

/// Copies imported files into the app's sandboxed Documents/Vault directory
/// and resolves stored relative paths back to absolute URLs.
struct DocumentFileStore {
    private let fileManager: FileManager
    private let vaultDirectory: URL

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.vaultDirectory = documentsDirectory.appendingPathComponent("Vault", isDirectory: true)
        try? fileManager.createDirectory(at: vaultDirectory, withIntermediateDirectories: true)
    }

    func copyIntoVault(sourceURL: URL, id: UUID) throws -> String {
        let accessed = sourceURL.startAccessingSecurityScopedResource()
        defer { if accessed { sourceURL.stopAccessingSecurityScopedResource() } }

        let fileExtension = sourceURL.pathExtension
        let relativePath = "\(id.uuidString).\(fileExtension)"
        let destinationURL = vaultDirectory.appendingPathComponent(relativePath)

        if fileManager.fileExists(atPath: destinationURL.path) {
            try fileManager.removeItem(at: destinationURL)
        }
        try fileManager.copyItem(at: sourceURL, to: destinationURL)
        return relativePath
    }

    /// For sources that aren't file-backed, e.g. an image picked via
    /// PhotosPicker, which vends Data rather than a URL.
    func writeIntoVault(data: Data, id: UUID, fileExtension: String) throws -> String {
        let relativePath = "\(id.uuidString).\(fileExtension)"
        let destinationURL = vaultDirectory.appendingPathComponent(relativePath)
        try data.write(to: destinationURL, options: .atomic)
        return relativePath
    }

    func absoluteURL(forRelativePath relativePath: String) -> URL {
        vaultDirectory.appendingPathComponent(relativePath)
    }

    func delete(relativePath: String) throws {
        let url = absoluteURL(forRelativePath: relativePath)
        if fileManager.fileExists(atPath: url.path) {
            try fileManager.removeItem(at: url)
        }
    }
}
