# TreasureSayNo
An app to help Sarah

**Daily No** gives you a new way to say no each day. It's a small web app built to be added to an iPhone home screen, where it opens full-screen like a regular app and works offline.

## Using it on an iPhone

1. Open the app's address in Safari.
2. Tap **Share**, then **Add to Home Screen**.
3. Open it from the new **Daily No** icon.

## How it works

- Each date gets one phrase, based on the phone's local date. The phrase changes at midnight.
- Phrases rotate in a fixed shuffled order, so the cycle repeats every N days, where N is the number of phrases.
- Tap ‹ › or swipe the card to see other days. **Copy** puts the phrase on the clipboard.

## Adding or editing phrases

Phrases live in the `NOS` list in `index.html`. Each one has the phrase, a tone label and a one-line tip.

When you add one, also add its position (its index in `NOS`) somewhere in the `ORDER` list just below it. `ORDER` sets which phrase shows on which day.

Then bump `CACHE` in `sw.js` (for example `daily-no-v1` to `daily-no-v2`) so phones that have the app installed drop the old copy.

## Files

| File | What it is |
|---|---|
| `index.html` | The whole app: page, styles, phrases and script |
| `manifest.webmanifest` | App name, colours and icons for installing it |
| `sw.js` | Offline support |
| `icons/` | App icon (`icon.svg` is the source, the PNGs are rendered from it) |
| `.github/workflows/pages.yml` | Publishes the app to GitHub Pages on every push to `main` |

## Running it locally

Any static file server works, for example:

```sh
python3 -m http.server 8000
```

Then open http://localhost:8000.

## Publishing

The workflow deploys to GitHub Pages. It needs a one-time setting: in the repo's **Settings → Pages**, set **Source** to **GitHub Actions**.
