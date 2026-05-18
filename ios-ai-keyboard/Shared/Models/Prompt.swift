import Foundation
import SwiftData

@Model
final class Prompt {
    @Attribute(.unique) var id: UUID
    var title: String
    var template: String
    var emoji: String
    var tags: [String]
    var createdAt: Date
    var lastUsedAt: Date?
    var useCount: Int
    var acceptCount: Int
    var rejectCount: Int
    var preferredContexts: [String]
    var isPinned: Bool

    init(
        id: UUID = UUID(),
        title: String,
        template: String,
        emoji: String = "✨",
        tags: [String] = [],
        preferredContexts: [String] = [],
        isPinned: Bool = false
    ) {
        self.id = id
        self.title = title
        self.template = template
        self.emoji = emoji
        self.tags = tags
        self.createdAt = Date()
        self.lastUsedAt = nil
        self.useCount = 0
        self.acceptCount = 0
        self.rejectCount = 0
        self.preferredContexts = preferredContexts
        self.isPinned = isPinned
    }

    var acceptanceRate: Double {
        let total = acceptCount + rejectCount
        guard total > 0 else { return 0.5 }
        return Double(acceptCount) / Double(total)
    }
}

extension Prompt {
    static let seeds: [Prompt] = [
        Prompt(
            title: "Resumir",
            template: "Resuma o texto a seguir em 2-3 frases curtas, mantendo o tom original:\n{{INPUT}}",
            emoji: "📝",
            tags: ["produtividade"],
            preferredContexts: ["mail", "notes"]
        ),
        Prompt(
            title: "Mais formal",
            template: "Reescreva o texto abaixo em um tom profissional e cordial, sem mudar o significado:\n{{INPUT}}",
            emoji: "🎩",
            tags: ["tom"],
            preferredContexts: ["mail", "linkedin"]
        ),
        Prompt(
            title: "Mais casual",
            template: "Reescreva o texto abaixo em um tom descontraído e amigável:\n{{INPUT}}",
            emoji: "😎",
            tags: ["tom"],
            preferredContexts: ["whatsapp", "messages", "social"]
        ),
        Prompt(
            title: "Corrigir",
            template: "Corrija ortografia, gramática e pontuação do texto abaixo. Não altere o significado nem o tom:\n{{INPUT}}",
            emoji: "✅",
            tags: ["correção"]
        ),
        Prompt(
            title: "Traduzir EN",
            template: "Translate the following text to natural, fluent English. Keep the original tone:\n{{INPUT}}",
            emoji: "🌐",
            tags: ["tradução"]
        ),
        Prompt(
            title: "Responder",
            template: "Sugira uma resposta curta e adequada para a mensagem abaixo:\n{{INPUT}}",
            emoji: "💬",
            tags: ["resposta"],
            preferredContexts: ["whatsapp", "messages", "mail"]
        ),
        Prompt(
            title: "Expandir",
            template: "Expanda as ideias abaixo em um parágrafo coeso e bem escrito:\n{{INPUT}}",
            emoji: "📖",
            tags: ["criação"]
        )
    ]
}
