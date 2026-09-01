import Foundation

enum ParseDoctorSearchQueryError: Error {
    case invalidResponse
}

struct ParseDoctorSearchQueryUseCaseImpl: ParseDoctorSearchQueryUseCaseProtocol {
    private let chatClient: ChatCompletionClientProtocol

    private let systemPrompt = """
    Extract the medical specialty being searched for from the user's message. Respond \
    with ONLY a JSON object with exactly this key: "specialty". Use null if no specialty \
    is mentioned. No other text, no explanation.
    """

    init(chatClient: ChatCompletionClientProtocol) {
        self.chatClient = chatClient
    }

    func execute(query: String) async throws -> ParsedDoctorSearchFilters {
        let rawResponse = try await chatClient.complete(
            systemPrompt: systemPrompt,
            userMessage: query,
            responseFormat: .json
        )

        guard let data = rawResponse.data(using: .utf8) else {
            throw ParseDoctorSearchQueryError.invalidResponse
        }
        let decoded = try JSONDecoder().decode(ExtractedFiltersDTO.self, from: data)
        return ParsedDoctorSearchFilters(specialty: decoded.specialty)
    }
}

private struct ExtractedFiltersDTO: Decodable {
    let specialty: String?
}
