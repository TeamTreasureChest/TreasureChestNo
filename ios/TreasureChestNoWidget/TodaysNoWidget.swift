import SwiftUI
import WidgetKit

@main
struct TreasureChestNoWidgets: WidgetBundle {
    var body: some Widget {
        TodaysNoWidget()
    }
}

/// Today's no on the home screen (small, medium and large, plus extra large
/// on iPad), in StandBy, and on the Lock Screen (one line or a few lines). Follows the app's Layout and
/// swear words settings, which it reads from the App Group.
struct TodaysNoWidget: Widget {
    let kind = "TodaysNo"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: NoProvider()) { entry in
            NoWidgetView(entry: entry)
        }
        .configurationDisplayName("Today's No")
        .description("Today's way to say no. Changes at midnight.")
        .supportedFamilies([
            .systemSmall, .systemMedium, .systemLarge, .systemExtraLarge,
            .accessoryRectangular, .accessoryInline
        ])
    }
}

struct NoEntry: TimelineEntry {
    let date: Date
    let phrase: Phrase
    let value: TeamValue
    let layout: PageLayout
}

/// One entry per day, starting at local midnight, a week ahead. The app
/// asks for a fresh timeline whenever a setting changes.
struct NoProvider: TimelineProvider {
    func placeholder(in context: Context) -> NoEntry {
        entry(for: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (NoEntry) -> Void) {
        completion(entry(for: Date()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<NoEntry>) -> Void) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let entries = (0..<7)
            .compactMap { calendar.date(byAdding: .day, value: $0, to: today) }
            .map { entry(for: $0) }
        completion(Timeline(entries: entries, policy: .atEnd))
    }

    private func entry(for date: Date) -> NoEntry {
        NoEntry(
            date: date,
            phrase: Phrases.phrase(for: date, includeSwearing: SharedDefaults.includeSwearing),
            value: TeamValues.value(for: date),
            layout: SharedDefaults.layout
        )
    }
}

struct NoWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: NoEntry

    var body: some View {
        content
            .containerBackground(for: .widget) { background }
    }

    @ViewBuilder private var content: some View {
        switch family {
        case .accessoryInline:
            Text(entry.phrase.text)
        case .accessoryRectangular:
            LockScreenView(phrase: entry.phrase)
        case .systemMedium:
            MediumView(entry: entry)
        case .systemLarge, .systemExtraLarge:
            LargeView(entry: entry)
        default:
            SmallView(entry: entry)
        }
    }

    @ViewBuilder private var background: some View {
        switch family {
        case .accessoryInline, .accessoryRectangular:
            Color.clear
        default:
            if entry.layout == .treasure {
                ZStack {
                    entry.layout.palette.paper
                    RadialGradient(
                        colors: [.clear, TreasureTheme.parchmentEdge.opacity(0.25)],
                        center: .center, startRadius: 40, endRadius: 220
                    )
                }
            } else {
                Theme.paper
            }
        }
    }
}

/// A few lines on the Lock Screen. The system picks the colours.
private struct LockScreenView: View {
    let phrase: Phrase

    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            Text("Today's no")
                .font(.caption2.weight(.semibold))
                .textCase(.uppercase)
                .widgetAccentable()
            Text(phrase.text)
                .font(.headline)
                .minimumScaleFactor(0.6)
                .lineLimit(3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// Date across the top, the phrase, and its tone.
private struct SmallView: View {
    let entry: NoEntry

    private var layout: PageLayout { entry.layout }
    private var palette: Palette { layout.palette }
    private var treasure: Bool { layout == .treasure }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline) {
                Text(treasure ? "X marks the no" : "Today's no")
                    .font(layout.labelFont(.caption2))
                    .textCase(.uppercase)
                    .foregroundStyle(treasure ? palette.dayNumber : Theme.stop)
                    .lineLimit(1)
                Spacer(minLength: 4)
                Text(entry.date, format: .dateTime.day())
                    .font(treasure ? TreasureTheme.marker(size: 17) : .system(size: 17, weight: .heavy))
                    .foregroundStyle(palette.dayNumber)
            }

            Text(entry.phrase.text)
                .font(layout.phraseFont(size: phraseSize(for: entry.phrase, sizes: (26, 21, 17, 14))))
                .foregroundStyle(palette.cardInk)
                .minimumScaleFactor(0.5)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

            ToneTag(tone: entry.phrase.tone, layout: layout)
        }
    }
}

/// The date on the left, the phrase and its tip on the right. The treasure
/// chest layout adds the team value of the day.
private struct MediumView: View {
    let entry: NoEntry

