import SwiftUI

struct KeyboardRootView: View {
    @ObservedObject var viewModel: KeyboardViewModel

    var body: some View {
        VStack(spacing: 6) {
            if let draft = viewModel.pendingDraft {
                AIDraftView(draft: draft, viewModel: viewModel)
                    .transition(.move(edge: .top).combined(with: .opacity))
            } else if let error = viewModel.errorMessage {
                ErrorBanner(message: error) { viewModel.errorMessage = nil }
            } else {
                PromptStripView(viewModel: viewModel)
            }

            QwertyKeyboardView(viewModel: viewModel)
        }
        .padding(.vertical, 4)
        .background(Color(UIColor.systemGray6))
        .animation(.easeInOut(duration: 0.18), value: viewModel.pendingDraft?.id)
    }
}

private struct ErrorBanner: View {
    let message: String
    let onDismiss: () -> Void

    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill").foregroundStyle(.orange)
            Text(message).font(.caption)
            Spacer()
            Button(action: onDismiss) { Image(systemName: "xmark.circle.fill") }
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 12).padding(.vertical, 8)
        .background(Color.orange.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal, 6)
    }
}
