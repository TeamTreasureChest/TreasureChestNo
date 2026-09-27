import Foundation

/// Keys for the values the Settings screen saves.
enum SettingsKey {
    static let reminderEnabled = "reminderEnabled"
    /// Reminder time as minutes after midnight.
    static let reminderMinutes = "reminderMinutes"
    static let includeSwearing = "includeSwearing"
    static let layout = "layout"

    static let all = [reminderEnabled, reminderMinutes, includeSwearing, layout]
}

/// Settings live in an App Group so the widgets and Siri read the same
/// values as the app.
///
/// If the bundle identifier changes, change `appGroup` to match the App
/// Group in both .entitlements files.
enum SharedDefaults {
    static let appGroup = "group.com.calebgab.TreasureChestNo"

    static let store: UserDefaults = UserDefaults(suiteName: appGroup) ?? .standard

    static var includeSwearing: Bool { store.bool(forKey: SettingsKey.includeSwearing) }

    static var layout: PageLayout {
        PageLayout(rawValue: store.string(forKey: SettingsKey.layout) ?? "") ?? .classic
    }

    /// Copies across anything saved before settings moved into the App
    /// Group, so nobody loses their settings on update.
    static func migrate() {
        let old = UserDefaults.standard
        guard store !== old else { return }
        for key in SettingsKey.all where store.object(forKey: key) == nil {
            if let value = old.object(forKey: key) {
                store.set(value, forKey: key)
            }
        }
    }
}
