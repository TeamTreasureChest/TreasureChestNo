import SwiftUI
import UIKit
import WidgetKit

struct SettingsView: View {
    @AppStorage(SettingsKey.reminderEnabled, store: SharedDefaults.store) private var reminderEnabled = false
    @AppStorage(SettingsKey.reminderMinutes, store: SharedDefaults.store) private var reminderMinutes = Reminder.defaultMinutes
    @AppStorage(SettingsKey.includeSwearing, store: SharedDefaults.store) private var includeSwearing = false
    @AppStorage(SettingsKey.layout, store: SharedDefaults.store) private var layout = PageLayout.classic

    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @State private var notificationsBlocked = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Layout", selection: $layout) {
                        ForEach(PageLayout.allCases) { option in
                            Text(option.title).tag(option)
                        }
                    }
                    .pickerStyle(.segmented)
                } header: {
                    Text("Layout")
                } footer: {
                    Text("Treasure chest uses the look of the Team Treasure Chest board, and shows one of the team's values or behaviours each day.")
                }

                Section {
                    Toggle("Daily notification", isOn: $reminderEnabled)
                    if reminderEnabled {
                        DatePicker("Time", selection: reminderTime, displayedComponents: .hourAndMinute)
                    }
                    if notificationsBlocked {
                        Button("Open iPhone Settings") {
                            if let url = URL(string: UIApplication.openSettingsURLString) { openURL(url) }
                        }
                    }
                } header: {
                    Text("Notifications")
                } footer: {
                    Text(notificationsBlocked
                         ? "Notifications are turned off for TreasureChestNo in iPhone Settings. Turn them on there, then switch the daily notification on again."
                         : "Get a notification each day at this time with that day's way to say no.")
                }

                Section {
                    Toggle("Include swear words", isOn: $includeSwearing)
                } header: {
                    Text("Phrases")
                } footer: {
                    Text("When this is off, phrases with swearing are left out of the daily rotation, the list and the notifications.")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .onChange(of: reminderEnabled) { _, isOn in
                Task {
                    if isOn {
                        let allowed = await Reminder.requestPermission()
                        notificationsBlocked = !allowed
                        if !allowed { reminderEnabled = false }
                    }
                    await Reminder.reschedule()
                }
            }
            .onChange(of: reminderMinutes) { _, _ in
                Task { await Reminder.reschedule() }
            }
            .onChange(of: includeSwearing) { _, _ in
                Task { await Reminder.reschedule() }
                WidgetCenter.shared.reloadAllTimelines()
            }
            .onChange(of: layout) { _, _ in
                WidgetCenter.shared.reloadAllTimelines()
            }
        }
    }

    /// The saved minutes-after-midnight as a Date for the time picker.
    private var reminderTime: Binding<Date> {
        Binding {
            Calendar.current.date(
                bySettingHour: reminderMinutes / 60, minute: reminderMinutes % 60, second: 0, of: Date()
            ) ?? Date()
        } set: { newValue in
            let parts = Calendar.current.dateComponents([.hour, .minute], from: newValue)
            reminderMinutes = (parts.hour ?? 0) * 60 + (parts.minute ?? 0)
        }
    }
}

#Preview {
    SettingsView()
}
