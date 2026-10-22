import Foundation
import Observation

enum SummaryState {
    case idle
    case extracting
    case summarizing
    case result(String)
    case failed(String)
}

@Observable
final class SummaryViewModel {
    private(set) var state: SummaryState = .idle

    private let extractTextUseCase: ExtractDocumentTextUseCaseProtocol
    private let summarizeUseCase: SummarizeLabReportUseCaseProtocol

    init(
        extractTextUseCase: ExtractDocumentTextUseCaseProtocol,
        summarizeUseCase: SummarizeLabReportUseCaseProtocol
    ) {
        self.extractTextUseCase = extractTextUseCase
        self.summarizeUseCase = summarizeUseCase
    }

    func summarize(fileURL: URL, kind: VaultDocumentKind) async {
        state = .extracting

        let text: String
        do {
            text = try await extractTextUseCase.execute(fileURL: fileURL, kind: kind)
        } catch ExtractDocumentTextError.noTextLayer {
            state = .failed("This document doesn't contain readable text, so it can't be summarized.")
            return
        } catch {
            state = .failed("Couldn't open this document.")
            return
        }

        state = .summarizing
        do {
            let summary = try await summarizeUseCase.execute(reportText: text)
            state = .result(summary)
        } catch {
            state = .failed("Couldn't generate a summary right now. Please try again.")
        }
    }
}
