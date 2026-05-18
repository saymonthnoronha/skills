import SwiftUI

struct AIDraftView: View {
    let draft: AIDraft
    @ObservedObject var viewModel: KeyboardViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Text(draft.prompt.emoji)
                Text(draft.prompt.title).font(.caption).bold()
                Spacer()
                Text(draft.route)
                    .font(.caption2)
                    .padding(.horizontal, 6).padding(.vertical, 2)
                    .background(Color.primary.opacity(0.08))
                    .clipShape(Capsule())
            }

            Text(draft.text)
                .font(.callout)
                .lineLimit(4)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 8) {
                Button {
                    viewModel.acceptDraft()
                } label: {
                    Label("Substituir", systemImage: "checkmark")
                        .font(.caption).bold()
                        .padding(.horizontal, 12).padding(.vertical, 6)
                        .background(Color.accentColor)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)

                Button {
                    viewModel.appendDraftWithoutReplacing()
                } label: {
                    Label("Inserir", systemImage: "text.insert")
                        .font(.caption)
                        .padding(.horizontal, 12).padding(.vertical, 6)
                        .background(Color.primary.opacity(0.08))
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)

                Spacer()

                Button {
                    viewModel.discardDraft()
                } label: {
                    Label("Descartar", systemImage: "xmark")
                        .font(.caption)
                        .padding(.horizontal, 12).padding(.vertical, 6)
                        .background(Color.primary.opacity(0.05))
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(10)
        .background(
            LinearGradient(colors: [Color.accentColor.opacity(0.10), Color.purple.opacity(0.06)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 6)
    }
}
