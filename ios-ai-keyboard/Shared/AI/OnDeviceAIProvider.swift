import Foundation

#if canImport(FoundationModels)
import FoundationModels
#endif

final class OnDeviceAIProvider: AIProvider {
    let name = "on-device"

    static var isAvailable: Bool {
        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            return SystemLanguageModel.default.availability == .available
        }
        #endif
        return false
    }

    func generate(_ request: AIRequest) async throws -> AIResponse {
        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            let start = Date()
            let model = SystemLanguageModel.default
            guard model.availability == .available else { throw AIError.unsupportedOnDevice }

            let instructions = FoundationModels.Instructions(request.systemPrompt + styleBlock(request.styleSamples))
            let session = FoundationModels.LanguageModelSession(model: model, instructions: instructions)
            let response = try await session.respond(to: FoundationModels.Prompt(request.userPrompt))
            let latency = Int(Date().timeIntervalSince(start) * 1000)
            let text = response.content.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !text.isEmpty else { throw AIError.empty }
            return AIResponse(text: text, route: name, latencyMs: latency)
        }
        #endif
        throw AIError.unsupportedOnDevice
    }

    private func styleBlock(_ samples: [String]) -> String {
        guard !samples.isEmpty else { return "" }
        let joined = samples.prefix(4).enumerated()
            .map { "Exemplo \($0.offset + 1): \($0.element)" }
            .joined(separator: "\n")
        return "\n\nO usuário costuma escrever assim — imite o tom e ritmo:\n\(joined)"
    }
}
