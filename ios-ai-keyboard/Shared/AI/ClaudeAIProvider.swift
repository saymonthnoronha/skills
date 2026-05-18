import Foundation

final class ClaudeAIProvider: AIProvider {
    let name = "claude"
    private let model: String
    private let endpoint = URL(string: "https://api.anthropic.com/v1/messages")!
    private let session: URLSession

    init(model: String = "claude-haiku-4-5-20251001", session: URLSession = .shared) {
        self.model = model
        self.session = session
    }

    func generate(_ request: AIRequest) async throws -> AIResponse {
        guard let key = KeychainStore.get(KeychainKey.claudeAPIKey), !key.isEmpty else {
            throw AIError.missingAPIKey
        }

        let body: [String: Any] = [
            "model": model,
            "max_tokens": request.maxTokens,
            "system": [
                ["type": "text", "text": request.systemPrompt, "cache_control": ["type": "ephemeral"]],
                ["type": "text", "text": styleBlock(request.styleSamples)]
            ],
            "messages": [
                ["role": "user", "content": request.userPrompt]
            ]
        ]

        var urlRequest = URLRequest(url: endpoint)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        urlRequest.setValue(key, forHTTPHeaderField: "x-api-key")
        urlRequest.httpBody = try JSONSerialization.data(withJSONObject: body)

        let start = Date()
        let (data, response) = try await session.data(for: urlRequest)
        let latency = Int(Date().timeIntervalSince(start) * 1000)

        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            let message = String(data: data, encoding: .utf8) ?? "unknown"
            throw AIError.network("status \((response as? HTTPURLResponse)?.statusCode ?? -1): \(message)")
        }

        let decoded = try JSONDecoder().decode(MessagesResponse.self, from: data)
        let text = decoded.content
            .compactMap { $0.text }
            .joined()
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { throw AIError.empty }
        return AIResponse(text: text, route: name, latencyMs: latency)
    }

    private func styleBlock(_ samples: [String]) -> String {
        guard !samples.isEmpty else { return "" }
        let joined = samples.prefix(6).enumerated()
            .map { "Exemplo \($0.offset + 1): \($0.element)" }
            .joined(separator: "\n")
        return "O usuário costuma escrever assim — imite o tom, ritmo e vocabulário:\n\(joined)"
    }
}

private struct MessagesResponse: Decodable {
    let content: [Block]
    struct Block: Decodable {
        let type: String
        let text: String?
    }
}
