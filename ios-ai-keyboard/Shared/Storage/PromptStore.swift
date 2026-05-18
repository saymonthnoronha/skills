import Foundation
import SwiftData

@MainActor
final class PromptStore {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func ensureSeeded() {
        let descriptor = FetchDescriptor<Prompt>()
        let count = (try? context.fetchCount(descriptor)) ?? 0
        guard count == 0 else { return }
        for seed in Prompt.seeds { context.insert(seed) }
        try? context.save()
    }

    func all() -> [Prompt] {
        let descriptor = FetchDescriptor<Prompt>(
            sortBy: [SortDescriptor(\.isPinned, order: .reverse), SortDescriptor(\.lastUsedAt, order: .reverse)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    func create(title: String, template: String, emoji: String, tags: [String], contexts: [String]) {
        let prompt = Prompt(
            title: title,
            template: template,
            emoji: emoji,
            tags: tags,
            preferredContexts: contexts
        )
        context.insert(prompt)
        try? context.save()
    }

    func delete(_ prompt: Prompt) {
        context.delete(prompt)
        try? context.save()
    }

    func recordUse(_ prompt: Prompt) {
        prompt.useCount += 1
        prompt.lastUsedAt = Date()
        try? context.save()
    }

    func recordAcceptance(_ prompt: Prompt, accepted: Bool) {
        if accepted { prompt.acceptCount += 1 } else { prompt.rejectCount += 1 }
        try? context.save()
    }

    func togglePin(_ prompt: Prompt) {
        prompt.isPinned.toggle()
        try? context.save()
    }
}
