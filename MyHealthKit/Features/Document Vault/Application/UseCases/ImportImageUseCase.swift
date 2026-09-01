import Foundation

struct ImportImageUseCaseImpl: ImportImageUseCaseProtocol {
    private let repository: DocumentRepositoryProtocol

    init(repository: DocumentRepositoryProtocol) {
        self.repository = repository
    }

    func execute(data: Data, fileName: String, fileExtension: String) throws -> VaultDocument {
        try repository.importImage(data: data, fileName: fileName, fileExtension: fileExtension)
    }
}
