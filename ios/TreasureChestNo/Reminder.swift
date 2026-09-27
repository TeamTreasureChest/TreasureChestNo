import Foundation
import UserNotifications

/// Keys for the values the Settings screen saves.
enum SettingsKey {
    static let reminderEnabled = "reminderEnabled"
    /// Reminder time as minutes after midnight.
    static let reminderMinutes = "reminderMinutes"
    static let includeSwearing = "includeSwearing"
    static let layout = "layout"
}

/// The daily "today's no" notification.
///
/// The phrase changes every day, so a single repeating notification can't
/// carry it. Instead this books one notification per day for the next
/// `daysAhead` days, each with that day's phrase. iOS keeps at most 64
/// pending notifications per app, so the schedule is topped up every time
/// the app opens or a setting changes.
enum Reminder {
    static let defaultMinutes = 8 * 60
    static let daysAhead = 60

    /// Asks for permission to send notifications. Returns false if the user
    /// says no, or said no before.
    static func requestPermission() async -> Bool {
        (try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound])) ?? false
    }

    static func isAllowed() async -> Bool {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral: return true
        default: return false
        }
    }

    /// Rebuilds the schedule from the saved settings.
    static func reschedule(defaults: UserDefaults = .standard) async {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()

        guard defaults.bool(forKey: SettingsKey.reminderEnabled), await isAllowed() else { return }

        let minutes = defaults.object(forKey: SettingsKey.reminderMinutes) as? Int ?? defaultMinutes
        let includeSwearing = defaults.bool(forKey: SettingsKey.includeSwearing)
        let calendar = Calendar.current
        let now = Date()
        let today = calendar.startOfDay(for: now)

        for offset in 0..<daysAhead {
            guard
                let day = calendar.date(byAdding: .day, value: offset, to: today),
                let fireDate = calendar.date(bySettingHour: minutes / 60, minute: minutes % 60, second: 0, of: day),
                fireDate > now
            else { continue }

            let content = UNMutableNotificationContent()
            content.title = "Today's no"
            content.body = Phrases.phrase(for: day, includeSwearing: includeSwearing).text
            content.sound = .default

            let when = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate)
            let request = UNNotificationRequest(
                identifier: "daily-no-\(Phrases.dayNumber(for: day))",
                content: content,
                trigger: UNCalendarNotificationTrigger(dateMatching: when, repeats: false)
            )
            try? await center.add(request)
        }
    }
}
