import Foundation

enum ChatResponseFormat {
    /// Free-form prose. Use for summaries, explanations, anything meant to be
    /// read directly.
    case text
    /// Forces the model to only emit a syntactically valid JSON object. Use
    /// when the caller is going to decode the response into a struct — never
    /// mix with a prompt that asks for prose, since a model constrained to
    /// JSON-only output cannot express a paragraph and will often just return `{}`.
    case json
}

/// Abstracts a chat-completion LLM call so Domain/UseCase code never depends on
/// a specific provider (Ollama, OpenAI, Anthropic, Apple Foundation Models, ...).
protocol ChatCompletionClientProtocol {
    func complete(systemPrompt: String, userMessage: String, responseFormat: ChatResponseFormat) async throws -> String
}

extension ChatCompletionClientProtocol {
    func complete(systemPrompt: String, userMessage: String) async throws -> String {
        try await complete(systemPrompt: systemPrompt, userMessage: userMessage, responseFormat: .text)
    }
}
