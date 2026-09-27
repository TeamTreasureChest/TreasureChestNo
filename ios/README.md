# TreasureChestNo for iPhone

The native iOS version of TreasureChestNo. It has the same 30 ways to say no as the web app in the repo root, in the same daily order. With **Include swear words** turned on, both show the same no on the same day. With it off (the default), the rotation skips the phrase with swearing, so the two apps can show different phrases.

## What it does

- **Today's no** on a tear-off calendar page, with its tone tag and a tip. Tap ‹ › or swipe the page to see other days, and tap **Copy** to put the phrase on the clipboard.
- **Settings** (the gear, top right):
  - **Layout:** **Classic** (the red tear-off calendar) or **Treasure chest**, styled on the Team Treasure Chest board in `team-treasure-chest.jpg`, with sand, parchment, wood and gold. The treasure chest layout also shows one of the team's values or behaviours each day. The web app has the same setting.
  - **Daily notification:** off to start with. Turn it on and pick a time, and you'll get a notification each day at that time with that day's no. The first time it's turned on, iOS asks for permission.
  - **Include swear words:** off to start with. While it's off, phrases with swearing are left out of the daily rotation, the full list and the notifications.

## Running it on your iPhone

You'll need a Mac with **Xcode 16 or later**.

1. Open `ios/TreasureChestNo.xcodeproj` in Xcode.
2. Select the **TreasureChestNo** target, open **Signing & Capabilities**, and pick your Apple ID under **Team**. A free Apple ID works for installing on your own phone. If Xcode says the bundle identifier is taken, change `com.calebgab.TreasureChestNo` to something unique.
3. Plug in your iPhone (or pick it from the device list), then press **Run**.

With a free Apple ID, apps installed this way stop opening after 7 days and need running from Xcode again. A paid Apple Developer account removes that limit and lets you share the app through TestFlight or the App Store.

## How the notifications work

The phrase changes every day, so a single repeating notification can't carry it. Instead the app books one notification per day for the next 60 days, each with that day's phrase. iOS allows at most 64 pending notifications per app. The schedule is rebuilt every time the app opens or a setting changes, so the notifications keep coming as long as the app is opened at least once every two months.

## Adding or editing phrases

Phrases live in `TreasureChestNo/Phrases.swift`:

- `all` is the list. Set `hasSwearing: true` on any phrase with swearing so the setting can hide it.
- `order` is which phrase comes up on which day.

Make the same change in the web app's `index.html` so the two stay in step.

## Files

| File | What it is |
|---|---|
| `TreasureChestNoApp.swift` | App entry point. Also lets notifications show while the app is open |
| `ContentView.swift` | The main screen: calendar page, day buttons, copy button and full list |
| `SettingsView.swift` | The settings screen |
| `Reminder.swift` | Schedules the daily notifications |
| `Phrases.swift` | The phrases and the day-to-phrase logic |
| `Theme.swift` | Colours for light and dark mode |
| `PageLayout.swift` | The Classic and Treasure chest layouts: colours, fonts, buttons, and the team's values and behaviours |
| `Assets.xcassets` | App icon (the treasure chest from `team-treasure-chest.jpg`), the same chest for the title bar, and accent colour |

A GitHub Actions check (`.github/workflows/ios.yml`) builds the app on a Mac for every pull request that changes the `ios/` folder.
