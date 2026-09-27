# TreasureChestNo for iPhone

The native iOS version of TreasureChestNo. It has the same 30 ways to say no as the web app in the repo root, in the same daily order. With **Include swear words** turned on, both show the same no on the same day. With it off (the default), the rotation skips the phrase with swearing, so the two apps can show different phrases.

## What it does

- **Today's no** on a tear-off calendar page, with its tone tag and a tip. Tap ‹ › or swipe the page to see other days, tap **Copy** to put the phrase on the clipboard, or **Share** to send it to Messages, WhatsApp and so on.
- **Widgets:** long-press the home screen, tap **Edit → Add Widget** and pick **TreasureChestNo**. Small and medium sizes go on the home screen (and show in StandBy while charging). On the Lock Screen, tap **Customise → Lock Screen** and add the one-line or three-line version. Widgets follow the **Layout** and **Include swear words** settings and change at midnight.
- **Siri and Shortcuts:** say "What's today's no in TreasureChestNo". Siri reads it out. The **Today's No** action is also in the Shortcuts app, and gives the phrase as text to use in other steps.
- **Settings** (the gear, top right):
  - **Layout:** **Classic** (the red tear-off calendar) or **Treasure chest**, styled on the Team Treasure Chest board in `team-treasure-chest.jpg`, with sand, parchment, wood and gold. The treasure chest layout also shows one of the team's values or behaviours each day. The web app has the same setting.
  - **Daily notification:** off to start with. Turn it on and pick a time, and you'll get a notification each day at that time with that day's no. The first time it's turned on, iOS asks for permission. Long-press the notification and tap **Copy** to copy the phrase. iOS only lets apps use the clipboard while they're open, so this opens the app for a moment.
  - **Include swear words:** off to start with. While it's off, phrases with swearing are left out of the daily rotation, the full list and the notifications.

## Running it on your iPhone

You'll need a Mac with **Xcode 16 or later**.

1. Open `ios/TreasureChestNo.xcodeproj` in Xcode.
2. Open **Signing & Capabilities** and pick your team under **Team** for **both** targets: **TreasureChestNo** (the app) and **TreasureChestNoWidget** (the widgets). With automatic signing, Xcode registers the bundle identifiers and the App Group for you.
3. Plug in your iPhone (or pick it from the device list), then press **Run**.

The app and the widgets share settings through an App Group, `group.com.calebgab.TreasureChestNo`. If you change the bundle identifier (`com.calebgab.TreasureChestNo`, with the widget at `com.calebgab.TreasureChestNo.Widget`), change the App Group to match in three places: `TreasureChestNo.entitlements`, `TreasureChestNoWidget.entitlements` and `appGroup` in `Shared/Settings.swift`.

If the App Group isn't set up (for example with a free Apple ID), the app still runs, but the widgets and Siri can't see its settings, so they always use Classic with swear words off.

With a free Apple ID, apps installed this way stop opening after 7 days and need running from Xcode again. A paid Apple Developer account removes that limit and lets you share the app through TestFlight or the App Store.

## How the notifications work

The phrase changes every day, so a single repeating notification can't carry it. Instead the app books one notification per day for the next 60 days, each with that day's phrase. iOS allows at most 64 pending notifications per app. The schedule is rebuilt every time the app opens or a setting changes, so the notifications keep coming as long as the app is opened at least once every two months.

## Adding or editing phrases

Phrases live in `Shared/Phrases.swift`:

- `all` is the list. Set `hasSwearing: true` on any phrase with swearing so the setting can hide it.
- `order` is which phrase comes up on which day.

Make the same change in the web app's `index.html` so the two stay in step.

## Files

| File | What it is |
|---|---|
| `TreasureChestNo/TreasureChestNoApp.swift` | App entry point. Lets notifications show while the app is open, and handles the notification's Copy button |
| `TreasureChestNo/ContentView.swift` | The main screen: calendar page, day buttons, copy and share, and full list |
| `TreasureChestNo/SettingsView.swift` | The settings screen |
| `TreasureChestNo/Reminder.swift` | Schedules the daily notifications |
| `TreasureChestNo/TodaysNoIntent.swift` | The Siri and Shortcuts action |
| `TreasureChestNo/Assets.xcassets` | App icon (the treasure chest from `team-treasure-chest.jpg`), the same chest for the title bar, and accent colour |
| `TreasureChestNoWidget/TodaysNoWidget.swift` | The home screen and Lock Screen widgets |
| `TreasureChestNoWidget/Assets.xcassets` | The chest picture for the medium widget |
| `Shared/Phrases.swift` | The phrases and the day-to-phrase logic |
| `Shared/Settings.swift` | Settings keys, and the App Group the app and widgets share them through |
| `Shared/Theme.swift` | Colours for light and dark mode |
| `Shared/PageLayout.swift` | The Classic and Treasure chest layouts: colours, fonts, buttons, and the team's values and behaviours |
| `TreasureChestNo.entitlements`, `TreasureChestNoWidget.entitlements` | Turn on the App Group for the app and the widgets |

Everything in `Shared/` is built into both the app and the widgets.

A GitHub Actions check (`.github/workflows/ios.yml`) builds the app on a Mac for every pull request that changes the `ios/` folder.
