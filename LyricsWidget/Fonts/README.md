# Fonts

Place the **Lyrico Display – Midnight** font files here, for example:

- `LyricoDisplay-Midnight.ttf`
- `LyricoDisplay-Midnight.otf`

After copying the files into this folder, add them to both Xcode targets:

1. Drag the font file(s) into the Xcode project navigator under the `LyricsWidget` group.
2. In the dialog, select **Copy items if needed** and check both **LyricsWidget** and **LyricsWidgetExtension** targets.
3. Confirm the files appear in **Build Phases → Copy Bundle Resources** for both targets.

The `UIAppFonts` entries in `LyricsWidget/Info.plist` and `LyricsWidgetExtension/Info.plist` already list `LyricoDisplay-Midnight.ttf`. If your file is named differently, update both plists to match.

Finally, verify the exact font name SwiftUI expects by updating `DesignSystem.displayFont` in `LyricsWidget/Theme.swift` to match the PostScript/full name reported by iOS.
