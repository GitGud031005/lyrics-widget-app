import Foundation
import SwiftUI

// MARK: - Shared Storage (App ↔ Widget via App Groups)

/// Central storage for lyrics data and widget settings.
/// Uses UserDefaults with an App Group suite so both the main app
/// and the widget extension can read/write the same data.
///
/// NOTE: The App Group ID will be set up in Phase 5 (Mac Session #2).
/// Until then, this falls back to standard UserDefaults.
class LyricsStore: ObservableObject {
    static let shared = LyricsStore()
    
    // MARK: - App Group Configuration
    
    /// App Group ID — set this after creating the App Group in Phase 5
    /// Format: "group.com.lyrico.LyricsWidget"
    private let appGroupID: String? = nil  // TODO: Set after Phase 5
    
    private var defaults: UserDefaults {
        if let groupID = appGroupID,
           let groupDefaults = UserDefaults(suiteName: groupID) {
            return groupDefaults
        }
        return .standard
    }
    
    // MARK: - Current Song
    
    /// The currently selected song for the widget
    @Published var currentSong: LRCSearchResult? {
        didSet { persistSong() }
    }
    
    /// Parsed lyric lines from the current song's synced lyrics
    @Published var currentLines: [LyricLine] = []
    
    /// Index of the currently highlighted line in the widget
    @Published var currentLineIndex: Int = 0 {
        didSet { defaults.set(currentLineIndex, forKey: Keys.lineIndex) }
    }
    
    // MARK: - Widget Appearance Settings
    
    @Published var backgroundColorHex: String {
        didSet { defaults.set(backgroundColorHex, forKey: Keys.bgColor) }
    }
    
    @Published var textColorHex: String {
        didSet { defaults.set(textColorHex, forKey: Keys.textColor) }
    }
    
    @Published var highlightColorHex: String {
        didSet { defaults.set(highlightColorHex, forKey: Keys.highlightColor) }
    }
    
    @Published var fontSize: Double {
        didSet { defaults.set(fontSize, forKey: Keys.fontSize) }
    }
    
    @Published var linesVisible: Int {
        didSet { defaults.set(linesVisible, forKey: Keys.linesVisible) }
    }
    
    // MARK: - Keys
    
    private enum Keys {
        static let songData = "currentSongData"
        static let lineIndex = "currentLineIndex"
        static let bgColor = "widgetBgColor"
        static let textColor = "widgetTextColor"
        static let highlightColor = "widgetHighlightColor"
        static let fontSize = "widgetFontSize"
        static let linesVisible = "widgetLinesVisible"
    }
    
    // MARK: - Init
    
    private init() {
        // Load appearance settings with defaults
        self.backgroundColorHex = UserDefaults.standard.string(forKey: Keys.bgColor) ?? "#1A1A2E"
        self.textColorHex = UserDefaults.standard.string(forKey: Keys.textColor) ?? "#8888AA"
        self.highlightColorHex = UserDefaults.standard.string(forKey: Keys.highlightColor) ?? "#E94560"
        
        let savedFontSize = UserDefaults.standard.double(forKey: Keys.fontSize)
        self.fontSize = savedFontSize == 0 ? 14.0 : savedFontSize
        
        let savedLinesVisible = UserDefaults.standard.integer(forKey: Keys.linesVisible)
        self.linesVisible = savedLinesVisible == 0 ? 5 : savedLinesVisible
        
        // Load current song
        loadSong()
    }
    
    // MARK: - Song Persistence
    
    /// Save a song as the active widget song
    func selectSong(_ song: LRCSearchResult) {
        self.currentSong = song
        if let synced = song.syncedLyrics {
            self.currentLines = LRCParser.parse(synced)
        } else {
            self.currentLines = []
        }
        self.currentLineIndex = 0
    }
    
    private func persistSong() {
        guard let song = currentSong else {
            defaults.removeObject(forKey: Keys.songData)
            return
        }
        
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        if let data = try? encoder.encode(song) {
            defaults.set(data, forKey: Keys.songData)
        }
    }
    
    private func loadSong() {
        guard let data = defaults.data(forKey: Keys.songData) else { return }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        guard let song = try? decoder.decode(LRCSearchResult.self, from: data) else { return }
        
        self.currentSong = song
        if let synced = song.syncedLyrics {
            self.currentLines = LRCParser.parse(synced)
        }
        self.currentLineIndex = defaults.integer(forKey: Keys.lineIndex)
    }
    
    // MARK: - Widget Control
    
    /// Advance to the next lyric line
    func advanceLine() {
        guard !currentLines.isEmpty else { return }
        currentLineIndex = min(currentLineIndex + 1, currentLines.count - 1)
    }
    
    /// Go back to the previous lyric line
    func previousLine() {
        currentLineIndex = max(currentLineIndex - 1, 0)
    }
    
    /// Jump to a specific line
    func jumpToLine(_ index: Int) {
        guard index >= 0 && index < currentLines.count else { return }
        currentLineIndex = index
    }
    
    /// Reset to the beginning
    func resetPosition() {
        currentLineIndex = 0
    }
}

// MARK: - Color Helpers

extension Color {
    /// Create a Color from a hex string like "#FF5733" or "#FF573380" (with alpha)
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        
        let r, g, b, a: Double
        switch hex.count {
        case 6:
            r = Double((rgbValue & 0xFF0000) >> 16) / 255.0
            g = Double((rgbValue & 0x00FF00) >> 8) / 255.0
            b = Double(rgbValue & 0x0000FF) / 255.0
            a = 1.0
        case 8:
            r = Double((rgbValue & 0xFF000000) >> 24) / 255.0
            g = Double((rgbValue & 0x00FF0000) >> 16) / 255.0
            b = Double((rgbValue & 0x0000FF00) >> 8) / 255.0
            a = Double(rgbValue & 0x000000FF) / 255.0
        default:
            r = 0; g = 0; b = 0; a = 1
        }
        
        self.init(red: r, green: g, blue: b, opacity: a)
    }
}
