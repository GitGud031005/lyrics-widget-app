import Foundation
import SwiftUI
import WidgetKit

// MARK: - Shared Storage (App ↔ Widget via App Groups)

/// Central storage for lyrics data and widget settings.
/// Uses UserDefaults with an App Group suite so both the main app
/// and the widget extension can read/write the same data.
@MainActor
class LyricsStore: ObservableObject {
    static let shared = LyricsStore()
    
    // MARK: - App Group Configuration
    
    private var defaults: UserDefaults {
        if let groupDefaults = UserDefaults(suiteName: AppGroupHelper.appGroupID) {
            return groupDefaults
        }
        return .standard
    }
    
    // MARK: - Current Song
    
    /// The currently selected song for the widget
    @Published var currentSong: LRCSearchResult? {
        didSet {
            persistSong()
            if !isBatchUpdating { reloadWidget() }
        }
    }
    
    /// Parsed lyric lines from the current song's synced lyrics
    @Published var currentLines: [LyricLine] = []
    
    /// Index of the currently highlighted line in the widget
    @Published var currentLineIndex: Int = 0 {
        didSet {
            defaults.set(currentLineIndex, forKey: Keys.lineIndex)
            if !isBatchUpdating { reloadWidget() }
        }
    }
    
    // MARK: - Widget Appearance Settings
    
    @Published var backgroundColorHex: String {
        didSet {
            defaults.set(backgroundColorHex, forKey: Keys.bgColor)
            if !isBatchUpdating { reloadWidget() }
        }
    }
    
    @Published var textColorHex: String {
        didSet {
            defaults.set(textColorHex, forKey: Keys.textColor)
            if !isBatchUpdating { reloadWidget() }
        }
    }
    
    @Published var highlightColorHex: String {
        didSet {
            defaults.set(highlightColorHex, forKey: Keys.highlightColor)
            if !isBatchUpdating { reloadWidget() }
        }
    }
    
    @Published var fontSize: Double {
        didSet {
            defaults.set(fontSize, forKey: Keys.fontSize)
            if !isBatchUpdating { reloadWidget() }
        }
    }
    
    @Published var linesVisible: Int {
        didSet {
            defaults.set(linesVisible, forKey: Keys.linesVisible)
            if !isBatchUpdating { reloadWidget() }
        }
    }
    
    // MARK: - Default Values
    
    nonisolated static let defaultBgColorHex = "#F4E9D0"
    nonisolated static let defaultTextColorHex = "#3A2C5C"
    nonisolated static let defaultHighlightColorHex = "#E08244"

    // MARK: - Keys
    
    private enum Keys {
        static let songData = "currentSongData"
        static let lineIndex = "currentLineIndex"
        static let bgColor = "widgetBgColor"
        static let textColor = "widgetTextColor"
        static let highlightColor = "widgetHighlightColor"
        static let fontSize = "widgetFontSize"
        static let linesVisible = "widgetLinesVisible"
        static let recentlyPlayed = "recentlyPlayedSongsData"
    }
    
    // MARK: - Init
    
    /// Flag to temporarily suspend widget timeline reloads during batch updates.
    private var isBatchUpdating = false
    
    @Published var recentlyPlayed: [LRCSearchResult] = [] {
        didSet {
            persistRecentlyPlayed()
        }
    }
    
    private init() {
        let groupDefaults = UserDefaults(suiteName: AppGroupHelper.appGroupID) ?? .standard
        
        self.isBatchUpdating = true
        
        // Load appearance settings with defaults
        self.backgroundColorHex = groupDefaults.string(forKey: Keys.bgColor) ?? LyricsStore.defaultBgColorHex
        self.textColorHex = groupDefaults.string(forKey: Keys.textColor) ?? LyricsStore.defaultTextColorHex
        self.highlightColorHex = groupDefaults.string(forKey: Keys.highlightColor) ?? LyricsStore.defaultHighlightColorHex
        
        let savedFontSize = groupDefaults.double(forKey: Keys.fontSize)
        self.fontSize = savedFontSize == 0 ? 16.0 : savedFontSize
        
        let savedLinesVisible = groupDefaults.integer(forKey: Keys.linesVisible)
        self.linesVisible = savedLinesVisible == 0 ? 3 : savedLinesVisible

        // Load current song
        loadSong()
        
        // Load recently played history
        loadRecentlyPlayed()
        
        self.isBatchUpdating = false
    }
    
