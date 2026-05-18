# AIKeyboard — Teclado iOS AI-first

Teclado para iPhone com IA híbrida (on-device + Claude) que **evolui com o uso**:
biblioteca de prompts favoritos, aprendizado de estilo via amostras, sugestões
contextuais adaptativas por app e telemetria de aceitação que reordena o ranking.

## Arquitetura

```
┌─────────────────────────┐    ┌────────────────────────────┐
│   AIKeyboardApp         │    │  AIKeyboardExtension       │
│   (container app)       │    │  (keyboard extension)      │
│                         │    │                            │
│  • Onboarding           │    │  • KeyboardViewController  │
│  • Prompt Library       │    │  • PromptStripView         │
│  • Estilo (amostras)    │    │  • AIDraftView             │
│  • Insights/Telemetria  │    │  • QwertyKeyboardView      │
│  • Settings (API key)   │    │                            │
└──────────┬──────────────┘    └────────────┬───────────────┘
           │                                │
           └──────────────┬─────────────────┘
                          ▼
            ┌──────────────────────────────┐
            │  Shared (App Group container)│
            │                              │
            │  • Models (SwiftData)        │
            │     Prompt / StyleSample /   │
            │     TelemetryEvent           │
            │  • PromptStore               │
            │  • TelemetryStore            │
            │  • SuggestionEngine          │
            │  • ContextDetector           │
            │  • AI/                       │
            │    AIProvider (protocol)     │
            │    HybridAIProvider (router) │
            │    OnDeviceAIProvider        │
            │    ClaudeAIProvider          │
            │    PromptBuilder             │
            │  • KeychainStore             │
            └──────────────────────────────┘
```

## Como evolui

1. **Histórico de favoritos** — todo prompt usado registra `useCount` e `lastUsedAt`.
   Pinados ficam no topo permanentemente.
2. **Aprende estilo** — usuário cola amostras na aba *Estilo*. O `PromptBuilder`
   injeta as 6 amostras mais recentes como referência tonal em todo request.
3. **Sugestões contextuais adaptativas** — `ContextDetector` infere a surface
   (mail/whatsapp/notes/etc) por `bundleHint` + `keyboardType` + `returnKeyType`.
   `SuggestionEngine` rankeia prompts por: fixados → match de contexto →
   `log(useCount)` → taxa de aceitação → recência → tag×contexto.
4. **Telemetria de aceitação** — cada sugestão mostrada, aceita, rejeitada,
   gerada e inserida vira um `TelemetryEvent`. Aceitos elevam, rejeitados
   abaixam o score. A aba *Insights* mostra resumo e log.

## Roteamento híbrido

`HybridAIProvider` decide por request:

| Condição                                  | Rota         |
|-------------------------------------------|--------------|
| Apple Intelligence indisponível           | Claude       |
| `complexity == .heavy`                    | Claude       |
| Input > 280 caracteres                    | Claude       |
| Caso contrário                            | On-device → fallback Claude se falhar |

Apple Intelligence usa `FoundationModels.SystemLanguageModel` (iOS 26+),
guardado por `#if canImport(FoundationModels)` para compilar mesmo em SDKs
anteriores.

## Setup no Xcode

> Este repositório contém código-fonte e configurações. O `.xcodeproj` deve ser
> criado manualmente porque arquivos `.pbxproj` são gerados por templates.

### 1. Criar o projeto

1. Abra o Xcode → **File → New → Project → iOS App**
2. Product Name: `AIKeyboardApp`
3. Interface: SwiftUI · Language: Swift · Storage: SwiftData
4. Bundle Identifier: `com.aikeyboard.app` (ajuste para o seu prefixo de Team)
5. Após criado, **delete** o `ContentView.swift` e o `AIKeyboardAppApp.swift`
   gerados pelo template.

### 2. Adicionar o target de teclado

1. **File → New → Target → iOS → Custom Keyboard Extension**
2. Product Name: `AIKeyboardExtension`
3. Bundle Identifier: `com.aikeyboard.app.keyboard`
4. Delete o `KeyboardViewController.swift` gerado.

### 3. Copiar os arquivos

Arraste para o Xcode (respeitando os grupos):

- `Shared/**` → adicione a **ambos** os targets (App + Extension)
- `AIKeyboardApp/**` → target App
- `AIKeyboardExtension/**` → target Extension

### 4. Habilitar capabilities

Em **ambos** os targets (App e Extension):

1. **Signing & Capabilities → + Capability → App Groups**
2. Adicione/marque: `group.com.aikeyboard.shared`
3. **+ Capability → Keychain Sharing** → group `com.aikeyboard.shared`

### 5. Apontar os entitlements

- App target → Build Settings → `CODE_SIGN_ENTITLEMENTS` =
  `AIKeyboardApp/AIKeyboardApp.entitlements`
- Extension target → Build Settings → `CODE_SIGN_ENTITLEMENTS` =
  `AIKeyboardExtension/AIKeyboardExtension.entitlements`

### 6. Info.plist

Aponte cada target para o `Info.plist` correspondente neste repo
(Build Settings → `INFOPLIST_FILE`). O da extensão **precisa** ter
`RequestsOpenAccess = true` — sem isso o teclado não pode fazer chamadas
de rede para Claude.

### 7. Deployment target

- iOS 17.0 mínimo (SwiftData)
- iOS 26.0 recomendado para usar Apple Intelligence on-device

### 8. Build & Run

1. Selecione o scheme `AIKeyboardApp`, rode no simulador ou device
2. Complete o onboarding
3. **Settings → General → Keyboard → Keyboards → Add New Keyboard**
4. Escolha *AIKeyboard*
5. Toque em AIKeyboard de novo → ative **Allow Full Access**
6. Em qualquer app (ex: Mensagens), toque no globo 🌐 até trocar para AIKeyboard

## Configuração da Claude API

Na aba **Ajustes** do app container:

1. Cole sua chave `sk-ant-...` (gerada em https://console.anthropic.com)
2. Toque **Salvar chave** — vai pro Keychain compartilhado com a extensão
3. Escolha o modelo:
   - `claude-haiku-4-5-20251001` — mais rápido, default
   - `claude-sonnet-4-6` — equilíbrio
   - `claude-opus-4-7` — mais capaz, mais lento

## Privacidade

- Prompts, amostras de estilo e telemetria ficam **só no dispositivo** (SwiftData no App Group).
- A chave Claude fica no **Keychain** (não em UserDefaults).
- Apenas o texto da tarefa atual sai do device quando a rota é Claude.
- On-device não usa rede.

## Limitações conhecidas

- `parentBundleIdentifier()` é heurístico — iOS não expõe o bundle do host app
  para extensões por design. A detecção combina `keyboardType` + `returnKeyType`
  como proxy. Pode-se aprimorar adicionando hints manuais por contexto.
- A primeira chamada Claude em uma sessão pode ter ~1-2s de latência (TLS + cold start).
- Apple Intelligence só está disponível em iPhone 15 Pro+ rodando iOS 26+.

## Roadmap sugerido

- [ ] Streaming de tokens (chamar `messages?stream=true` e atualizar `pendingDraft.text` incrementalmente)
- [ ] Auto-captura de amostras de estilo (após N mensagens enviadas com sucesso)
- [ ] Few-shot dinâmico: escolher amostras de estilo cujo `contextHint` casa com o contexto atual
- [ ] Sync iCloud entre dispositivos do mesmo usuário
- [ ] Suporte a iPad (layout `split`)
- [ ] Atalhos de voz (Speech framework)

## Licença

Sem licença definida. Adicione uma antes de distribuir.
