import Foundation
import Observation

@Observable
final class DocumentVaultViewModel {
    private(set) var documents: [VaultDocument] = []
    private(set) var errorMessage: String?

    private let fetchUseCase: FetchDocumentsUseCaseProtocol
    private let importUseCase: ImportDocumentUseCaseProtocol
    private let importImageUseCase: ImportImageUseCaseProtocol
    private let deleteUseCase: DeleteDocumentUseCaseProtocol

    init(
        fetchUseCase: FetchDocumentsUseCaseProtocol,
        importUseCase: ImportDocumentUseCaseProtocol,
        importImageUseCase: ImportImageUseCaseProtocol,
        deleteUseCase: DeleteDocumentUseCaseProtocol
    ) {
        self.fetchUseCase = fetchUseCase
        self.importUseCase = importUseCase
        self.importImageUseCase = importImageUseCase
        self.deleteUseCase = deleteUseCase
    }

    func loadDocuments() {
        do {
            documents = try fetchUseCase.execute()
            errorMessage = nil
        } catch {
            errorMessage = "Couldn't load your documents."
        }
    }

    func importDocument(from url: URL) {
        do {
            _ = try importUseCase.execute(sourceURL: url)
            loadDocuments()
        } catch {
            errorMessage = "Couldn't import that file."
        }
    }

    func importImage(data: Data, fileName: String, fileExtension: String) {
        do {
            _ = try importImageUseCase.execute(data: data, fileName: fileName, fileExtension: fileExtension)
            loadDocuments()
        } catch {
            errorMessage = "Couldn't import that photo."
        }
    }

    func delete(_ document: VaultDocument) {
        do {
            try deleteUseCase.execute(document)
            loadDocuments()
        } catch {
            errorMessage = "Couldn't delete that document."
        }
    }
}
