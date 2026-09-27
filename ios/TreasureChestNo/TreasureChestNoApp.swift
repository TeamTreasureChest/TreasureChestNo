import SwiftUI
import UserNotifications

@main
struct TreasureChestNoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    init() {
        SharedDefaults.migrate()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

final class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        Reminder.registerActions()
        return true
    }

    // The Copy button on the daily notification.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        guard
            response.actionIdentifier == Reminder.copyAction,
            let text = response.notification.request.content.userInfo[Reminder.textKey] as? String
        else { return }
        await MainActor.run {
            UIPasteboard.general.string = text
            NotificationCenter.default.post(name: .copiedFromNotification, object: nil)
        }
    }

    // Show the daily notification even if the app happens to be open.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .list, .sound]
    }
}

extension Notification.Name {
    /// Posted after the notification's Copy button puts a phrase on the
    /// clipboard, so the main screen can say so.
    static let copiedFromNotification = Notification.Name("copiedFromNotification")
}
