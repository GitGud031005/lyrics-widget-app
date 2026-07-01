# Phase 6 — Widget Code & Shared Storage

> **Where:** Windows PC  
> **Time:** ~1 hour  
> **Prerequisite:** Phase 5 complete (Widget target manually configured, entitlements created)  
> **Goal:** Implement the Widget TimelineProvider, widget views, and the AppIntent for interactive scrolling

---

## Checklist

- [ ] Update `LyricsStore.swift` to use your App Group ID
- [ ] Create `LyricsWidgetIntents.swift` (AppIntent for button taps)
- [ ] Create `LyricsTimelineProvider.swift` (Widget data scheduling)
- [ ] Create `LyricsWidgetEntryView.swift` (Widget UI layout)
- [ ] Update `LyricsWidgetBundle.swift` / `LyricsWidget.swift`
- [ ] Build, download, and test the widget

---

## Step 1: Enable App Group in Shared Storage

Update `LyricsWidget/Storage/LyricsStore.swift` to enable the App Group. Find the line:
```swift
private let appGroupID: String? = nil
```
And replace it with:
```swift
private let appGroupID: String? = "group.com.lyrico.LyricsWidget"
```

Also, restore `WidgetKit` imports in `LyricsStore.swift` if you commented them out in Phase 3:
```swift
import WidgetKit

// inside reloadWidget():
func reloadWidget() {
    WidgetCenter.shared.reloadAllTimelines()
}
```

---

## Step 2: Create LyricsWidgetIntents.swift

Interactive widgets on iOS 17+ require an `AppIntent` to handle button presses. When the user taps the "Next" or "Previous" buttons on the widget, it executes this code background-side and triggers a reload.

Create file: `LyricsWidgetExtension/LyricsWidgetIntents.swift`

```swift
import AppIntents
import Foundation

// MARK: - Next Line Intent

struct AdvanceLineIntent: AppIntent {
    static var title: LocalizedStringResource = "Advance Lyric Line"
    static var description = IntentDescription("Moves the widget lyrics display to the next line.")
    
    init() {}
    
    func perform() async throws -> some IntentResult {
        let store = LyricsStore.shared
        store.advanceLine()
        store.reloadWidget()
        return .result()
    }
}

// MARK: - Previous Line Intent

struct PreviousLineIntent: AppIntent {
    static var title: LocalizedStringResource = "Previous Lyric Line"
    static var description = IntentDescription("Moves the widget lyrics display to the previous line.")
    
    init() {}
    
    func perform() async throws -> some IntentResult {
        let store = LyricsStore.shared
        store.previousLine()
        store.reloadWidget()
        return .result()
    }
}

// MARK: - Reset Position Intent

struct ResetLineIntent: AppIntent {
    static var title: LocalizedStringResource = "Reset Lyric Line"
    static var description = IntentDescription("Resets the widget lyrics display to the beginning.")
    
    init() {}
    
    func perform() async throws -> some IntentResult {
        let store = LyricsStore.shared
        store.resetPosition()
        store.reloadWidget()
        return .result()
    }
}
```

---

## Step 3: Create LyricsTimelineProvider.swift

The `TimelineProvider` determines when and how your widget updates. Because we are making a manual-scrolling widget, we only need to provide a single static timeline entry containing the current index and song from our shared store.

Create file: `LyricsWidgetExtension/LyricsTimelineProvider.swift`

```swift
import WidgetKit
import Foundation

// MARK: - Timeline Entry

struct LyricsEntry: TimelineEntry {
    let date: Date
    let trackName: String
    let artistName: String
    let lines: [LyricLine]
    let currentIndex: Int
    
    // Appearance settings
    let backgroundColorHex: String
    let textColorHex: String
    let highlightColorHex: String
    let fontSize: Double
    let linesVisible: Int
}

// MARK: - Timeline Provider

struct LyricsTimelineProvider: TimelineProvider {
    
    func placeholder(in context: Context) -> LyricsEntry {
        createSampleEntry()
    }

    func getSnapshot(in context: Context, completion: @escaping (LyricsEntry) -> ()) {
        let entry = createEntryFromStore()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entry = createEntryFromStore()
        
        // Since updates are triggered on-demand via AppIntents (button taps) 
        // or app modifications, we tell the system to refresh only when requested (.never).
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }
    
    // MARK: - Helpers
    
    private func createEntryFromStore() -> LyricsEntry {
        let store = LyricsStore.shared
        
        return LyricsEntry(
            date: Date(),
            trackName: store.currentSong?.trackName ?? "No Song Selected",
            artistName: store.currentSong?.artistName ?? "Open Lyrico to select lyrics",
            lines: store.currentLines,
            currentIndex: store.currentLineIndex,
            backgroundColorHex: store.backgroundColorHex,
            textColorHex: store.textColorHex,
            highlightColorHex: store.highlightColorHex,
            fontSize: store.fontSize,
            linesVisible: store.linesVisible
        )
    }
    
    private func createSampleEntry() -> LyricsEntry {
        let sampleLines = [
            LyricLine(timestamp: 0, text: "Welcome to Lyrico"),
            LyricLine(timestamp: 5, text: "Search for a song in the app"),
            LyricLine(timestamp: 10, text: "Select a line to highlight it"),
            LyricLine(timestamp: 15, text: "And display it on your widget"),
            LyricLine(timestamp: 20, text: "Tap the buttons to scroll!")
        ]
        
        return LyricsEntry(
            date: Date(),
            trackName: "Sample Song",
            artistName: "Sample Artist",
            lines: sampleLines,
            currentIndex: 1,
            backgroundColorHex: "#1A1A2E",
            textColorHex: "#8888AA",
            highlightColorHex: "#E94560",
            fontSize: 14.0,
            linesVisible: 5
        )
    }
}
```

