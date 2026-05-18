import SwiftUI
import SwiftData

struct TelemetryView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \TelemetryEvent.createdAt, order: .reverse) private var events: [TelemetryEvent]

    var body: some View {
        NavigationStack {
            List {
                Section("Resumo") {
                    SummaryRow(label: "Sugestões aceitas", value: "\(accepted)")
                    SummaryRow(label: "Sugestões rejeitadas", value: "\(rejected)")
                    SummaryRow(label: "Taxa de aceitação", value: percent(acceptanceRate))
                    SummaryRow(label: "Latência média on-device", value: ms(avgLatency(route: "on-device")))
                    SummaryRow(label: "Latência média Claude", value: ms(avgLatency(route: "claude")))
                }

                Section("Eventos recentes") {
                    ForEach(events.prefix(80)) { event in
                        HStack {
                            Image(systemName: icon(for: event.kind))
                                .foregroundStyle(color(for: event.kind))
                            VStack(alignment: .leading, spacing: 2) {
                                Text(event.kind).font(.callout)
                                Text("\(event.contextKey) · \(event.route)")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text(event.createdAt.formatted(.relative(presentation: .numeric)))
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                        }
                    }
                }
            }
            .navigationTitle("Insights")
        }
    }

    private var accepted: Int {
        events.filter { $0.kind == TelemetryKind.suggestionAccepted.rawValue || $0.kind == TelemetryKind.aiInserted.rawValue }.count
    }
    private var rejected: Int {
        events.filter { $0.kind == TelemetryKind.suggestionRejected.rawValue || $0.kind == TelemetryKind.aiDiscarded.rawValue }.count
    }
    private var acceptanceRate: Double {
        let total = accepted + rejected
        return total > 0 ? Double(accepted) / Double(total) : 0
    }

    private func avgLatency(route: String) -> Int {
        let filtered = events.filter { $0.route == route && $0.latencyMs > 0 }
        guard !filtered.isEmpty else { return 0 }
        return filtered.reduce(0) { $0 + $1.latencyMs } / filtered.count
    }

    private func percent(_ value: Double) -> String { "\(Int(value * 100))%" }
    private func ms(_ value: Int) -> String { value > 0 ? "\(value) ms" : "—" }

    private func icon(for kind: String) -> String {
        switch kind {
        case TelemetryKind.suggestionAccepted.rawValue, TelemetryKind.aiInserted.rawValue: return "checkmark.circle.fill"
        case TelemetryKind.suggestionRejected.rawValue, TelemetryKind.aiDiscarded.rawValue: return "xmark.circle.fill"
        case TelemetryKind.aiGenerated.rawValue: return "sparkles"
        default: return "circle"
        }
    }
    private func color(for kind: String) -> Color {
        switch kind {
        case TelemetryKind.suggestionAccepted.rawValue, TelemetryKind.aiInserted.rawValue: return .green
        case TelemetryKind.suggestionRejected.rawValue, TelemetryKind.aiDiscarded.rawValue: return .red
        case TelemetryKind.aiGenerated.rawValue: return .purple
        default: return .secondary
        }
    }
}

private struct SummaryRow: View {
    let label: String
    let value: String
    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Text(value).foregroundStyle(.secondary).monospacedDigit()
        }
    }
}
