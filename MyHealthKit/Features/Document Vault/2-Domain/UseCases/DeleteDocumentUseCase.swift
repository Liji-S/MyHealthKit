import Foundation

struct DeleteDocumentUseCaseImpl: DeleteDocumentUseCaseProtocol {
    private let repository: DocumentRepositoryProtocol

    init(repository: DocumentRepositoryProtocol) {
        self.repository = repository
    }

    func execute(_ document: VaultDocument) throws {
        try repository.delete(document)
    }
}
