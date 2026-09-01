import Foundation

enum ExtractDocumentTextError: Error {
    case noTextLayer
    case couldNotOpenDocument
}

protocol ExtractDocumentTextUseCaseProtocol {
    func execute(fileURL: URL, kind: VaultDocumentKind) async throws -> String
}
