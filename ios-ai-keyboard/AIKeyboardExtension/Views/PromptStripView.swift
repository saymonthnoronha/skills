import SwiftUI

struct PromptStripView: View {
    @ObservedObject var viewModel: KeyboardViewModel

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                if viewModel.isGenerating {
                    HStack(spacing: 6) {
                        ProgressView().controlSize(.small)
                        Text("Pensando…").font(.caption)
                    }
                    .padding(.horizontal, 12).padding(.vertical, 8)
                    .background(Color(UIColor.systemBackground))
                    .clipShape(Capsule())
                }

                ForEach(viewModel.rankedPrompts) { ranked in
                    Button {
                        viewModel.run(prompt: ranked.prompt)
                    } label: {
                        HStack(spacing: 6) {
                            Text(ranked.prompt.emoji)
                            Text(ranked.prompt.title).font(.callout).bold()
                        }
                        .padding(.horizontal, 12).padding(.vertical, 8)
                        .background(
                            LinearGradient(
                                colors: [Color.accentColor.opacity(0.18), Color.purple.opacity(0.12)],
                                startPoint: .leading, endPoint: .trailing
                            )
                        )
                        .clipShape(Capsule())
                        .overlay(
                            Capsule().strokeBorder(Color.primary.opacity(0.08))
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(viewModel.isGenerating)
                }

                Button {
                    viewModel.captureStyleSample()
                } label: {
                    Image(systemName: "text.badge.plus")
                        .padding(.horizontal, 12).padding(.vertical, 8)
                        .background(Color(UIColor.systemBackground))
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 6)
        }
        .frame(height: 40)
    }
}
