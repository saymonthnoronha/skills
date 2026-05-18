import Foundation
import UIKit

enum ContextDetector {
    static func detect(
        bundleHint: String,
        proxy: UITextDocumentProxy
    ) -> KeyboardContext {
        let surface = surfaceFor(bundleHint: bundleHint, proxy: proxy)
        let before = proxy.documentContextBeforeInput ?? ""
        let after = proxy.documentContextAfterInput ?? ""
        let multiline = before.contains("\n") || after.contains("\n") || before.count > 120
        return KeyboardContext(
            bundleHint: bundleHint,
            surface: surface,
            textBefore: String(before.suffix(400)),
            textAfter: String(after.prefix(200)),
            isMultiline: multiline,
            returnKeyType: proxy.returnKeyType ?? .default,
            keyboardType: proxy.keyboardType ?? .default,
            locale: Locale.current.identifier
        )
    }

    private static func surfaceFor(bundleHint: String, proxy: UITextDocumentProxy) -> KeyboardContext.Surface {
        let hint = bundleHint.lowercased()
        if hint.contains("mail") { return .mail }
        if hint.contains("whatsapp") { return .whatsapp }
        if hint.contains("messages") || hint.contains("mobilesms") { return .messages }
        if hint.contains("notes") || hint.contains("mobilenotes") { return .notes }
        if hint.contains("safari") || hint.contains("chrome") { return .browser }
        if hint.contains("twitter") || hint.contains("instagram") || hint.contains("threads") { return .social }
        if hint.contains("xcode") || hint.contains("code") { return .code }

        switch proxy.keyboardType ?? .default {
        case .emailAddress, .webSearch: return .mail
        case .URL: return .browser
        case .twitter: return .social
        default: break
        }
        switch proxy.returnKeyType ?? .default {
        case .search, .google, .yahoo: return .search
        case .send: return .messages
        default: return .unknown
        }
    }
}
