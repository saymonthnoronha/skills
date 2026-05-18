import SwiftUI
import SwiftData

@main
struct AIKeyboardAppApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
                .modelContainer(SharedModelContainer.shared)
        }
    }
}

struct RootView: View {
    @Environment(\.modelContext) private var context
    @AppStorage("hasOnboarded", store: AppGroup.sharedDefaults) private var hasOnboarded = false

    var body: some View {
        Group {
            if hasOnboarded {
                ContentView()
            } else {
                OnboardingView(onFinish: { hasOnboarded = true })
            }
        }
        .task {
            PromptStore(context: context).ensureSeeded()
        }
    }
}
