import Foundation

struct RankedPrompt: Identifiable {
    let id: UUID
    let prompt: Prompt
    let score: Double
}

enum SuggestionEngine {
    static func rank(
        prompts: [Prompt],
        context: KeyboardContext,
        limit: Int = 6
    ) -> [RankedPrompt] {
        let now = Date()
        let ranked = prompts.map { prompt -> RankedPrompt in
            RankedPrompt(id: prompt.id, prompt: prompt, score: score(prompt, context: context, now: now))
        }
        return ranked
            .sorted { $0.score > $1.score }
            .prefix(limit)
            .map { $0 }
    }

    private static func score(_ prompt: Prompt, context: KeyboardContext, now: Date) -> Double {
        var score = 0.0

        if prompt.isPinned { score += 5.0 }

        if prompt.preferredContexts.contains(context.surface.rawValue) {
            score += 3.0
        } else if !prompt.preferredContexts.isEmpty {
            score -= 1.0
        }

        score += min(2.0, log(Double(prompt.useCount + 1)))

        score += (prompt.acceptanceRate - 0.5) * 2.0

        if let last = prompt.lastUsedAt {
            let hours = now.timeIntervalSince(last) / 3600
            score += max(0, 1.5 - hours / 48)
        }

        let input = context.textBefore
        if input.count > 40, prompt.tags.contains("resposta") == false, prompt.tags.contains("correção") {
            score += 0.5
        }
        if context.surface == .mail, prompt.tags.contains("tom") { score += 0.5 }

        return score
    }
}
