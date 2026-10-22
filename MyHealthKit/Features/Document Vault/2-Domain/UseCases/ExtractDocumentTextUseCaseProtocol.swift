import Foundation

protocol ExtractDocumentTextUseCaseProtocol {
    func execute(fileURL: URL, kind: VaultDocumentKind) async throws -> String
}
