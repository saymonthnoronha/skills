import SwiftUI
import SwiftData

struct PromptLibraryView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: [SortDescriptor(\Prompt.isPinned, order: .reverse), SortDescriptor(\Prompt.lastUsedAt, order: .reverse)])
    private var prompts: [Prompt]

    @State private var showingEditor = false
    @State private var editing: Prompt?

    var body: some View {
        NavigationStack {
            List {
                ForEach(prompts) { prompt in
                    PromptRow(prompt: prompt)
                        .contentShape(Rectangle())
                        .onTapGesture { editing = prompt }
                        .swipeActions(edge: .leading) {
                            Button {
                                PromptStore(context: context).togglePin(prompt)
                            } label: {
                                Label(prompt.isPinned ? "Desafixar" : "Fixar", systemImage: "pin")
                            }
                            .tint(.orange)
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                PromptStore(context: context).delete(prompt)
                            } label: {
                                Label("Excluir", systemImage: "trash")
                            }
                        }
                }
            }
            .navigationTitle("Prompts")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingEditor = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingEditor) {
                PromptEditorView(prompt: nil)
            }
            .sheet(item: $editing) { prompt in
                PromptEditorView(prompt: prompt)
            }
        }
    }
}

private struct PromptRow: View {
    let prompt: Prompt

    var body: some View {
        HStack(spacing: 14) {
            Text(prompt.emoji).font(.title2)
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(prompt.title).font(.headline)
                    if prompt.isPinned {
                        Image(systemName: "pin.fill")
                            .font(.caption2)
                            .foregroundStyle(.orange)
                    }
                }
                Text(prompt.template)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                if prompt.useCount > 0 {
                    Text("Usado \(prompt.useCount)× · \(Int(prompt.acceptanceRate * 100))% aceito")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
