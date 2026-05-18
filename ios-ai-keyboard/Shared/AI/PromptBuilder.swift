import Foundation

enum PromptBuilder {
    static let inputToken = "{{INPUT}}"
    static let contextToken = "{{CONTEXT}}"

    static func build(
        prompt: Prompt,
        input: String,
        context: KeyboardContext,
        styleSamples: [String]
    ) -> AIRequest {
        let system = """
        Você é um assistente embutido num teclado iOS. Responda apenas com o texto final \
        a ser inserido — sem aspas, sem prefácios, sem explicações, sem markdown. \
        Mantenha o idioma do texto de entrada. Surface atual: \(context.surface.rawValue).
        """

        var user = prompt.template
        if user.contains(inputToken) {
            user = user.replacingOccurrences(of: inputToken, with: input.isEmpty ? "(vazio)" : input)
        } else if !input.isEmpty {
            user += "\n\nTexto: \(input)"
        }
        user = user.replacingOccurrences(of: contextToken, with: context.surface.rawValue)

        let complexity: AIRequest.Complexity = (input.count > 240 || prompt.template.count > 240) ? .heavy : .light

        return AIRequest(
            systemPrompt: system,
            userPrompt: user,
            styleSamples: styleSamples,
            maxTokens: 512,
            complexity: complexity
        )
    }
}
