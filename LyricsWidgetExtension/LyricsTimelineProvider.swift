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
        Task { @MainActor in
            let entry = createEntryFromStore()
            completion(entry)
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        Task { @MainActor in
            let entry = createEntryFromStore()
            
            // Refresh only when requested (.never)
            let timeline = Timeline(entries: [entry], policy: .never)
            completion(timeline)
        }
    }
    
    // MARK: - Helpers
    
    @MainActor
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
            backgroundColorHex: LyricsStore.defaultBgColorHex,
            textColorHex: LyricsStore.defaultTextColorHex,
            highlightColorHex: LyricsStore.defaultHighlightColorHex,
            fontSize: 14.0,
            linesVisible: 5
        )
    }
}
