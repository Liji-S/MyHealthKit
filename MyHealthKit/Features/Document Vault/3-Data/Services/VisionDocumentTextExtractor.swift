import PDFKit
import UIKit

/// PDFKit + Vision implementation of `DocumentTextExtractorProtocol`. Runs
/// entirely on-device — no network call.
struct VisionDocumentTextExtractor: DocumentTextExtractorProtocol {
    private let textRecognizer: ImageTextRecognizer

    init(textRecognizer: ImageTextRecognizer = ImageTextRecognizer()) {
        self.textRecognizer = textRecognizer
    }

    func embeddedText(inPDFAt fileURL: URL) throws -> String {
        try openPDF(at: fileURL).string ?? ""
    }

    func recognizedText(inPDFAt fileURL: URL) async throws -> String {
        try await textRecognizer.recognizeText(inPDF: openPDF(at: fileURL))
    }

    func recognizedText(inImageAt fileURL: URL) async throws -> String {
        guard let image = UIImage(contentsOfFile: fileURL.path) else {
            throw ExtractDocumentTextError.couldNotOpenDocument
        }
        return try await textRecognizer.recognizeText(in: image)
    }

    private func openPDF(at fileURL: URL) throws -> PDFDocument {
        guard let document = PDFDocument(url: fileURL) else {
            throw ExtractDocumentTextError.couldNotOpenDocument
        }
        return document
    }
}
