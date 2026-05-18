import Foundation

final class HybridAIProvider: AIProvider {
    let name = "hybrid"
    private let onDevice: OnDeviceAIProvider
    private let claude: ClaudeAIProvider
    private let lightInputThreshold: Int

    init(
        onDevice: OnDeviceAIProvider = OnDeviceAIProvider(),
        claude: ClaudeAIProvider = ClaudeAIProvider(),
        lightInputThreshold: Int = 280
    ) {
        self.onDevice = onDevice
        self.claude = claude
        self.lightInputThreshold = lightInputThreshold
    }

    func generate(_ request: AIRequest) async throws -> AIResponse {
        let useLocal = shouldUseLocal(for: request)
        if useLocal {
            do {
                return try await onDevice.generate(request)
            } catch {
                return try await claude.generate(request)
            }
        }
        return try await claude.generate(request)
    }

    private func shouldUseLocal(for request: AIRequest) -> Bool {
        guard OnDeviceAIProvider.isAvailable else { return false }
        if request.complexity == .heavy { return false }
        if request.userPrompt.count > lightInputThreshold { return false }
        return true
    }
}