---

## Step 4: Create LyricsWidgetEntryView.swift

Implement the layout UI for the Widget. It reads our settings (colors, size) and displays the lyric lines. On iOS 17+, it adds buttons that trigger our `AdvanceLineIntent` or `PreviousLineIntent`.

Create file: `LyricsWidgetExtension/LyricsWidgetEntryView.swift`

```swift
import SwiftUI
import WidgetKit

// MARK: - Widget View

struct LyricsWidgetEntryView : View {
    var entry: LyricsTimelineProvider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        ZStack {
            // Background Color
            Color(hex: entry.backgroundColorHex)
            
            VStack(spacing: 6) {
                // Header (only for Medium/Large sizes)
                if family != .systemSmall {
                    headerView
                }
                
                // Lyrics Window
                lyricsWindowView
                
                // Interactive Controls (only for Medium/Large sizes)
                if family != .systemSmall {
                    Spacer(minLength: 0)
                    controlsView
                }
            }
            .padding(12)
        }
        .containerBackground(Color(hex: entry.backgroundColorHex), for: .widget)
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 1) {
                Text(entry.trackName)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Text(entry.artistName)
                    .font(.system(size: 11))
                    .foregroundColor(Color(hex: entry.textColorHex).opacity(0.8))
                    .lineLimit(1)
            }
            
            Spacer()
            
            Image(systemName: "music.note.list")
                .font(.system(size: 14))
                .foregroundColor(Color(hex: entry.highlightColorHex))
        }
        .padding(.bottom, 4)
    }
    
    // MARK: - Lyrics Window
    
    private var lyricsWindowView: some View {
        VStack(alignment: .leading, spacing: 4) {
            let visibleRange = getVisibleLineIndices()
            
            ForEach(visibleRange, id: \.self) { index in
                if index >= 0 && index < entry.lines.count {
                    let line = entry.lines[index]
                    let isCurrent = (index == entry.currentIndex)
                    
                    Text(line.text)
                        .font(.system(
                            size: CGFloat(entry.fontSize),
                            weight: isCurrent ? .bold : .regular
                        ))
                        .foregroundColor(
                            isCurrent
                                ? Color(hex: entry.highlightColorHex)
                                : Color(hex: entry.textColorHex)
                        )
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 2)
                        .background(
                            isCurrent
                                ? Color(hex: entry.highlightColorHex).opacity(0.1)
                                : Color.clear
                        )
                        .cornerRadius(4)
                } else {
                    // Blank lines if song has ended or hasn't started
                    Text(" ")
                        .font(.system(size: CGFloat(entry.fontSize)))
                        .padding(.vertical, 2)
                }
            }
        }
    }
    
    // MARK: - Controls
    
    private var controlsView: some View {
        HStack(spacing: 24) {
            Button(intent: PreviousLineIntent()) {
                Image(systemName: "backward.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.white)
            }
            .buttonStyle(.plain)
            
            Button(intent: ResetLineIntent()) {
                Image(systemName: "goforward")
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.6))
            }
            .buttonStyle(.plain)
            
            Button(intent: AdvanceLineIntent()) {
                Image(systemName: "forward.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.white)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 16)
        .background(Color.white.opacity(0.08))
        .cornerRadius(10)
    }
    
    // MARK: - Range Calculation
    
    /// Calculate which indices to show to keep the highlighted lyric centered
    private func getVisibleLineIndices() -> [Int] {
        guard !entry.lines.isEmpty else {
            // Placeholder text if no lines
            return Array(0..<entry.linesVisible)
        }
        
        let count = entry.linesVisible
        let half = count / 2
        
        var start = entry.currentIndex - half
        
        // Pin bounds
        if start < 0 {
            start = 0
        }
        
        if start + count > entry.lines.count {
            start = max(0, entry.lines.count - count)
        }
        
        return Array(start..<(start + count))
    }
}
```

---

## Step 5: Update Main Widget Entry point

Find the generated file `LyricsWidgetExtension/LyricsWidget.swift` (or `LyricsWidgetExtension/LyricsWidgetBundle.swift`). Let's replace the widget registration code.

**Replace the entire content** of `LyricsWidgetExtension/LyricsWidget.swift` with:

```swift
import WidgetKit
import SwiftUI

struct LyricsWidget: Widget {
    let kind: String = "LyricsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LyricsTimelineProvider()) { entry in
            LyricsWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Lyrico Widget")
        .description("Displays manual-scrolling synced song lyrics.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
```

If Xcode created a `LyricsWidgetBundle.swift`, make sure it points to our new widget:

```swift
import WidgetKit
import SwiftUI

@main
struct LyricsWidgetBundle: WidgetBundle {
    var body: some Widget {
        LyricsWidget()
    }
}
```

---

## Step 6: Update the CI Workflow File

Since the project now includes a second Target (`LyricsWidgetExtension`), the widget target must be built along with the main app. We must update `.github/workflows/build.yml` so that both targets are compiled into the `.app` bundle.

Actually, because the Widget Extension is defined as a dependency target of `LyricsWidget` inside Xcode's project structure, when you build scheme `LyricsWidget`, Xcode **automatically compiles and embeds the widget** inside the app container (`Payload/LyricsWidget.app/PlugIns/LyricsWidgetExtension.appex`).

So your `build.yml` from Phase 3 **already works out of the box**! No modifications needed.

---

## Step 7: Push and Build

```powershell
git add .
git commit -m "implement interactive widget UI, timeline provider and app intents"
git push origin main
```

Watch the run on GitHub. Download the new zip, extract the `.ipa` and install it via AltStore!

---

## What's Next

We will write the customization menu (colors, sizes) in the main app to finalize the project features.

→ **[Phase 7: Customization Settings](./phase-7-customization.md)**
