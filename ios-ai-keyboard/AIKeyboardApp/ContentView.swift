import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            PromptLibraryView()
                .tabItem { Label("Prompts", systemImage: "sparkles") }

            StyleSamplesView()
                .tabItem { Label("Estilo", systemImage: "text.quote") }

            TelemetryView()
                .tabItem { Label("Insights", systemImage: "chart.bar") }

            SettingsView()
                .tabItem { Label("Ajustes", systemImage: "gearshape") }
        }
    }
}
