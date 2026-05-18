import SwiftUI
import SwiftData

struct PromptEditorView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    let prompt: Prompt?

    @State private var title: String = ""
    @State private var template: String = ""
    @State private var emoji: String = "✨"
    @State private var tagsText: String = ""
    @State private var selectedSurfaces: Set<String> = []

    private let surfaces: [KeyboardContext.Surface] = [.mail, .messages, .whatsapp, .notes, .social, .browser, .search]

    var body: some View {
        NavigationStack {
            Form {
                Section("Identificação") {
                    HStack {
                        TextField("Emoji", text: $emoji).frame(width: 60)
                        TextField("Título", text: $title)
                    }
                }

                Section("Template") {
                    TextEditor(text: $template)
                        .frame(minHeight: 140)
                    Text("Use {{INPUT}} para inserir o texto digitado.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Section("Tags (separadas por vírgula)") {
                    TextField("ex: tom, formal, tradução", text: $tagsText)
                }

                Section("Aparece preferencialmente em") {
                    ForEach(surfaces, id: \.self) { surface in
                        Toggle(surface.rawValue.capitalized, isOn: Binding(
                            get: { selectedSurfaces.contains(surface.rawValue) },
                            set: { active in
                                if active { selectedSurfaces.insert(surface.rawValue) }
                                else { selectedSurfaces.remove(surface.rawValue) }
                            }
                        ))
                    }
                }
            }
            .navigationTitle(prompt == nil ? "Novo prompt" : "Editar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salvar") { save() }
                        .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty || template.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear(perform: load)
        }
    }

    private func load() {
        guard let prompt else { return }
        title = prompt.title
        template = prompt.template
        emoji = prompt.emoji
        tagsText = prompt.tags.joined(separator: ", ")
        selectedSurfaces = Set(prompt.preferredContexts)
    }

    private func save() {
        let tags = tagsText
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        let contexts = Array(selectedSurfaces)

        if let prompt {
            prompt.title = title
            prompt.template = template
            prompt.emoji = emoji.isEmpty ? "✨" : emoji
            prompt.tags = tags
            prompt.preferredContexts = contexts
            try? context.save()
        } else {
            PromptStore(context: context).create(
                title: title,
                template: template,
                emoji: emoji.isEmpty ? "✨" : emoji,
                tags: tags,
                contexts: contexts
            )
        }
        dismiss()
    }
}
