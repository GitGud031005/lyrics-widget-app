import WidgetKit
import Foundation

// MARK: - Timeline Entry

struct LyricsEntry: TimelineEntry, Sendable {
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

    func getSnapshot(in context: Context, completion: @escaping @Sendable (LyricsEntry) -> ()) {
        let entry = createEntryFromStore()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping @Sendable (Timeline<Entry>) -> ()) {
        let entry = createEntryFromStore()
        
        // Refresh only when requested (.never)
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }
    
    // MARK: - Helpers
    
    private func createEntryFromStore() -> LyricsEntry {
        let appGroupID = AppGroupHelper.appGroupID
        let defaults = UserDefaults(suiteName: appGroupID) ?? .standard
        
        // Load appearance settings with defaults matching LyricsStore
        let backgroundColorHex = defaults.string(forKey: "widgetBgColor") ?? "#1A1A2E"
        let textColorHex = defaults.string(forKey: "widgetTextColor") ?? "#8888AA"
        let highlightColorHex = defaults.string(forKey: "widgetHighlightColor") ?? "#E94560"
        
        let savedFontSize = defaults.double(forKey: "widgetFontSize")
        let fontSize = savedFontSize == 0 ? 14.0 : savedFontSize
        
        let savedLinesVisible = defaults.integer(forKey: "widgetLinesVisible")
        let linesVisible = savedLinesVisible == 0 ? 5 : savedLinesVisible
        
        // Load current song
        var currentSong: LRCSearchResult? = nil
        var currentLines: [LyricLine] = []
        if let data = defaults.data(forKey: "currentSongData") {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            if let song = try? decoder.decode(LRCSearchResult.self, from: data) {
                currentSong = song
                
                // Parse lines
                if let synced = song.syncedLyrics {
                    currentLines = LRCParser.parse(synced)
                } else if let plain = song.plainLyrics, !plain.isEmpty {
                    currentLines = plain.components(separatedBy: "\n")
                        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                        .map { $0.isEmpty ? " " : $0 }
                        .enumerated()
                        .map { LyricLine(timestamp: Double($0.offset), text: $0.element) }
                }
            }
        }
        
        let currentLineIndex = defaults.integer(forKey: "currentLineIndex")
        
        return LyricsEntry(
            date: Date(),
            trackName: currentSong?.trackName ?? "No Song Selected",
            artistName: currentSong?.artistName ?? "Open Lyrico to select lyrics",
            lines: currentLines,
            currentIndex: currentLineIndex,
            backgroundColorHex: backgroundColorHex,
            textColorHex: textColorHex,
            highlightColorHex: highlightColorHex,
            fontSize: fontSize,
            linesVisible: linesVisible
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
