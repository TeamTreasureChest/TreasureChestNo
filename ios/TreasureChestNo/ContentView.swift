import SwiftUI
import UIKit

struct ContentView: View {
    @AppStorage(SettingsKey.includeSwearing, store: SharedDefaults.store) private var includeSwearing = false
    @AppStorage(SettingsKey.layout, store: SharedDefaults.store) private var layout = PageLayout.classic
    @Environment(\.scenePhase) private var scenePhase

    @State private var today = Date()
    @State private var offset = 0
    @State private var showingSettings = false
    @State private var copied = false

    private var calendar: Calendar { .current }

    private var shownDate: Date {
        calendar.date(byAdding: .day, value: offset, to: calendar.startOfDay(for: today)) ?? today
    }

    private var palette: Palette { layout.palette }

    private var rotation: [Phrase] { Phrases.rotation(includeSwearing: includeSwearing) }

    private var phrase: Phrase { Phrases.phrase(for: shownDate, includeSwearing: includeSwearing) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    CalendarPage(date: shownDate, offset: offset, phrase: phrase, layout: layout)
                        .contentShape(Rectangle())
                        .simultaneousGesture(swipe)

                    controls

                    HStack(spacing: 24) {
                        ShareLink(item: phrase.text) {
                            Label(offset == 0 ? "Share today's no" : "Share this no", systemImage: "square.and.arrow.up")
                        }
                        if offset != 0 {
                            Button("Back to today") { move(to: 0) }
                        }
                    }
                    .font(layout.labelFont(.footnote).weight(.medium))
                    .textCase(.uppercase)
                    .tint(palette.accent)

                    PhraseList(phrases: rotation, current: phrase, layout: layout)

                    if layout == .treasure {
                        Text("Five people · One team · Endless potential")
                            .font(TreasureTheme.hand(size: 15, bold: true, relativeTo: .footnote))
                            .foregroundStyle(TreasureTheme.parchment)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 14)
                            .background(TreasureTheme.wood, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                            .padding(.top, 8)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .frame(maxWidth: 480)
                .frame(maxWidth: .infinity)
            }
            .background(palette.ground.ignoresSafeArea())
            .navigationTitle("TreasureChestNo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    title
                }
                ToolbarItem(placement: .topBarLeading) {
                    Text("No. \(position) of \(rotation.count)")
                        .font(layout.labelFont(.caption))
                        .foregroundStyle(palette.muted)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showingSettings = true } label: {
                        Image(systemName: "gearshape")
                    }
                    .accessibilityLabel("Settings")
                    .tint(palette.ink)
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
        }
        .tint(palette.accent)
        .onChange(of: scenePhase) { _, phase in
            guard phase == .active else { return }
            today = Date()
            offset = 0
            Task { await Reminder.reschedule() }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.significantTimeChangeNotification)) { _ in
            today = Date()
        }
        .onReceive(NotificationCenter.default.publisher(for: .copiedFromNotification)) { _ in
            offset = 0
            showCopied()
        }
    }

    private var position: Int {
        (Phrases.all.firstIndex(of: phrase) ?? 0) + 1
    }

    /// The app name with the treasure chest icon, in the navigation bar.
    private var title: some View {
        HStack(spacing: 8) {
            Image("Chest")
                .resizable()
                .scaledToFill()
                .frame(width: 26, height: 26)
                .clipShape(layout == .treasure
                           ? AnyShape(Circle())
                           : AnyShape(RoundedRectangle(cornerRadius: 6, style: .continuous)))
                .overlay {
                    if layout == .treasure {
                        Circle().strokeBorder(TreasureTheme.gold, lineWidth: 1.5)
                    }
                }
                .accessibilityHidden(true)
            Text("TreasureChestNo")
                .font(layout == .treasure ? TreasureTheme.marker(size: 19) : .headline)
                .foregroundStyle(palette.ink)
        }
    }

    private var controls: some View {
        HStack(spacing: 10) {
            Button { move(to: offset - 1) } label: {
                Image(systemName: "chevron.left").frame(width: 52, height: 52)
            }
            .sideButtonStyle(layout)
            .accessibilityLabel("Previous day")

            Button(action: copy) {
                Text(copied ? "Copied. Go say no." : offset == 0 ? "Copy today's no" : "Copy this no")
                    .font(layout == .treasure ? TreasureTheme.hand(size: 19, bold: true, relativeTo: .headline) : .headline)
                    .frame(maxWidth: .infinity, minHeight: 52)
            }
            .copyButtonStyle(layout)

            Button { move(to: offset + 1) } label: {
                Image(systemName: "chevron.right").frame(width: 52, height: 52)
            }
            .sideButtonStyle(layout)
            .accessibilityLabel("Next day")
        }
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
        showCopied()
    }

    private func showCopied() {
        copied = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) { copied = false }
    }
}

/// The tear-off calendar page: date at the top, the day's no underneath.
private struct CalendarPage: View {
    let date: Date
    let offset: Int
    let phrase: Phrase
    let layout: PageLayout

