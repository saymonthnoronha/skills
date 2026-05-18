import SwiftUI
import SwiftData

struct StyleSamplesView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \StyleSample.createdAt, order: .reverse) private var samples: [StyleSample]
    @State private var draft: String = ""

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("Cole aqui textos que representam seu jeito de escrever (mensagens, emails, posts). A IA usa esses exemplos como referência de estilo.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    VStack(alignment: .leading) {
                        TextEditor(text: $draft).frame(minHeight: 100)
                        HStack {
                            Spacer()
                            Button("Adicionar amostra") {
                                let trimmed = draft.trimmingCharacters(in: .whitespacesAndNewlines)
                                guard !trimmed.isEmpty else { return }
                                context.insert(StyleSample(text: trimmed, isApproved: true))
                                try? context.save()
                                draft = ""
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(draft.trimmingCharacters(in: .whitespaces).isEmpty)
                        }
                    }
                }

                Section("Suas amostras (\(samples.count))") {
                    ForEach(samples) { sample in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(sample.text).font(.body)
                            Text(sample.createdAt.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                        }
                        .swipeActions {
                            Button(role: .destructive) {
                                context.delete(sample)
                                try? context.save()
                            } label: {
                                Label("Excluir", systemImage: "trash")
                            }
                        }
                    }
                }
            }
            .navigationTitle("Estilo")
        }
    }
}
