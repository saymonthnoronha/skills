import SwiftUI

struct SettingsView: View {
    @State private var apiKey: String = KeychainStore.get(KeychainKey.claudeAPIKey) ?? ""
    @State private var savedFeedback: String?
    @AppStorage("preferredModel", store: AppGroup.sharedDefaults) private var model: String = "claude-haiku-4-5-20251001"
    @AppStorage("preferLocalForShort", store: AppGroup.sharedDefaults) private var preferLocal: Bool = true

    private let availableModels = [
        "claude-haiku-4-5-20251001",
        "claude-sonnet-4-6",
        "claude-opus-4-7"
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section("Claude API") {
                    SecureField("Chave API (sk-ant-...)", text: $apiKey)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                    Button {
                        let trimmed = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
                        if trimmed.isEmpty {
                            KeychainStore.remove(KeychainKey.claudeAPIKey)
                            savedFeedback = "Chave removida"
                        } else {
                            KeychainStore.set(trimmed, for: KeychainKey.claudeAPIKey)
                            savedFeedback = "Chave salva no Keychain"
                        }
                    } label: {
                        Label("Salvar chave", systemImage: "key.fill")
                    }
                    if let savedFeedback {
                        Text(savedFeedback).font(.caption).foregroundStyle(.secondary)
                    }
                }

                Section("Modelo Claude") {
                    Picker("Modelo", selection: $model) {
                        ForEach(availableModels, id: \.self) { Text($0).tag($0) }
                    }
                }

                Section("Roteamento Híbrido") {
                    Toggle("Preferir on-device em textos curtos", isOn: $preferLocal)
                    Text("Quando disponível, Apple Intelligence é usado para tarefas leves (<280 caracteres). Tarefas pesadas ou indisponíveis vão para Claude.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Section("Privacidade") {
                    Label("Prompts e amostras ficam no dispositivo.", systemImage: "lock.shield")
                    Label("Claude API só recebe o texto da tarefa atual.", systemImage: "network")
                }

                Section("Sobre") {
                    LabeledContent("Versão", value: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                    LabeledContent("App Group", value: AppGroup.identifier)
                }
            }
            .navigationTitle("Ajustes")
        }
    }
}
