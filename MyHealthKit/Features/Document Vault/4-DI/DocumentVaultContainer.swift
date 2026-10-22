import Foundation
import SwiftData

@MainActor
final class DocumentVaultContainer {
    private let modelContext: ModelContext
    private let chatCompletionClient: ChatCompletionClientProtocol

    private lazy var fileStore = DocumentFileStore()

    private lazy var documentRepository: DocumentRepositoryProtocol = DocumentRepositoryImpl(
        modelContext: modelContext,
        fileStore: fileStore
    )

    private lazy var fetchDocumentsUseCase: FetchDocumentsUseCaseProtocol = FetchDocumentsUseCaseImpl(
        repository: documentRepository
    )

    private lazy var importDocumentUseCase: ImportDocumentUseCaseProtocol = ImportDocumentUseCaseImpl(
        repository: documentRepository
    )

    private lazy var importImageUseCase: ImportImageUseCaseProtocol = ImportImageUseCaseImpl(
        repository: documentRepository
    )

    private lazy var deleteDocumentUseCase: DeleteDocumentUseCaseProtocol = DeleteDocumentUseCaseImpl(
        repository: documentRepository
    )

    private lazy var documentTextExtractor: DocumentTextExtractorProtocol = VisionDocumentTextExtractor()

    private lazy var extractDocumentTextUseCase: ExtractDocumentTextUseCaseProtocol = ExtractDocumentTextUseCaseImpl(
        textExtractor: documentTextExtractor
    )

    private lazy var summarizeLabReportUseCase: SummarizeLabReportUseCaseProtocol = SummarizeLabReportUseCaseImpl(
        chatClient: chatCompletionClient
    )

    init(modelContext: ModelContext, chatCompletionClient: ChatCompletionClientProtocol) {
        self.modelContext = modelContext
        self.chatCompletionClient = chatCompletionClient
    }

    func makeDocumentVaultViewModel() -> DocumentVaultViewModel {
        DocumentVaultViewModel(
            fetchUseCase: fetchDocumentsUseCase,
            importUseCase: importDocumentUseCase,
            importImageUseCase: importImageUseCase,
            deleteUseCase: deleteDocumentUseCase
        )
    }

    func makeSummaryViewModel() -> SummaryViewModel {
        SummaryViewModel(
            extractTextUseCase: extractDocumentTextUseCase,
            summarizeUseCase: summarizeLabReportUseCase
        )
    }
}
