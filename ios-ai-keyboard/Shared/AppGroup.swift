import Foundation

enum AppGroup {
    static let identifier = "group.com.aikeyboard.shared"

    static var containerURL: URL {
        guard let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: identifier) else {
            fatalError("App Group container missing. Enable App Groups capability with id: \(identifier)")
        }
        return url
    }

    static var sharedDefaults: UserDefaults {
        guard let defaults = UserDefaults(suiteName: identifier) else {
            fatalError("Cannot access shared UserDefaults for App Group \(identifier)")
        }
        return defaults
    }
}