    // MARK: - Song Persistence
    
    /// Save a song as the active widget song
    func selectSong(_ song: LRCSearchResult, initialIndex: Int = 0) {
        performBatchUpdate {
            self.currentSong = song
            self.currentLines = parseLines(for: song)
            self.currentLineIndex = initialIndex
            
            // Add to recently played list
            var updated = recentlyPlayed.filter { $0.id != song.id }
            updated.insert(song, at: 0)
            if updated.count > 5 {
                updated = Array(updated.prefix(5))
            }
            self.recentlyPlayed = updated
        }
    }
    
    /// Update multiple properties in a single transaction, reloading the widget exactly once
    func performBatchUpdate(_ updates: () -> Void) {
        let wasBatchUpdating = isBatchUpdating
        isBatchUpdating = true
        updates()
        isBatchUpdating = wasBatchUpdating
        if !isBatchUpdating {
            reloadWidget()
        }
    }
    
    private func parseLines(for song: LRCSearchResult) -> [LyricLine] {
        if let synced = song.syncedLyrics {
            return LRCParser.parse(synced)
        } else if let plain = song.plainLyrics, !plain.isEmpty {
            // Fallback: Parse plain lyrics line-by-line so they are scrollable on the widget
            return plain.components(separatedBy: "\n")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .map { $0.isEmpty ? " " : $0 }
                .enumerated()
                .map { LyricLine(timestamp: Double($0.offset), text: $0.element) }
        }
        return []
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
        self.currentLines = parseLines(for: song)
        self.currentLineIndex = defaults.integer(forKey: Keys.lineIndex)
    }
    
    private func persistRecentlyPlayed() {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        if let data = try? encoder.encode(recentlyPlayed) {
            defaults.set(data, forKey: Keys.recentlyPlayed)
        }
    }
    
    private func loadRecentlyPlayed() {
        guard let data = defaults.data(forKey: Keys.recentlyPlayed) else { return }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        if let list = try? decoder.decode([LRCSearchResult].self, from: data) {
            self.recentlyPlayed = list
        }
    }
    
    // MARK: - Widget Control
    
    /// Advance to the next lyric line
    func advanceLine(reload: Bool = true) {
        guard !currentLines.isEmpty else { return }
        if reload {
            currentLineIndex = min(currentLineIndex + 1, currentLines.count - 1)
        } else {
            let wasBatchUpdating = isBatchUpdating
            isBatchUpdating = true
            currentLineIndex = min(currentLineIndex + 1, currentLines.count - 1)
            isBatchUpdating = wasBatchUpdating
        }
    }
    
    /// Go back to the previous lyric line
    func previousLine(reload: Bool = true) {
        guard !currentLines.isEmpty else { return }
        if reload {
            currentLineIndex = max(currentLineIndex - 1, 0)
        } else {
            let wasBatchUpdating = isBatchUpdating
            isBatchUpdating = true
            currentLineIndex = max(currentLineIndex - 1, 0)
            isBatchUpdating = wasBatchUpdating
        }
    }
    
    /// Jump to a specific line
    func jumpToLine(_ index: Int, reload: Bool = true) {
        guard index >= 0 && index < currentLines.count else { return }
        if reload {
            currentLineIndex = index
        } else {
            let wasBatchUpdating = isBatchUpdating
            isBatchUpdating = true
            currentLineIndex = index
            isBatchUpdating = wasBatchUpdating
        }
    }
    
    /// Reset to the beginning
    func resetPosition(reload: Bool = true) {
        if reload {
            currentLineIndex = 0
        } else {
            let wasBatchUpdating = isBatchUpdating
            isBatchUpdating = true
            currentLineIndex = 0
            isBatchUpdating = wasBatchUpdating
        }
    }
    
    /// Trigger a reload of all active widgets on the home screen
    func reloadWidget() {
        WidgetCenter.shared.reloadAllTimelines()
    }
}

// MARK: - Color Helpers

extension Color {
    static let lyricBg = Color(hex: "#0F0F1A")
    static let lyricBgSecondary = Color(hex: "#16213E")
    static let lyricCardBg = Color(hex: "#1A1A2E")
    static let lyricHighlight = Color(hex: "#E94560")
    static let lyricHighlightDark = Color(hex: "#C23152")
    static let lyricGreen = Color(hex: "#4ECCA3")
    static let lyricGray = Color(hex: "#8888AA")

