import SwiftUI
import UIKit

/// Colours from the web app, with matching dark mode versions.
enum Theme {
    static let ground = Color(light: 0xEEF1F4, dark: 0x0E1318)
    static let paper = Color(light: 0xFFFFFF, dark: 0x171E26)
    static let ink = Color(light: 0x141B24, dark: 0xEDF1F5)
    static let muted = Color(light: 0x5B6673, dark: 0x93A0AE)
    static let line = Color(light: 0xD5DBE2, dark: 0x2A333E)
    static let stop = Color(light: 0xC8102E, dark: 0xFF5A6E)
    static let stopSoft = Color(light: 0xFBE7EA, dark: 0x3A1C22)
    /// The red bar at the top of the calendar page stays the same red in
    /// both modes so the white text on it always reads.
    static let bar = Color(light: 0xC8102E, dark: 0xC8102E)
}

extension Color {
    init(light: UInt32, dark: UInt32) {
        self.init(uiColor: UIColor { traits in
            UIColor(hex: traits.userInterfaceStyle == .dark ? dark : light)
        })
    }
}

extension UIColor {
    convenience init(hex: UInt32) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: 1
        )
    }
}
