import Foundation

enum OllamaClientError: Error {
    case invalidResponse
    case requestFailed(statusCode: Int)
}

/// Talks to a locally- or self-hosted Ollama server's /api/chat endpoint.
final class OllamaChatCompletionClient: ChatCompletionClientProtocol {
    private let baseURL: URL
    private let model: String
    private let session: URLSession

    init(baseURL: URL, model: String, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.model = model
        self.session = session
    }

    func complete(systemPrompt: String, userMessage: String, responseFormat: ChatResponseFormat) async throws -> String {
        var request = URLRequest(url: baseURL.appendingPathComponent("api/chat"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ChatRequestBody(
            model: model,
            messages: [
                .init(role: "system", content: systemPrompt),
                .init(role: "user", content: userMessage)
            ],
            stream: false,
            format: responseFormat == .json ? "json" : nil
        )
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw OllamaClientError.invalidResponse
        }
        guard httpResponse.statusCode == 200 else {
            throw OllamaClientError.requestFailed(statusCode: httpResponse.statusCode)
        }

        let decoded = try JSONDecoder().decode(ChatResponseBody.self, from: data)
        return decoded.message.content
    }
}

private struct ChatRequestBody: Encodable {
    let model: String
    let messages: [Message]
    let stream: Bool
    let format: String?

    struct Message: Encodable {
        let role: String
        let content: String
    }
}

private struct ChatResponseBody: Decodable {
    let message: Message

    struct Message: Decodable {
        let role: String
        let content: String
    }
}
