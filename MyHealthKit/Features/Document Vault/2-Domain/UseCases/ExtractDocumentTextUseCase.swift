import Foundation

/// Pure text extraction — no AI involved. Kept separate from summarization so
/// a "this document has no readable text" failure is distinguishable from an
/// AI error.
///
/// For PDFs: tries the embedded text layer first (instant); if that's empty —
/// common for a scanned/photographed document saved as a PDF — falls back to
/// on-device OCR of each rendered page. For raw images: goes straight to OCR.
struct ExtractDocumentTextUseCaseImpl: ExtractDocumentTextUseCaseProtocol {
    private let textExtractor: DocumentTextExtractorProtocol

    init(textExtractor: DocumentTextExtractorProtocol) {
        self.textExtractor = textExtractor
    }

    func execute(fileURL: URL, kind: VaultDocumentKind) async throws -> String {
        switch kind {
        case .pdf:
            return try await extractFromPDF(fileURL: fileURL)
        case .image:
            return try nonEmpty(await textExtractor.recognizedText(inImageAt: fileURL))
        }
    }

    private func extractFromPDF(fileURL: URL) async throws -> String {
        let embeddedText = try textExtractor.embeddedText(inPDFAt: fileURL)
        if !isBlank(embeddedText) {
            return embeddedText
        }
        return try nonEmpty(await textExtractor.recognizedText(inPDFAt: fileURL))
    }

    private func nonEmpty(_ text: String) throws -> String {
        guard !isBlank(text) else {
            throw ExtractDocumentTextError.noTextLayer
        }
        return text
    }

    private func isBlank(_ text: String) -> Bool {
        text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