    private var palette: Palette { layout.palette }
    private var treasure: Bool { layout == .treasure }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(date, format: .dateTime.month(.wide))
                Spacer()
                Text(date, format: .dateTime.year())
            }
            .font(treasure ? TreasureTheme.marker(size: 17) : .system(.footnote, design: .monospaced))
            .textCase(.uppercase)
            .tracking(1)
            .foregroundStyle(treasure ? TreasureTheme.gold : .white)
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .background {
                if treasure { TreasureTheme.wood } else { Theme.bar }
            }

            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .bottom) {
                    Text(date, format: .dateTime.day())
                        .font(treasure ? TreasureTheme.marker(size: 64) : .system(size: 64, weight: .heavy))
                        .monospacedDigit()
                        .foregroundStyle(palette.dayNumber)
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(date, format: .dateTime.weekday(.wide))
                        Text(relativeDay)
                    }
                    .font(layout.labelFont(.caption))
                    .textCase(.uppercase)
                    .foregroundStyle(palette.cardMuted)
                }

                if treasure {
                    Capsule().fill(TreasureTheme.sea.opacity(0.7)).frame(height: 3)
                } else {
                    Rectangle().fill(Theme.line).frame(height: 1)
                }

                Text(kicker)
                    .font(layout.labelFont(.caption2))
                    .textCase(.uppercase)
                    .tracking(1)
                    .foregroundStyle(palette.cardMuted)

                Text(phrase.text)
                    .font(layout.phraseFont(size: phraseSize))
                    .tracking(treasure ? 0 : -0.5)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, minHeight: 130, alignment: .leading)
                    .id(phrase.id)
                    .transition(.opacity)

                Text(phrase.tone)
                    .font(treasure ? TreasureTheme.hand(size: 14, bold: true, relativeTo: .caption) : .system(.caption, design: .monospaced))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(palette.tagFill, in: Capsule())
                    .overlay {
                        if treasure { Capsule().strokeBorder(TreasureTheme.goldDark, lineWidth: 1) }
                    }
                    .foregroundStyle(palette.tagText)

                Text(phrase.tip)
                    .font(treasure ? TreasureTheme.hand(size: 16, relativeTo: .subheadline) : .subheadline)
                    .foregroundStyle(palette.cardMuted)

                if treasure {
                    TeamValueRow(value: TeamValues.value(for: date), isToday: offset == 0)
                }
            }
            .foregroundStyle(palette.cardInk)
            .padding(22)
        }
        .background {
            if treasure {
                // Parchment, darker towards the edges.
                ZStack {
                    palette.paper
                    RadialGradient(
                        colors: [.clear, TreasureTheme.parchmentEdge.opacity(0.22)],
                        center: .center, startRadius: 120, endRadius: 380
                    )
                }
            } else {
                palette.paper
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: treasure ? 12 : 8, style: .continuous))
        .overlay {
            if treasure {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(TreasureTheme.parchmentEdge.opacity(0.35), lineWidth: 1)
            }
        }
        .shadow(color: .black.opacity(treasure ? 0.25 : 0.12), radius: 16, y: 8)
        .accessibilityElement(children: .combine)
    }

    private var kicker: String {
        switch offset {
        case 0: return treasure ? "X marks today's no" : "Today's no"
        case ..<0: return "That day's no"
        default: return "Coming up"
        }
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
    let layout: PageLayout
    @State private var expanded = false

    private var palette: Palette { layout.palette }

    var body: some View {
        DisclosureGroup(isExpanded: $expanded) {
            VStack(spacing: 0) {
                ForEach(phrases) { item in
                    HStack(alignment: .firstTextBaseline, spacing: 12) {
                        Text(item.text)
                            .font(layout == .treasure ? TreasureTheme.hand(size: 17, bold: item == current) : .body)
                            .fontWeight(item == current ? .semibold : .regular)
                            .foregroundStyle(item == current ? palette.accent : palette.ink)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text(item.tone)
                            .font(layout.labelFont(.caption2))
                            .textCase(.uppercase)
                            .foregroundStyle(palette.muted)
                    }
                    .padding(.vertical, 12)
                    Rectangle().fill(palette.line).frame(height: 1)
                }
            }
            .padding(.top, 4)
        } label: {
            Text("All \(phrases.count) ways to say no")
                .font(layout.labelFont(.footnote))
                .textCase(.uppercase)
                .tracking(1)
                .foregroundStyle(palette.muted)
        }
        .tint(palette.muted)
        .padding(.top, 8)
    }
}

/// One of the team's values or behaviours, at the bottom of the treasure
/// chest page.
private struct TeamValueRow: View {
    let value: TeamValue
    let isToday: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            DashedLine()
                .stroke(TreasureTheme.parchmentEdge.opacity(0.5), style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
                .frame(height: 1)
            HStack(spacing: 12) {
                Text(value.icon)
                    .font(.system(size: 26))
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 2) {
                    Text((isToday ? "Today's team " : "Team ") + value.kind.lowercased())
                        .font(TreasureTheme.hand(size: 13, relativeTo: .caption))
                        .foregroundStyle(Color(hex: 0x6B5A3E))
                    Text(value.text)
                        .font(TreasureTheme.hand(size: 16))
                }
            }
        }
        .padding(.top, 2)
    }
}

private struct DashedLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        return path
    }
}

#Preview {
    ContentView()
}
