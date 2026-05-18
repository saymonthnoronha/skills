import Foundation
import SwiftData

enum TelemetryKind: String, Codable {
    case suggestionShown
    case suggestionAccepted
    case suggestionRejected
    case aiGenerated
    case aiInserted
    case aiDiscarded
}

@Model
final class TelemetryEvent {
    @Attribute(.unique) var id: UUID
    var kind: String
    var promptId: UUID?
    var contextKey: String
    var route: String
    var latencyMs: Int
    var inputLength: Int
    var outputLength: Int
    var createdAt: Date

    init(
        kind: TelemetryKind,
        promptId: UUID? = nil,
        contextKey: String = "",
        route: String = "",
        latencyMs: Int = 0,
        inputLength: Int = 0,
        outputLength: Int = 0
    ) {
        self.id = UUID()
        self.kind = kind.rawValue
        self.promptId = promptId
        self.contextKey = contextKey
        self.route = route
        self.latencyMs = latencyMs
        self.inputLength = inputLength
        self.outputLength = outputLength
        self.createdAt = Date()
    }
}
