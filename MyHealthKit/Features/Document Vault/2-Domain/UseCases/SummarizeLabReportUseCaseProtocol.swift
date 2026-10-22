import Foundation

/// General-purpose document summarizer — not limited to lab reports. Works on
/// whatever a Vault document actually contains (lab report, insurance policy,
/// ID, contract, etc.) and adapts its response accordingly.
protocol SummarizeLabReportUseCaseProtocol {
    func execute(reportText: String) async throws -> String
}
