# TreasureChestNo

**TreasureChestNo** gives you a new way to say no each day. It's a small web app built to be added to an iPhone home screen, where it opens full-screen like a regular app and works offline.

## Using it on an iPhone

1. Open the app's address in Safari.
2. Tap **Share**, then **Add to Home Screen**.
3. Open it from the new **TreasureChestNo** icon.

## How it works

- Each date gets one phrase, based on the phone's local date. The phrase changes at midnight.
- Phrases rotate in a fixed shuffled order, so the cycle repeats every N days, where N is the number of phrases.
- Tap ‹ › or swipe the card to see other days. **Copy** puts the phrase on the clipboard.
- On an iPad or other wide screen the page is drawn bigger, and in landscape the full list of phrases sits beside it.
- The gear in the top corner opens **Settings**, where **Layout** switches between **Classic** (the red tear-off calendar) and **Treasure chest**, styled on the Team Treasure Chest board in `team-treasure-chest.jpg`. The treasure chest layout also shows one of the team's values or behaviours each day. The choice is remembered on that phone.

## Adding or editing phrases

Phrases live in the `NOS` list in `index.html`. Each one has the phrase, a tone label and a one-line tip.

When you add one, also add its position (its index in `NOS`) somewhere in the `ORDER` list just below it. `ORDER` sets which phrase shows on which day.

Then bump `CACHE` in `sw.js` (for example `treasure-chest-no-v1` to `treasure-chest-no-v2`) so phones that have the app installed drop the old copy.

## iPhone app

There's also a native iOS version in the [`ios/`](ios/) folder, with a daily notification and an option to hide phrases with swearing. See [`ios/README.md`](ios/README.md) for how to run it.

## Files

| File | What it is |
|---|---|
| `index.html` | The whole app: page, styles, phrases and script |
| `manifest.webmanifest` | App name, colours and icons for installing it |
| `sw.js` | Offline support |
| `icons/` | App icon, the same treasure chest as the iPhone app. The PNGs are resized from `ios/TreasureChestNo/Assets.xcassets/AppIcon.appiconset/AppIcon.png` |
| `.github/workflows/pages.yml` | Publishes the app to GitHub Pages on every push to `main` |

## Running it locally

Any static file server works, for example:

```sh
python3 -m http.server 8000
```

Then open http://localhost:8000.

## Publishing

The workflow deploys to GitHub Pages. It needs a one-time setting: in the repo's **Settings → Pages**, set **Source** to **GitHub Actions**.
