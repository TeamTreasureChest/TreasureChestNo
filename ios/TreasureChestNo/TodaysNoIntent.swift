import AppIntents

/// "What's today's no?" for Siri, Shortcuts and Spotlight. Siri reads the
/// phrase out, and Shortcuts gets it as text to pass along.
struct TodaysNoIntent: AppIntent {
    static var title: LocalizedStringResource = "Today's No"
    static var description = IntentDescription("Gets today's way to say no.")

    func perform() async throws -> some IntentResult & ReturnsValue<String> & ProvidesDialog {
        let text = Phrases.phrase(for: Date(), includeSwearing: SharedDefaults.includeSwearing).text
        return .result(value: text, dialog: "\(text)")
    }
}

/// Makes the intent work with Siri straight away, with no setup in the
/// Shortcuts app.
struct TreasureChestNoShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: TodaysNoIntent(),
            phrases: [
                "What's today's no in \(.applicationName)",
                "What's today's \(.applicationName)",
                "Get today's no from \(.applicationName)",
                "\(.applicationName) today"
            ],
            shortTitle: "Today's No",
            systemImageName: "hand.raised"
        )
    }
}
