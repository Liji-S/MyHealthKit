import Foundation

enum VaultDocumentKind: String, Codable {
    case pdf
    case image
}

struct VaultDocument: Identifiable, Hashable {
    let id: UUID
    let fileName: String
    let addedAt: Date
    let fileURL: URL
    let kind: VaultDocumentKind
}
