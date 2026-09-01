import Foundation
import PDFKit
import UIKit

/// Pure text extraction — no AI involved. Kept separate from summarization so
/// a "this document has no readable text" failure is distinguishable from an
/// AI error.
///
/// For PDFs: tries the embedded text layer first (instant); if that's empty —
/// common for a scanned/photographed document saved as a PDF — falls back to
/// on-device OCR of each rendered page. For raw images: goes straight to OCR.
struct ExtractDocumentTextUseCaseImpl: ExtractDocumentTextUseCaseProtocol {
    private let textRecognizer: ImageTextRecognizer

    init(textRecognizer: ImageTextRecognizer = ImageTextRecognizer()) {
        self.textRecognizer = textRecognizer
    }

    func execute(fileURL: URL, kind: VaultDocumentKind) async throws -> String {
        switch kind {
        case .pdf:
            return try await extractFromPDF(fileURL: fileURL)
        case .image:
            return try await extractFromImage(fileURL: fileURL)
        }
    }

    private func extractFromPDF(fileURL: URL) async throws -> String {
        guard let document = PDFDocument(url: fileURL) else {
            throw ExtractDocumentTextError.couldNotOpenDocument
        }

        if let embeddedText = document.string, !embeddedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return embeddedText
        }

        let ocrText = try await textRecognizer.recognizeText(inPDF: document)
        guard !ocrText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw ExtractDocumentTextError.noTextLayer
        }
        return ocrText
    }

    private func extractFromImage(fileURL: URL) async throws -> String {
        guard let image = UIImage(contentsOfFile: fileURL.path) else {
            throw ExtractDocumentTextError.couldNotOpenDocument
        }
        let ocrText = try await textRecognizer.recognizeText(in: image)
        guard !ocrText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw ExtractDocumentTextError.noTextLayer
        }
        return ocrText
    }
}
