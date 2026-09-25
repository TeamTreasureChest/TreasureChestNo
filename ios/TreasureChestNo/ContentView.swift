import SwiftUI
import UIKit

struct ContentView: View {
    @AppStorage(SettingsKey.includeSwearing) private var includeSwearing = false
    @Environment(\.scenePhase) private var scenePhase

    @State private var today = Date()
    @State private var offset = 0
    @State private var showingSettings = false
    @State private var copied = false

    private var calendar: Calendar { .current }

    private var shownDate: Date {
        calendar.date(byAdding: .day, value: offset, to: calendar.startOfDay(for: today)) ?? today
    }

    private var rotation: [Phrase] { Phrases.rotation(includeSwearing: includeSwearing) }

    private var phrase: Phrase { Phrases.phrase(for: shownDate, includeSwearing: includeSwearing) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    CalendarPage(date: shownDate, offset: offset, phrase: phrase)
                        .contentShape(Rectangle())
                        .simultaneousGesture(swipe)

                    controls

                    if offset != 0 {
                        Button("Back to today") { move(to: 0) }
                            .font(.system(.footnote, design: .monospaced).weight(.medium))
                            .textCase(.uppercase)
                            .tint(Theme.stop)
                    }

                    PhraseList(phrases: rotation, current: phrase)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .frame(maxWidth: 480)
                .frame(maxWidth: .infinity)
            }
            .background(Theme.ground.ignoresSafeArea())
            .navigationTitle("TreasureChestNo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("No. \(position) of \(rotation.count)")
                        .font(.system(.caption, design: .monospaced))
                        .foregroundStyle(Theme.muted)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showingSettings = true } label: {
                        Image(systemName: "gearshape")
                    }
                    .accessibilityLabel("Settings")
                    .tint(Theme.ink)
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
        }
        .tint(Theme.stop)
        .onChange(of: scenePhase) { _, phase in
            guard phase == .active else { return }
            today = Date()
            offset = 0
            Task { await Reminder.reschedule() }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.significantTimeChangeNotification)) { _ in
            today = Date()
        }
    }

    private var position: Int {
        (Phrases.all.firstIndex(of: phrase) ?? 0) + 1
    }

    private var controls: some View {
        HStack(spacing: 10) {
            Button { move(to: offset - 1) } label: {
                Image(systemName: "chevron.left").frame(width: 52, height: 52)
            }
            .buttonStyle(.bordered)
            .accessibilityLabel("Previous day")

            Button(action: copy) {
                Text(copied ? "Copied. Go say no." : offset == 0 ? "Copy today's no" : "Copy this no")
                    .font(.headline)
                    .frame(maxWidth: .infinity, minHeight: 52)
            }
            .buttonStyle(.borderedProminent)
            .tint(Theme.ink)
            .foregroundStyle(Theme.paper)

            Button { move(to: offset + 1) } label: {
                Image(systemName: "chevron.right").frame(width: 52, height: 52)
            }
            .buttonStyle(.bordered)
            .accessibilityLabel("Next day")
        }
        .tint(Theme.ink)
    }

    private var swipe: some Gesture {
        DragGesture(minimumDistance: 30)
            .onEnded { value in
                let dx = value.translation.width
                guard abs(dx) > 50, abs(dx) > abs(value.translation.height) else { return }
                move(to: offset + (dx < 0 ? 1 : -1))
            }
    }

    private func move(to newOffset: Int) {
        withAnimation(.easeInOut(duration: 0.2)) { offset = newOffset }
    }

    private func copy() {
        UIPasteboard.general.string = phrase.text
        copied = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) { copied = false }
    }
}

/// The tear-off calendar page: date at the top, the day's no underneath.
private struct CalendarPage: View {
    let date: Date
    let offset: Int
    let phrase: Phrase

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(date, format: .dateTime.month(.wide))
                Spacer()
                Text(date, format: .dateTime.year())
            }
            .font(.system(.footnote, design: .monospaced))
            .textCase(.uppercase)
            .tracking(1)
            .foregroundStyle(.white)
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .background(Theme.bar)

            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .bottom) {
                    Text(date, format: .dateTime.day())
                        .font(.system(size: 64, weight: .heavy))
                        .monospacedDigit()
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(date, format: .dateTime.weekday(.wide))
                        Text(relativeDay)
                    }
                    .font(.system(.caption, design: .monospaced))
                    .textCase(.uppercase)
                    .foregroundStyle(Theme.muted)
                }

                Rectangle().fill(Theme.line).frame(height: 1)

                Text(offset == 0 ? "Today's no" : offset < 0 ? "That day's no" : "Coming up")
                    .font(.system(.caption2, design: .monospaced))
                    .textCase(.uppercase)
                    .tracking(1)
                    .foregroundStyle(Theme.muted)

                Text(phrase.text)
                    .font(.system(size: phraseSize, weight: .heavy))
                    .tracking(-0.5)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, minHeight: 130, alignment: .leading)
                    .id(phrase.id)
                    .transition(.opacity)

                Text(phrase.tone)
                    .font(.system(.caption, design: .monospaced))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Theme.stopSoft, in: Capsule())
                    .foregroundStyle(Theme.stop)

                Text(phrase.tip)
                    .font(.subheadline)
                    .foregroundStyle(Theme.muted)
            }
            .foregroundStyle(Theme.ink)
            .padding(22)
        }
        .background(Theme.paper)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .shadow(color: .black.opacity(0.12), radius: 16, y: 8)
        .accessibilityElement(children: .combine)
    }

    private var relativeDay: String {
        switch offset {
        case 0: return "Today"
        case -1: return "Yesterday"
        case 1: return "Tomorrow"
        case ..<0: return "\(-offset) days ago"
        default: return "In \(offset) days"
        }
    }

    private var phraseSize: CGFloat {
        switch phrase.text.count {
        case ..<16: return 46
        case ..<30: return 38
        case ..<50: return 30
        default: return 25
        }
    }
}

/// Every phrase in the current rotation, with the one on show highlighted.
private struct PhraseList: View {
    let phrases: [Phrase]
    let current: Phrase
    @State private var expanded = false

    var body: some View {
        DisclosureGroup(isExpanded: $expanded) {
            VStack(spacing: 0) {
                ForEach(phrases) { item in
                    HStack(alignment: .firstTextBaseline, spacing: 12) {
                        Text(item.text)
                            .fontWeight(item == current ? .semibold : .regular)
                            .foregroundStyle(item == current ? Theme.stop : Theme.ink)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text(item.tone)
                            .font(.system(.caption2, design: .monospaced))
                            .textCase(.uppercase)
                            .foregroundStyle(Theme.muted)
                    }
                    .padding(.vertical, 12)
                    Rectangle().fill(Theme.line).frame(height: 1)
                }
            }
            .padding(.top, 4)
        } label: {
            Text("All \(phrases.count) ways to say no")
                .font(.system(.footnote, design: .monospaced))
                .textCase(.uppercase)
                .tracking(1)
                .foregroundStyle(Theme.muted)
        }
        .tint(Theme.muted)
        .padding(.top, 8)
    }
}

#Preview {
    ContentView()
}
