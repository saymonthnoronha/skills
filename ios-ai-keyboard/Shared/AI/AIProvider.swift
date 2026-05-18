import Foundation

struct AIRequest {
    enum Complexity { case light, heavy }
    let systemPrompt: String
    let userPrompt: String
    let styleSamples: [String]
    let maxTokens: Int
    let complexity: Complexity
}

struct AIResponse {
    let text: String
    let route: String
    let latencyMs: Int
}

enum AIError: Error, LocalizedError {
    case missingAPIKey
    case network(String)
    case decoding(String)
    case unsupportedOnDevice
    case empty

    var errorDescription: String? {
        switch self {
        case .missingAPIKey: return "Configure a chave da Claude API em Configurações."
        case .network(let msg): return "Erro de rede: \(msg)"
        case .decoding(let msg): return "Resposta inválida: \(msg)"
        case .unsupportedOnDevice: return "Apple Intelligence indisponível neste dispositivo."
        case .empty: return "Resposta vazia."
        }
    }
}

protocol AIProvider {
    var name: String { get }
    func generate(_ request: AIRequest) async throws -> AIResponse
}
