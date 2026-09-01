import Foundation

struct ImportDocumentUseCaseImpl: ImportDocumentUseCaseProtocol {
    private let repository: DocumentRepositoryProtocol

    init(repository: DocumentRepositoryProtocol) {
        self.repository = repository
    }

    func execute(sourceURL: URL) throws -> VaultDocument {
        try repository.importDocument(from: sourceURL)
    }
}
