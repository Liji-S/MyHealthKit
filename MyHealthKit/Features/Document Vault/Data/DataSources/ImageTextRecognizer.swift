import PDFKit
import UIKit
import Vision

/// On-device OCR (Vision framework) — no network call. Used as a fallback for
/// PDFs with no embedded text layer (a photographed document saved as a PDF),
/// and directly for raw image documents.
struct ImageTextRecognizer {
    func recognizeText(inPDF document: PDFDocument) async throws -> String {
        var recognizedPages: [String] = []

        for pageIndex in 0..<document.pageCount {
            guard let page = document.page(at: pageIndex) else { continue }
            let image = renderImage(for: page)
            let pageText = try await recognizeText(in: image)
            if !pageText.isEmpty {
                recognizedPages.append(pageText)
            }
        }

        return recognizedPages.joined(separator: "\n\n")
    }

    func recognizeText(in image: UIImage) async throws -> String {
        guard let cgImage = image.cgImage else { return "" }

        return try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                let observations = request.results as? [VNRecognizedTextObservation] ?? []
                let text = observations
                    .compactMap { $0.topCandidates(1).first?.string }
                    .joined(separator: "\n")
                continuation.resume(returning: text)
            }
            request.recognitionLevel = .accurate

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    private func renderImage(for page: PDFPage) -> UIImage {
        let pageBounds = page.bounds(for: .mediaBox)
        let renderer = UIGraphicsImageRenderer(size: pageBounds.size)
        return renderer.image { context in
            UIColor.white.set()
            context.fill(pageBounds)
            context.cgContext.translateBy(x: 0, y: pageBounds.size.height)
            context.cgContext.scaleBy(x: 1, y: -1)
            page.draw(with: .mediaBox, to: context.cgContext)
        }
    }
}
