# Phase 8 — Ongoing Workflow & Tips

> **Where:** Windows PC & iPhone  
> **Goal:** Run builds, update lyrics, refresh certificates, and maintain your $0 iOS app suite

---

## Daily / Weekly Developer Loop

```
1. Edit code in VS Code (Windows)
       ↓
2. git commit + push
       ↓
3. GitHub Actions builds (takes ~5-10 min)
       ↓
4. Download new .ipa from workflow artifact page
       ↓
5. Connect phone (Wi-Fi or USB) & sideload via AltStore / AltServer
```

---

## Tips & Best Practices

### 1. The 7-Day Certificate Refresh
Since you signed the app using a free Apple ID, the certificate expires after **7 days**. When it expires:
- The app will fail to open, showing an "App No Longer Available" or crashed prompt.
- **Your saved song and settings data will NOT be deleted.**
- Simply open **AltStore** on your iPhone while connected to the same Wi-Fi as your Windows PC (with AltServer running in the tray).
- Go to the **My Apps** tab and tap **Refresh All**.

### 2. Speeding Up App Sideloading
If Wi-Fi sideloading is slow or fails frequently:
1. Connect your iPhone via USB.
2. In the AltStore app on your iPhone, tap **My Apps** > **Refresh All** (or install the `.ipa`).
3. AltServer will transfer the app over the cable instead of the local network, reducing install time from 3 minutes to 30 seconds.

### 3. Modifying Files on Windows
When you add new `.swift` files on Windows:
- Remember that the `.xcodeproj` index doesn't auto-detect new files added to the folder.
- **Option A (Easiest)**: Whenever you sitting at the borrowed Mac, drag the new files from Finder into the Xcode project sidebar.
- **Option B**: Keep your code edits within the existing file structures if you want to avoid adding new files.

### 4. Customizing App Icons
If you want to customize your app icon:
1. Generate a `1024x1024` AppIcon image.
2. Replace the contents of `LyricsWidget/Assets.xcassets/AppIcon.appiconset/` with your asset sizes.
3. Push to GitHub, and the CI will compile the IPA with your new icon.

---

## How to Debug Widget Updates

Since Widgets run on a system-allocated resource budget, they do not update second-by-second. Here is how Lyrico manages it:

1. **App Intents (Buttons)**: Every time you tap the "Next" (`AdvanceLineIntent`) or "Previous" (`PreviousLineIntent`) button on the widget, it executes code directly on your iPhone. This does **not** count against the system daily refresh budget and updates instantly!
2. **App Modifications**: When you choose a new song inside the main app and tap "Set as Widget Lyrics", `WidgetCenter.shared.reloadAllTimelines()` is called. This forces an immediate widget redraw.
3. **Timeline Refreshes**: If your widget isn't updating, make sure AltServer is not running an expired certificate for the widget extension. (AltStore signs BOTH the main app and the extension targets automatically).

---

## Congratulations!

You now have a fully operational, customized, interactive iOS lyrics widget built completely from Windows for free. Enjoy your lyrics scrolling!
