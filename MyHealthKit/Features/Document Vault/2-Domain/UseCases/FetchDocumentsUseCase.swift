import Foundation

struct FetchDocumentsUseCaseImpl: FetchDocumentsUseCaseProtocol {
    private let repository: DocumentRepositoryProtocol

    init(repository: DocumentRepositoryProtocol) {
        self.repository = repository
    }

    func execute() throws -> [VaultDocument] {
        try repository.fetchAll()
    }
}
