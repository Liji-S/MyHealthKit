import Foundation

/// Abstracts PDF parsing and on-device OCR so Domain/UseCase code never imports
/// PDFKit, Vision or UIKit directly.
///
/// Implementations throw `ExtractDocumentTextError.couldNotOpenDocument` when
/// the file can't be read, and return an empty string when it has no text.
protocol DocumentTextExtractorProtocol {
    /// The PDF's embedded text layer — instant, no OCR.
    func embeddedText(inPDFAt fileURL: URL) throws -> String
    /// OCR of every rendered page of the PDF.
    func recognizedText(inPDFAt fileURL: URL) async throws -> String
    /// OCR of a raw image file.
    func recognizedText(inImageAt fileURL: URL) async throws -> String
}