    /// Create a Color from a hex string like "#FF5733" or "#FF573380" (with alpha)
    /// If the hex string is invalid, it falls back to the specified default color.
    init(hex: String, fallback: Color = .black) {
        let trimmed = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        let hexCharacters = CharacterSet(charactersIn: "0123456789ABCDEFabcdef")
        
        guard (trimmed.count == 6 || trimmed.count == 8) &&
              CharacterSet(charactersIn: trimmed).isSubset(of: hexCharacters) else {
            self = fallback
            return
        }
        
        let scanner = Scanner(string: trimmed)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        
        let r, g, b, a: Double
        switch trimmed.count {
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
            self = fallback
            return
        }
        
        self.init(red: r, green: g, blue: b, opacity: a)
    }
}

struct AppGroupHelper {
    static let defaultAppGroupID = "group.com.lyrico.LyricsWidget"
    
    static var isAppGroupAccessible: Bool {
        return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID) != nil
    }
    
    static var appGroupID: String {
        // 1. Gather all potential App Group candidates
        var candidates: [String] = []
        
        // Candidate A: Parsed from current bundle profile
        if let url = Bundle.main.url(forResource: "embedded", withExtension: "mobileprovision"),
           let group = parseAppGroup(from: url) {
            candidates.append(group)
        }
        
        // Candidate B: Parsed from parent app bundle profile (for extensions)
        let parentURL = Bundle.main.bundleURL
            .deletingLastPathComponent() // to PlugIns
            .deletingLastPathComponent() // to LyricsWidget.app
            .appendingPathComponent("embedded.mobileprovision")
        
        if let group = parseAppGroup(from: parentURL) {
            candidates.append(group)
        }
        
        // Candidate C: Dynamic Team ID prefixed fallback (Apple Personal Team standard: group.<TeamID>.<AppGroupID>)
        if let suffix = resigningSuffix, !suffix.isEmpty {
            candidates.append("group.\(suffix).com.lyrico.LyricsWidget")
            candidates.append("group.com.lyrico.LyricsWidget.\(suffix)")
        }
        
        // Candidate D: Default fallback
        candidates.append(defaultAppGroupID)
        
        // 2. Query iOS at runtime for the first accessible App Group container
        let fileManager = FileManager.default
        for candidate in candidates {
            if fileManager.containerURL(forSecurityApplicationGroupIdentifier: candidate) != nil {
                return candidate
            }
        }
        
        // 3. If none are accessible, fall back to the most likely signed ID
        if let suffix = resigningSuffix, !suffix.isEmpty {
            return "group.\(suffix).com.lyrico.LyricsWidget"
        }
        return defaultAppGroupID
    }
    
    private static func parseAppGroup(from url: URL) -> String? {
        do {
            let data = try Data(contentsOf: url)
            guard let plistStartData = "<plist".data(using: .utf8),
                  let plistEndData = "</plist>".data(using: .utf8) else {
                return nil
            }
            
            guard let startRange = data.range(of: plistStartData),
                  let endRange = data.range(of: plistEndData, in: startRange.upperBound..<data.count) else {
                return nil
            }
            
            let plistData = data.subdata(in: startRange.lowerBound..<endRange.upperBound)
            
            struct MobileProvision: Decodable {
                let entitlements: Entitlements
                
                enum CodingKeys: String, CodingKey {
                    case entitlements = "Entitlements"
                }
                
                struct Entitlements: Decodable {
                    let appGroups: [String]?
                    
                    enum CodingKeys: String, CodingKey {
                        case appGroups = "com.apple.security.application-groups"
                    }
                }
            }
            
            let provision = try PropertyListDecoder().decode(MobileProvision.self, from: plistData)
            return provision.entitlements.appGroups?.first
        } catch {
            return nil
        }
    }
    
    private static var resigningSuffix: String? {
        guard let bid = Bundle.main.bundleIdentifier else {
            return nil
        }
        
        let parts = bid.components(separatedBy: ".")
        let baseParts = ["com", "lyrico", "LyricsWidget", "LyricsWidgetExtension"]
        let suffixParts = parts.filter { !baseParts.contains($0) }
        
        return suffixParts.first
    }
}
