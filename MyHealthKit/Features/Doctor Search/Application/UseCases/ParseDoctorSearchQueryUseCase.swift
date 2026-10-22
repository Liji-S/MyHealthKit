import Foundation

enum ParseDoctorSearchQueryError: Error {
    case invalidResponse
}

struct ParseDoctorSearchQueryUseCaseImpl: ParseDoctorSearchQueryUseCaseProtocol {
    private let chatClient: ChatCompletionClientProtocol

    private let systemPrompt = """
    The user is searching for a doctor or medical facility. Turn their message into a \
    concise search phrase suitable for a places/business search engine — keep the \
    medical specialty and any qualifiers they mentioned (spoken language, gender \
    preference, etc.), but drop location phrases like "near me" since location is \
    handled separately.

    For example: "Arabic speaking dermatologist near me" → "Arabic speaking dermatologist".

    Respond with ONLY a JSON object with exactly this key: "searchQuery". Use null if \
    no medical specialty or search intent can be determined. No other text, no explanation.
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
        return ParsedDoctorSearchFilters(searchQuery: decoded.searchQuery)
    }
}

private struct ExtractedFiltersDTO: Decodable {
    let searchQuery: String?
}
