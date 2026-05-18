import SwiftUI

struct OnboardingView: View {
    let onFinish: () -> Void
    @State private var step = 0

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            switch step {
            case 0:
                page(
                    emoji: "✨",
                    title: "Um teclado que pensa com você",
                    body: "Refine, traduza, resuma e responda direto do teclado — em qualquer app."
                )
            case 1:
                page(
                    emoji: "🔐",
                    title: "Ative o teclado",
                    body: "Ajustes → Geral → Teclado → Teclados → Adicionar Novo → AIKeyboard. Toque em AIKeyboard e ative 'Permitir Acesso Completo' para usar a IA."
                )
            case 2:
                page(
                    emoji: "🧠",
                    title: "Ele evolui",
                    body: "Aprende seu estilo, lembra dos prompts que você usa mais e adapta sugestões ao app onde você está digitando."
                )
            default:
                EmptyView()
            }

            Spacer()

            Button {
                if step < 2 { step += 1 } else { onFinish() }
            } label: {
                Text(step < 2 ? "Continuar" : "Começar")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 32)
        }
    }

    private func page(emoji: String, title: String, body: String) -> some View {
        VStack(spacing: 16) {
            Text(emoji).font(.system(size: 72))
            Text(title).font(.title).bold().multilineTextAlignment(.center)
            Text(body)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
    }
}
