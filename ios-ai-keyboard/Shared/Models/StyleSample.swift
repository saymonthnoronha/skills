import Foundation
import SwiftData

@Model
final class StyleSample {
    @Attribute(.unique) var id: UUID
    var text: String
    var contextHint: String
    var createdAt: Date
    var isApproved: Bool

    init(text: String, contextHint: String = "", isApproved: Bool = false) {
        self.id = UUID()
        self.text = text
        self.contextHint = contextHint
        self.createdAt = Date()
        self.isApproved = isApproved
    }
}
