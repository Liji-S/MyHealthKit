import Foundation

struct SummarizeLabReportUseCaseImpl: SummarizeLabReportUseCaseProtocol {
    private let chatClient: ChatCompletionClientProtocol

    private let systemPrompt = """
    You are summarizing a document for someone who wants a quick, plain-language \
    overview of what it contains. First, determine what kind of document this is \
    (for example: medical/lab report, insurance policy, identification document, \
    contract, resume, or something else), then summarize it appropriately for that type.

    General rules:
    - Write in simple, everyday language, not jargon.
    - Highlight the most important facts, dates, numbers, or values in the document.
    - Keep the summary concise — a few short paragraphs or bullet points.

    If, and only if, the document is a medical or lab report:
    - Explain what each test value means in everyday terms.
    - Point out any values that appear outside the normal reference range, if ranges are shown.
    - Do NOT suggest a diagnosis, medication, dosage, or treatment of any kind.
    - End your response with: "Please discuss these results with your doctor."

    For all other document types, do not add medical disclaimers — just summarize \
    the content clearly and factually.
    """

    init(chatClient: ChatCompletionClientProtocol) {
        self.chatClient = chatClient
    }

    func execute(reportText: String) async throws -> String {
        try await chatClient.complete(systemPrompt: systemPrompt, userMessage: reportText)
    }
}
