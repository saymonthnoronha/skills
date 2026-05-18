import Foundation
import SwiftUI
import SwiftData
import UIKit

@MainActor
final class KeyboardViewModel: ObservableObject {
    @Published var context: KeyboardContext = .empty
    @Published var rankedPrompts: [RankedPrompt] = []
    @Published var isGenerating: Bool = false
    @Published var pendingDraft: AIDraft?
    @Published var errorMessage: String?

    private let modelContext: ModelContext
    private let proxy: UITextDocumentProxy
    private let advance: () -> Void
    private let dismiss: () -> Void
    private let provider: AIProvider

    private lazy var promptStore = PromptStore(context: modelContext)
    private lazy var telemetryStore = TelemetryStore(context: modelContext)

    init(
        modelContext: ModelContext,
        proxy: UITextDocumentProxy,
        advanceAction: @escaping () -> Void,
        dismissAction: @escaping () -> Void,
        provider: AIProvider = HybridAIProvider()
    ) {
        self.modelContext = modelContext
        self.proxy = proxy
        self.advance = advanceAction
        self.dismiss = dismissAction
        self.provider = provider
        promptStore.ensureSeeded()
        refreshContext()
    }

    func refreshContext() {
        context = ContextDetector.detect(bundleHint: bundleHint, proxy: proxy)
        rankedPrompts = SuggestionEngine.rank(prompts: promptStore.all(), context: context)
        telemetryStore.log(TelemetryEvent(
            kind: .suggestionShown,
            contextKey: context.key,
            route: provider.name
        ))
    }

    func insertCharacter(_ char: String) {
        proxy.insertText(char)
    }

    func deleteBackward() {
        proxy.deleteBackward()
    }

    func insertSpace() { proxy.insertText(" ") }
    func insertReturn() { proxy.insertText("\n") }
    func nextKeyboard() { advance() }
    func dismissKeyboard() { dismiss() }

    func run(prompt: Prompt) {
        guard !isGenerating else { return }
        promptStore.recordUse(prompt)
        let input = context.textBefore
        let samples = approvedStyleSamples()
        let request = PromptBuilder.build(prompt: prompt, input: input, context: context, styleSamples: samples)

        isGenerating = true
        errorMessage = nil
        Task { [weak self] in
            guard let self else { return }
            do {
                let response = try await provider.generate(request)
                telemetryStore.log(TelemetryEvent(
                    kind: .aiGenerated,
                    promptId: prompt.id,
                    contextKey: context.key,
                    route: response.route,
                    latencyMs: response.latencyMs,
                    inputLength: input.count,
                    outputLength: response.text.count
                ))
                pendingDraft = AIDraft(text: response.text, prompt: prompt, route: response.route)
            } catch {
                errorMessage = error.localizedDescription
            }
            isGenerating = false
        }
    }

    func acceptDraft() {
        guard let draft = pendingDraft else { return }
        if !context.textBefore.isEmpty {
            replaceCurrentInput(with: draft.text)
        } else {
            proxy.insertText(draft.text)
        }
        promptStore.recordAcceptance(draft.prompt, accepted: true)
        telemetryStore.log(TelemetryEvent(
            kind: .aiInserted,
            promptId: draft.prompt.id,
            contextKey: context.key,
            route: draft.route,
            outputLength: draft.text.count
        ))
        pendingDraft = nil
    }

    func discardDraft() {
        guard let draft = pendingDraft else { return }
        promptStore.recordAcceptance(draft.prompt, accepted: false)
        telemetryStore.log(TelemetryEvent(
            kind: .aiDiscarded,
            promptId: draft.prompt.id,
            contextKey: context.key,
            route: draft.route
        ))
        pendingDraft = nil
    }

    func appendDraftWithoutReplacing() {
        guard let draft = pendingDraft else { return }
        proxy.insertText(draft.text)
        promptStore.recordAcceptance(draft.prompt, accepted: true)
        telemetryStore.log(TelemetryEvent(
            kind: .aiInserted,
            promptId: draft.prompt.id,
            contextKey: context.key,
            route: draft.route,
            outputLength: draft.text.count
        ))
        pendingDraft = nil
    }

    func captureStyleSample() {
        let text = context.textBefore.trimmingCharacters(in: .whitespacesAndNewlines)
        guard text.count >= 20 else { return }
        let sample = StyleSample(text: text, contextHint: context.key, isApproved: false)
        modelContext.insert(sample)
        try? modelContext.save()
    }

    private func replaceCurrentInput(with text: String) {
        let before = proxy.documentContextBeforeInput ?? ""
        for _ in 0..<before.count { proxy.deleteBackward() }
        proxy.insertText(text)
    }

    private func approvedStyleSamples() -> [String] {
        let descriptor = FetchDescriptor<StyleSample>(
            predicate: #Predicate { $0.isApproved == true },
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        let samples = (try? modelContext.fetch(descriptor)) ?? []
        return samples.prefix(6).map { $0.text }
    }

    private var bundleHint: String {
        // iOS não expõe o bundleId do app hospedeiro para a extensão (privacidade).
        // ContextDetector cai em keyboardType + returnKeyType para inferir a surface.
        ""
    }
}

struct AIDraft: Identifiable {
    let id = UUID()
    let text: String
    let prompt: Prompt
    let route: String
}
