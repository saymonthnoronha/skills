import Foundation
import UIKit

struct KeyboardContext {
    enum Surface: String {
        case mail, messages, whatsapp, notes, social, browser, search, code, unknown
    }

    let bundleHint: String
    let surface: Surface
    let textBefore: String
    let textAfter: String
    let isMultiline: Bool
    let returnKeyType: UIReturnKeyType
    let keyboardType: UIKeyboardType
    let locale: String

    var combined: String { textBefore + textAfter }

    var key: String { surface.rawValue }

    static let empty = KeyboardContext(
        bundleHint: "",
        surface: .unknown,
        textBefore: "",
        textAfter: "",
        isMultiline: false,
        returnKeyType: .default,
        keyboardType: .default,
        locale: Locale.current.identifier
    )
}
