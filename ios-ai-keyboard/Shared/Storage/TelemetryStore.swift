import Foundation
import SwiftData

@MainActor
final class TelemetryStore {
    private let context: ModelContext
    private let maxEvents = 5_000

    init(context: ModelContext) {
        self.context = context
    }

    func log(_ event: TelemetryEvent) {
        context.insert(event)
        try? context.save()
        trimIfNeeded()
    }

    func recent(limit: Int = 200) -> [TelemetryEvent] {
        var descriptor = FetchDescriptor<TelemetryEvent>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        descriptor.fetchLimit = limit
        return (try? context.fetch(descriptor)) ?? []
    }

    func acceptanceRate(forContext key: String) -> Double {
        let predicate = #Predicate<TelemetryEvent> { $0.contextKey == key }
        let events = (try? context.fetch(FetchDescriptor(predicate: predicate))) ?? []
        let accepted = events.filter { $0.kind == TelemetryKind.suggestionAccepted.rawValue }.count
        let rejected = events.filter { $0.kind == TelemetryKind.suggestionRejected.rawValue }.count
        let total = accepted + rejected
        guard total > 0 else { return 0.5 }
        return Double(accepted) / Double(total)
    }

    private func trimIfNeeded() {
        let descriptor = FetchDescriptor<TelemetryEvent>()
        let count = (try? context.fetchCount(descriptor)) ?? 0
        guard count > maxEvents else { return }
        var oldest = FetchDescriptor<TelemetryEvent>(
            sortBy: [SortDescriptor(\.createdAt, order: .forward)]
        )
        oldest.fetchLimit = count - maxEvents
        let toDelete = (try? context.fetch(oldest)) ?? []
        for event in toDelete { context.delete(event) }
        try? context.save()
    }
}