    private var layout: PageLayout { entry.layout }
    private var palette: Palette { layout.palette }
    private var treasure: Bool { layout == .treasure }

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.date, format: .dateTime.month(.abbreviated))
                    .font(layout.labelFont(.caption2))
                    .textCase(.uppercase)
                    .foregroundStyle(treasure ? palette.dayNumber : Theme.stop)
                Text(entry.date, format: .dateTime.day())
                    .font(treasure ? TreasureTheme.marker(size: 40) : .system(size: 40, weight: .heavy))
                    .monospacedDigit()
                    .foregroundStyle(palette.dayNumber)
                Text(entry.date, format: .dateTime.weekday(.abbreviated))
                    .font(layout.labelFont(.caption2))
                    .textCase(.uppercase)
                    .foregroundStyle(palette.cardMuted)
                Spacer(minLength: 0)
                if treasure {
                    Image("Chest")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 30, height: 30)
                        .clipShape(Circle())
                        .overlay(Circle().strokeBorder(TreasureTheme.gold, lineWidth: 1.5))
                }
            }
            .frame(width: 58, alignment: .leading)

            Rectangle()
                .fill(treasure ? TreasureTheme.sea.opacity(0.6) : Theme.line)
                .frame(width: treasure ? 2 : 1)

            VStack(alignment: .leading, spacing: 6) {
                Text(entry.phrase.text)
                    .font(layout.phraseFont(size: phraseSize(for: entry.phrase, sizes: (30, 25, 21, 17))))
                    .foregroundStyle(palette.cardInk)
                    .minimumScaleFactor(0.5)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

                if treasure {
                    Text("\(entry.value.icon) \(entry.value.text)")
                        .font(TreasureTheme.hand(size: 12, relativeTo: .caption))
                        .foregroundStyle(palette.cardMuted)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                } else {
                    Text(entry.phrase.tip)
                        .font(.caption)
                        .foregroundStyle(palette.cardMuted)
                        .lineLimit(2)
                }

                ToneTag(tone: entry.phrase.tone, layout: layout)
            }
        }
    }
}

/// A small calendar page: month and weekday, the date, the phrase, its tone
/// and tip. The treasure chest layout adds the team value of the day.
private struct LargeView: View {
    let entry: NoEntry

    private var layout: PageLayout { entry.layout }
    private var palette: Palette { layout.palette }
    private var treasure: Bool { layout == .treasure }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text(entry.date, format: .dateTime.month(.wide))
                    .foregroundStyle(treasure ? palette.dayNumber : Theme.stop)
                Spacer()
                Text(entry.date, format: .dateTime.weekday(.wide))
                    .foregroundStyle(palette.cardMuted)
            }
            .font(layout.labelFont(.caption))
            .textCase(.uppercase)

            HStack(alignment: .bottom) {
                Text(entry.date, format: .dateTime.day())
                    .font(treasure ? TreasureTheme.marker(size: 56) : .system(size: 56, weight: .heavy))
                    .monospacedDigit()
                    .foregroundStyle(palette.dayNumber)
                Spacer()
                if treasure {
                    Image("Chest")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 44, height: 44)
                        .clipShape(Circle())
                        .overlay(Circle().strokeBorder(TreasureTheme.gold, lineWidth: 2))
                }
            }

            if treasure {
                Capsule().fill(TreasureTheme.sea.opacity(0.7)).frame(height: 3)
            } else {
                Rectangle().fill(Theme.line).frame(height: 1)
            }

            Text(treasure ? "X marks today's no" : "Today's no")
                .font(layout.labelFont(.caption2))
                .textCase(.uppercase)
                .foregroundStyle(palette.cardMuted)

            Text(entry.phrase.text)
                .font(layout.phraseFont(size: phraseSize(for: entry.phrase, sizes: (40, 34, 28, 22))))
                .foregroundStyle(palette.cardInk)
                .minimumScaleFactor(0.5)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

            ToneTag(tone: entry.phrase.tone, layout: layout)

            Text(entry.phrase.tip)
                .font(treasure ? TreasureTheme.hand(size: 14, relativeTo: .footnote) : .footnote)
                .foregroundStyle(palette.cardMuted)
                .lineLimit(2)

            if treasure {
                Text("\(entry.value.icon) \(entry.value.text)")
                    .font(TreasureTheme.hand(size: 14, relativeTo: .footnote))
                    .foregroundStyle(palette.cardInk)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
    }
}

private struct ToneTag: View {
    let tone: String
    let layout: PageLayout

    var body: some View {
        let palette = layout.palette
        Text(tone)
            .font(layout == .treasure
                  ? TreasureTheme.hand(size: 11, bold: true, relativeTo: .caption2)
                  : .system(.caption2, design: .monospaced))
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(palette.tagFill, in: Capsule())
            .foregroundStyle(palette.tagText)
    }
}

/// Starting size for the phrase by length: under 16 characters, under 30,
/// under 50, and longer. `minimumScaleFactor` shrinks it further if it
/// still doesn't fit.
private func phraseSize(for phrase: Phrase, sizes: (CGFloat, CGFloat, CGFloat, CGFloat)) -> CGFloat {
    switch phrase.text.count {
    case ..<16: return sizes.0
    case ..<30: return sizes.1
    case ..<50: return sizes.2
    default: return sizes.3
    }
}
