import SwiftUI
import UIKit

/// The two looks the main screen can take, picked in Settings. Matches the
/// Layout setting in the web app.
enum PageLayout: String, CaseIterable, Identifiable {
    /// The red tear-off calendar.
    case classic
    /// Sand, parchment, wood and gold, styled on the Team Treasure Chest
    /// board (team-treasure-chest.jpg in the repo root).
    case treasure

    var id: String { rawValue }

    var title: String {
        switch self {
        case .classic: return "Classic"
        case .treasure: return "Treasure chest"
        }
    }

    var palette: Palette {
        switch self {
        case .classic: return .classic
        case .treasure: return .treasure
        }
    }

    /// Small labels: dates, tags and list headings.
    func labelFont(_ style: Font.TextStyle) -> Font {
        switch self {
        case .classic: return .system(style, design: .monospaced)
        case .treasure: return TreasureTheme.hand(size: Self.pointSize(style), relativeTo: style)
        }
    }

    /// The phrase itself, at a size picked from its length.
    func phraseFont(size: CGFloat) -> Font {
        switch self {
        case .classic: return .system(size: size, weight: .heavy)
        case .treasure: return .custom("ChalkboardSE-Bold", fixedSize: size)
        }
    }

    private static func pointSize(_ style: Font.TextStyle) -> CGFloat {
        switch style {
        case .caption2: return 12
        case .caption: return 13
        case .footnote: return 14
        case .subheadline: return 16
        default: return 17
        }
    }
}

/// The colours a layout uses. `cardInk` and `cardMuted` are for text on the
/// calendar page, which can differ from text on the background.
struct Palette {
    let ground: Color
    let paper: Color
    let ink: Color
    let muted: Color
    let line: Color
    let accent: Color
    let tagFill: Color
    let tagText: Color
    let cardInk: Color
    let cardMuted: Color
    let dayNumber: Color

    static let classic = Palette(
        ground: Theme.ground, paper: Theme.paper, ink: Theme.ink, muted: Theme.muted,
        line: Theme.line, accent: Theme.stop, tagFill: Theme.stopSoft, tagText: Theme.stop,
        cardInk: Theme.ink, cardMuted: Theme.muted, dayNumber: Theme.ink
    )

    /// The parchment page stays light in dark mode, like a lit scroll, so
    /// the text on it keeps the same dark colours.
    static let treasure = Palette(
        ground: Color(light: 0xEEDCB3, dark: 0x0E2230),
        paper: Color(light: 0xF8EBCB, dark: 0xEEDDB4),
        ink: Color(light: 0x1B3A5C, dark: 0xF3E6C6),
        muted: Color(light: 0x6B5A3E, dark: 0xB8A57E),
        line: Color(light: 0xD2B77F, dark: 0x2C4556),
        accent: Color(light: 0x1E7A8C, dark: 0xF2C24B),
        tagFill: TreasureTheme.gold,
        tagText: TreasureTheme.woodDark,
        cardInk: Color(hex: 0x1B3A5C),
        cardMuted: Color(hex: 0x6B5A3E),
        dayNumber: Color(hex: 0x6A3F1D)
    )
}

/// Fixed colours and fonts for the treasure chest layout.
enum TreasureTheme {
    static let gold = Color(hex: 0xF2C24B)
    static let goldDark = Color(hex: 0xC8901E)
    static let woodDark = Color(hex: 0x4A2A12)
    static let parchment = Color(hex: 0xF8EBCB)
    static let parchmentEdge = Color(hex: 0xA06E28)
    static let sea = Color(hex: 0x2BA3B8)

    static let wood = LinearGradient(
        colors: [Color(hex: 0x6A3F1D), woodDark], startPoint: .top, endPoint: .bottom
    )
    static let coin = LinearGradient(
        colors: [Color(hex: 0xFBE08A), gold, Color(hex: 0xE0A526)], startPoint: .top, endPoint: .bottom
    )

    /// Handwritten text. Chalkboard SE comes with iOS.
    static func hand(size: CGFloat, bold: Bool = false, relativeTo style: Font.TextStyle = .body) -> Font {
        .custom(bold ? "ChalkboardSE-Bold" : "ChalkboardSE-Regular", size: size, relativeTo: style)
    }

    /// Marker-pen headings. Marker Felt comes with iOS.
    static func marker(size: CGFloat) -> Font {
        .custom("MarkerFelt-Wide", fixedSize: size)
    }
}

/// The team's values and behaviours from the Team Treasure Chest board. The
/// treasure chest layout shows one a day alongside the no.
struct TeamValue {
    let icon: String
    let kind: String
    let text: String
}

enum TeamValues {
    /// Same list and order as `TREASURE` in the web app, so both show the
    /// same one on the same day.
    static let all: [TeamValue] = [
        TeamValue(icon: "☀️", kind: "Value", text: "Feel joy"),
        TeamValue(icon: "💬", kind: "Behaviour", text: "Give and take feedback with positive intent"),
        TeamValue(icon: "⛰️", kind: "Value", text: "Be open to challenge"),
        TeamValue(icon: "💚", kind: "Behaviour", text: "Accept change in the status quo"),
        TeamValue(icon: "🔄", kind: "Value", text: "Embrace change"),
        TeamValue(icon: "🐢", kind: "Behaviour", text: "Unwind and slow down"),
        TeamValue(icon: "🌱", kind: "Value", text: "Sustain energy"),
        TeamValue(icon: "😄", kind: "Behaviour", text: "Be silly. Belly laugh."),
        TeamValue(icon: "🛡️", kind: "Value", text: "Accountability"),
        TeamValue(icon: "📅", kind: "Behaviour", text: "Scheduled accountability check-ins")
    ]

    static func value(for date: Date, calendar: Calendar = .current) -> TeamValue {
        let key = Phrases.dayNumber(for: date, calendar: calendar)
        let count = all.count
        return all[((key % count) + count) % count]
    }
}

/// The ‹ › buttons in the treasure chest layout: a wooden plank.
struct WoodButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(TreasureTheme.gold)
            .background(TreasureTheme.wood, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(TreasureTheme.woodDark, lineWidth: 1)
            )
            .opacity(configuration.isPressed ? 0.85 : 1)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
    }
}

/// The copy button in the treasure chest layout: a gold coin.
struct GoldButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(TreasureTheme.woodDark)
            .background(TreasureTheme.coin, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(TreasureTheme.goldDark, lineWidth: 1)
            )
            .opacity(configuration.isPressed ? 0.85 : 1)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
    }
}

extension View {
    /// Style for the ‹ › buttons.
    @ViewBuilder func sideButtonStyle(_ layout: PageLayout) -> some View {
        switch layout {
        case .classic: buttonStyle(.bordered).tint(Theme.ink)
        case .treasure: buttonStyle(WoodButtonStyle())
        }
    }

    /// Style for the copy button.
    @ViewBuilder func copyButtonStyle(_ layout: PageLayout) -> some View {
        switch layout {
        case .classic: buttonStyle(.borderedProminent).tint(Theme.ink).foregroundStyle(Theme.paper)
        case .treasure: buttonStyle(GoldButtonStyle())
        }
    }
}

extension Color {
    init(hex: UInt32) {
        self.init(uiColor: UIColor(hex: hex))
    }
}
