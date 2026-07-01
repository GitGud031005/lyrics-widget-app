# Phase 2 — Core App Code

> **Where:** Windows PC (VS Code)  
> **Time:** ~1 hour  
> **Prerequisite:** Phase 0 + 1 complete (repo cloned, Xcode project exists)  
> **Goal:** Write all Swift source files for the main app (search, display, storage)

---

## Checklist

- [ ] Create folder structure
- [ ] Write `LyricsModel.swift`
- [ ] Write `LyricsAPI.swift`
- [ ] Write `LyricsStore.swift`
- [ ] Write `LyricsSearchView.swift`
- [ ] Write `LyricsDisplayView.swift`
- [ ] Update `LyricsWidgetApp.swift`
- [ ] Delete `ContentView.swift`
- [ ] Update `project.pbxproj` to register new files
- [ ] Commit and push

---

## Overview: What We're Building

The main app has 3 responsibilities:
1. **Search** for song lyrics via the LRCLIB API
2. **Display** the full lyrics with line highlighting
3. **Save** the selected lyrics to shared storage so the widget can read them

```
User flow:
  Search tab → type song name → see results → tap one
  → full lyrics appear with highlighted current line
  → tap "Set as Widget" → lyrics saved to App Groups
  → widget shows the lyrics on home screen
```

---

## Step 1: Create Folder Structure

In your project, create these folders inside `LyricsWidget/`:

```powershell
cd c:\Users\phucl\OneDrive\Desktop\phuc\Projects\autoscroll-lyrics-widget
mkdir LyricsWidget\Models
mkdir LyricsWidget\Services
mkdir LyricsWidget\Views
mkdir LyricsWidget\Storage
```

---

## Step 2: Create LyricsModel.swift

Create file: `LyricsWidget/Models/LyricsModel.swift`

```swift
import Foundation

// MARK: - LRCLIB API Response Models

/// Represents a single track result from the LRCLIB API
struct LRCSearchResult: Codable, Identifiable, Hashable {
    let id: Int
    let trackName: String
    let artistName: String
    let albumName: String?
    let duration: Double
    let plainLyrics: String?
    let syncedLyrics: String?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: LRCSearchResult, rhs: LRCSearchResult) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Parsed Lyric Line

/// A single line of lyrics with a timestamp (parsed from LRC format)
struct LyricLine: Codable, Identifiable, Equatable {
    let id: UUID
    let timestamp: TimeInterval   // seconds from start of song
    let text: String
    
    init(timestamp: TimeInterval, text: String) {
        self.id = UUID()
        self.timestamp = timestamp
        self.text = text
    }
    
    /// Format timestamp as "m:ss"
    var formattedTime: String {
        let minutes = Int(timestamp) / 60
        let seconds = Int(timestamp) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - LRC Parser

/// Parses LRC-format synchronized lyrics into an array of LyricLine
///
/// LRC format example:
/// ```
/// [00:12.34] First line of the song
/// [00:15.67] Second line of the song
/// ```
enum LRCParser {
    
    /// Parse an LRC string into sorted lyric lines
    static func parse(_ lrcString: String) -> [LyricLine] {
        let lines = lrcString.components(separatedBy: "\n")
        var result: [LyricLine] = []
        
        // Match patterns like [01:23.45] or [01:23.456]
        let pattern = #"\[(\d{1,2}):(\d{2})\.(\d{2,3})\]\s*(.*)"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return []
        }
        
        for line in lines {
            let range = NSRange(line.startIndex..., in: line)
            guard let match = regex.firstMatch(in: line, range: range) else {
                continue
            }
            
            guard let minRange = Range(match.range(at: 1), in: line),
                  let secRange = Range(match.range(at: 2), in: line),
                  let msRange = Range(match.range(at: 3), in: line),
                  let textRange = Range(match.range(at: 4), in: line) else {
                continue
            }
            
            let minutes = Double(line[minRange]) ?? 0
            let seconds = Double(line[secRange]) ?? 0
            let msString = String(line[msRange])
            let ms = Double(msString) ?? 0
            
            // Handle both 2-digit (centiseconds) and 3-digit (milliseconds)
            let msDivisor: Double = msString.count >= 3 ? 1000.0 : 100.0
            let timestamp = minutes * 60.0 + seconds + ms / msDivisor
            
            let text = String(line[textRange]).trimmingCharacters(in: .whitespaces)
            
            // Skip empty lines
            guard !text.isEmpty else { continue }
            
            result.append(LyricLine(timestamp: timestamp, text: text))
        }
        
        return result.sorted { $0.timestamp < $1.timestamp }
    }
}
```

---

## Step 3: Create LyricsAPI.swift

Create file: `LyricsWidget/Services/LyricsAPI.swift`

```swift
import Foundation

// MARK: - LRCLIB API Client

/// Client for the LRCLIB lyrics API
/// API docs: https://lrclib.net/docs
/// - Free, no authentication required
/// - Provides both synced (LRC) and plain-text lyrics
/// - Requires a descriptive User-Agent header
actor LyricsAPI {
    static let shared = LyricsAPI()
    
    private let baseURL = "https://lrclib.net/api"
    private let session: URLSession
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15
        config.httpAdditionalHeaders = [
            "User-Agent": "Lyrico iOS App/1.0.0 (https://github.com/YOUR_USERNAME/lyrics-widget-app)"
        ]
        self.session = URLSession(configuration: config)
    }
    
    // MARK: - Search
    
    /// Search for tracks matching a query string
    /// Endpoint: GET /api/search?q={query}
    /// Returns: Array of matching tracks with lyrics
    func search(query: String) async throws -> [LRCSearchResult] {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            return []
        }
        
        var components = URLComponents(string: "\(baseURL)/search")!
        components.queryItems = [
            URLQueryItem(name: "q", value: query)
        ]
        
        guard let url = components.url else {
            throw LyricsAPIError.invalidURL
        }
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw LyricsAPIError.requestFailed(statusCode: 0)
        }
        
        guard httpResponse.statusCode == 200 else {
            throw LyricsAPIError.requestFailed(statusCode: httpResponse.statusCode)
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode([LRCSearchResult].self, from: data)
    }
    
    // MARK: - Get by ID
    
    /// Fetch a specific track's lyrics by LRCLIB ID
    /// Endpoint: GET /api/get/{id}
    func getTrack(id: Int) async throws -> LRCSearchResult {
        guard let url = URL(string: "\(baseURL)/get/\(id)") else {
            throw LyricsAPIError.invalidURL
        }
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw LyricsAPIError.requestFailed(statusCode: 0)
        }
        
        guard httpResponse.statusCode == 200 else {
            throw LyricsAPIError.requestFailed(statusCode: httpResponse.statusCode)
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(LRCSearchResult.self, from: data)
    }
    
    // MARK: - Get by Metadata
    
    /// Fetch lyrics by exact track metadata
    /// Endpoint: GET /api/get?track_name={}&artist_name={}&album_name={}&duration={}
    func getLyrics(
        trackName: String,
        artistName: String,
        albumName: String? = nil,
        duration: TimeInterval? = nil
    ) async throws -> LRCSearchResult? {
        var components = URLComponents(string: "\(baseURL)/get")!
        var queryItems = [
            URLQueryItem(name: "track_name", value: trackName),
            URLQueryItem(name: "artist_name", value: artistName)
        ]
        if let album = albumName {
            queryItems.append(URLQueryItem(name: "album_name", value: album))
        }
        if let dur = duration {
            queryItems.append(URLQueryItem(name: "duration", value: String(Int(dur))))
        }
        components.queryItems = queryItems
        
        guard let url = components.url else {
            throw LyricsAPIError.invalidURL
        }
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw LyricsAPIError.requestFailed(statusCode: 0)
        }
        
        // 404 = not found (not an error, just no results)
        if httpResponse.statusCode == 404 { return nil }
        
        guard httpResponse.statusCode == 200 else {
            throw LyricsAPIError.requestFailed(statusCode: httpResponse.statusCode)
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(LRCSearchResult.self, from: data)
    }
}

// MARK: - Error Types

enum LyricsAPIError: LocalizedError {
    case invalidURL
    case requestFailed(statusCode: Int)
    case decodingFailed
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .requestFailed(let code):
            return "Request failed (HTTP \(code))"
        case .decodingFailed:
            return "Failed to decode response"
        }
    }
}
```

---

## Step 4: Create LyricsStore.swift

Create file: `LyricsWidget/Storage/LyricsStore.swift`

```swift
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
        self.fontSize = UserDefaults.standard.double(forKey: Keys.fontSize)
        if self.fontSize == 0 { self.fontSize = 14.0 }
        self.linesVisible = UserDefaults.standard.integer(forKey: Keys.linesVisible)
        if self.linesVisible == 0 { self.linesVisible = 5 }
        
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
```

---

## Step 5: Create LyricsSearchView.swift

Create file: `LyricsWidget/Views/LyricsSearchView.swift`

```swift
import SwiftUI

// MARK: - Search View

/// Main view: search for songs and pick lyrics to display on the widget
struct LyricsSearchView: View {
    @EnvironmentObject var store: LyricsStore
    
    @State private var searchText = ""
    @State private var results: [LRCSearchResult] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var searchTask: Task<Void, Never>?
    @State private var selectedSong: LRCSearchResult?
    @State private var showingLyrics = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [
                        Color(hex: "#0F0F1A"),
                        Color(hex: "#1A1A2E"),
                        Color(hex: "#16213E")
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Search bar
                    searchBar
                    
                    // Content
                    if isLoading {
                        loadingView
                    } else if let error = errorMessage {
                        errorView(error)
                    } else if results.isEmpty && !searchText.isEmpty {
                        emptyView
                    } else if results.isEmpty {
                        welcomeView
                    } else {
                        resultsList
                    }
                }
            }
            .navigationTitle("Lyrico")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .navigationDestination(isPresented: $showingLyrics) {
                if let song = selectedSong {
                    LyricsDisplayView(song: song)
                        .environmentObject(store)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
    
    // MARK: - Search Bar
    
    private var searchBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
                .font(.system(size: 18))
            
            TextField("Search song or artist...", text: $searchText)
                .foregroundColor(.white)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .onSubmit { performSearch() }
                .onChange(of: searchText) { _, newValue in
                    debounceSearch(query: newValue)
                }
            
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                    results = []
                    errorMessage = nil
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 16)
    }
    
    // MARK: - Results List
    
    private var resultsList: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(results) { result in
                    resultRow(result)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 32)
        }
    }
    
    private func resultRow(_ result: LRCSearchResult) -> some View {
        Button(action: {
            selectedSong = result
            showingLyrics = true
        }) {
            HStack(spacing: 14) {
                // Music icon
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "#E94560"), Color(hex: "#C23152")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: "music.note")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                // Song info
                VStack(alignment: .leading, spacing: 4) {
                    Text(result.trackName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    Text(result.artistName)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .lineLimit(1)
                    
                    if let album = result.albumName, !album.isEmpty {
                        Text(album)
                            .font(.system(size: 12))
                            .foregroundColor(.gray.opacity(0.7))
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                // Synced indicator
                VStack(spacing: 4) {
                    if result.syncedLyrics != nil {
                        Label("Synced", systemImage: "clock")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(Color(hex: "#4ECCA3"))
                    } else if result.plainLyrics != nil {
                        Label("Plain", systemImage: "text.alignleft")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.orange)
                    }
                    
                    // Duration
                    let minutes = Int(result.duration) / 60
                    let seconds = Int(result.duration) % 60
                    Text(String(format: "%d:%02d", minutes, seconds))
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(.gray)
                }
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.gray.opacity(0.5))
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.06), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - State Views
    
    private var welcomeView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "music.note.list")
                .font(.system(size: 60))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(hex: "#E94560"), Color(hex: "#4ECCA3")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text("Search for Lyrics")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
            
            Text("Find a song and set its lyrics\nas your home screen widget")
                .font(.system(size: 16))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            if let song = store.currentSong {
                Divider()
                    .background(Color.white.opacity(0.1))
                    .padding(.horizontal, 40)
                
                VStack(spacing: 8) {
                    Text("Currently on widget:")
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                    
                    Text("\(song.trackName) — \(song.artistName)")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(Color(hex: "#4ECCA3"))
                        .multilineTextAlignment(.center)
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 32)
    }
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            Spacer()
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "#E94560")))
                .scaleEffect(1.2)
            Text("Searching...")
                .font(.system(size: 16))
                .foregroundColor(.gray)
            Spacer()
        }
    }
    
    private func errorView(_ message: String) -> some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 40))
                .foregroundColor(.orange)
            Text(message)
                .font(.system(size: 16))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            Button("Try Again") { performSearch() }
                .foregroundColor(Color(hex: "#E94560"))
                .font(.system(size: 16, weight: .semibold))
            Spacer()
        }
        .padding(.horizontal, 32)
    }
    
    private var emptyView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "magnifyingglass")
                .font(.system(size: 40))
                .foregroundColor(.gray)
            Text("No results found")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            Text("Try a different search term")
                .font(.system(size: 14))
                .foregroundColor(.gray)
            Spacer()
        }
    }
    
    // MARK: - Search Logic
    
    private func debounceSearch(query: String) {
        searchTask?.cancel()
        
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            results = []
            errorMessage = nil
            isLoading = false
            return
        }
        
        searchTask = Task {
            // Wait 500ms for debounce
            try? await Task.sleep(nanoseconds: 500_000_000)
            
            guard !Task.isCancelled else { return }
            
            await performSearch()
        }
    }
    
    @MainActor
    private func performSearch() {
        let query = searchText.trimmingCharacters(in: .whitespaces)
        guard !query.isEmpty else { return }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let searchResults = try await LyricsAPI.shared.search(query: query)
                
                guard !Task.isCancelled else { return }
                
                await MainActor.run {
                    self.results = searchResults
                    self.isLoading = false
                }
            } catch {
                guard !Task.isCancelled else { return }
                
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
}
```

---

## Step 6: Create LyricsDisplayView.swift

Create file: `LyricsWidget/Views/LyricsDisplayView.swift`

```swift
import SwiftUI

// MARK: - Lyrics Display View

/// Full-screen view showing all lyrics for a song.
/// The user can scroll through, tap to highlight lines,
/// and set the song as the active widget content.
struct LyricsDisplayView: View {
    @EnvironmentObject var store: LyricsStore
    @Environment(\.dismiss) var dismiss
    
    let song: LRCSearchResult
    
    @State private var lines: [LyricLine] = []
    @State private var highlightedIndex: Int = 0
    @State private var isSetAsWidget = false
    @State private var showConfirmation = false
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    Color(hex: "#0F0F1A"),
                    Color(hex: "#1A1A2E")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Song header
                songHeader
                
                Divider()
                    .background(Color.white.opacity(0.1))
                
                // Lyrics content
                if !lines.isEmpty {
                    syncedLyricsView
                } else if let plain = song.plainLyrics, !plain.isEmpty {
                    plainLyricsView(plain)
                } else {
                    noLyricsView
                }
                
                // Bottom bar
                bottomBar
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onAppear {
            if let synced = song.syncedLyrics {
                lines = LRCParser.parse(synced)
            }
            // Check if this song is already the widget song
            isSetAsWidget = store.currentSong?.id == song.id
        }
        .overlay {
            if showConfirmation {
                confirmationToast
            }
        }
    }
    
    // MARK: - Song Header
    
    private var songHeader: some View {
        VStack(spacing: 8) {
            // Song icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#E94560"), Color(hex: "#C23152")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 64, height: 64)
                
                Image(systemName: "music.note")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(.white)
            }
            .padding(.top, 16)
            
            Text(song.trackName)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Text(song.artistName)
                .font(.system(size: 16))
                .foregroundColor(.gray)
            
            if let album = song.albumName, !album.isEmpty {
                Text(album)
                    .font(.system(size: 14))
                    .foregroundColor(.gray.opacity(0.7))
            }
            
            // Tags
            HStack(spacing: 8) {
                if song.syncedLyrics != nil {
                    tagView(text: "Synced", color: Color(hex: "#4ECCA3"))
                }
                if song.plainLyrics != nil {
                    tagView(text: "Plain Text", color: .orange)
                }
                
                let minutes = Int(song.duration) / 60
                let seconds = Int(song.duration) % 60
                tagView(
                    text: String(format: "%d:%02d", minutes, seconds),
                    color: .gray
                )
            }
            .padding(.top, 4)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }
    
    private func tagView(text: String, color: Color) -> some View {
        Text(text)
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(color.opacity(0.15))
            )
    }
    
    // MARK: - Synced Lyrics View
    
    private var syncedLyricsView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 6) {
                    ForEach(Array(lines.enumerated()), id: \.element.id) { index, line in
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                highlightedIndex = index
                            }
                        }) {
                            HStack(spacing: 12) {
                                // Timestamp
                                Text(line.formattedTime)
                                    .font(.system(size: 12, design: .monospaced))
                                    .foregroundColor(
                                        index == highlightedIndex
                                            ? Color(hex: "#E94560")
                                            : .gray.opacity(0.4)
                                    )
                                    .frame(width: 40, alignment: .trailing)
                                
                                // Lyric text
                                Text(line.text)
                                    .font(.system(
                                        size: index == highlightedIndex ? 18 : 16,
                                        weight: index == highlightedIndex ? .bold : .regular
                                    ))
                                    .foregroundColor(
                                        index == highlightedIndex
                                            ? .white
                                            : .gray.opacity(0.6)
                                    )
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .multilineTextAlignment(.leading)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(
                                        index == highlightedIndex
                                            ? Color(hex: "#E94560").opacity(0.1)
                                            : Color.clear
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                        .id(index)
                    }
                }
                .padding(.vertical, 16)
            }
            .onChange(of: highlightedIndex) { _, newValue in
                withAnimation {
                    proxy.scrollTo(newValue, anchor: .center)
                }
            }
        }
    }
    
    // MARK: - Plain Lyrics View
    
    private func plainLyricsView(_ text: String) -> some View {
        ScrollView {
            Text(text)
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.8))
                .lineSpacing(8)
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    // MARK: - No Lyrics
    
    private var noLyricsView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "text.page.slash")
                .font(.system(size: 40))
                .foregroundColor(.gray)
            Text("No lyrics available")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            Text("This track doesn't have lyrics in the database")
                .font(.system(size: 14))
                .foregroundColor(.gray)
            Spacer()
        }
    }
    
    // MARK: - Bottom Bar
    
    private var bottomBar: some View {
        VStack(spacing: 0) {
            Divider()
                .background(Color.white.opacity(0.1))
            
            Button(action: setAsWidget) {
                HStack(spacing: 10) {
                    Image(systemName: isSetAsWidget ? "checkmark.circle.fill" : "rectangle.on.rectangle")
                        .font(.system(size: 18))
                    
                    Text(isSetAsWidget ? "Active on Widget" : "Set as Widget Lyrics")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(
                            isSetAsWidget
                                ? Color(hex: "#4ECCA3")
                                : LinearGradient(
                                    colors: [Color(hex: "#E94560"), Color(hex: "#C23152")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                        )
                )
            }
            .disabled(song.syncedLyrics == nil && song.plainLyrics == nil)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(Color(hex: "#0F0F1A").opacity(0.95))
    }
    
    // MARK: - Actions
    
    private func setAsWidget() {
        store.selectSong(song)
        store.currentLineIndex = highlightedIndex
        
        isSetAsWidget = true
        showConfirmation = true
        
        // Auto-hide confirmation
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation { showConfirmation = false }
        }
    }
    
    // MARK: - Toast
    
    private var confirmationToast: some View {
        VStack {
            Spacer()
            
            HStack(spacing: 10) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(Color(hex: "#4ECCA3"))
                Text("Lyrics saved to widget!")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background(
                Capsule()
                    .fill(Color(hex: "#1A1A2E"))
                    .overlay(
                        Capsule()
                            .stroke(Color(hex: "#4ECCA3").opacity(0.3), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.3), radius: 10)
            )
            .padding(.bottom, 100)
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .animation(.spring(response: 0.3), value: showConfirmation)
    }
}
```

---

## Step 7: Update LyricsWidgetApp.swift

**Replace the entire content** of `LyricsWidget/LyricsWidgetApp.swift` with:

```swift
import SwiftUI

@main
struct LyricsWidgetApp: App {
    @StateObject private var store = LyricsStore.shared
    
    var body: some Scene {
        WindowGroup {
            LyricsSearchView()
                .environmentObject(store)
        }
    }
}
```

---

## Step 8: Delete ContentView.swift

Delete the file `LyricsWidget/ContentView.swift` — it was Xcode's default file and we've replaced it with our own views.

```powershell
Remove-Item "LyricsWidget\ContentView.swift"
```

---

## Step 9: Update project.pbxproj

This is the trickiest part. The `project.pbxproj` file tells Xcode which files are part of the project. Since we added new files from Windows (not through Xcode's "Add File" dialog), Xcode doesn't know about them yet.

### Option A: Quick Fix on Your Mac Session (Recommended)

During Phase 5 (Mac Session #2), simply:
1. Open the project in Xcode
2. Right-click the `LyricsWidget` folder in the sidebar
3. Choose "Add Files to 'LyricsWidget'..."
4. Select all the new `.swift` files
5. Make sure "Add to targets: LyricsWidget" is checked
6. Click Add

This is the safest method and takes 30 seconds.

### Option B: Manual project.pbxproj Edit (Advanced)

If you want GitHub Actions to build the project BEFORE your Mac session, you'll need to edit `project.pbxproj` manually. This is complex but doable — **I'll generate the exact edits when you're ready for this step.** Just let me know.

The key concept: every file in an Xcode project needs:
1. A `PBXFileReference` entry (declares the file exists)
2. A `PBXBuildFile` entry (links it to a target for compilation)
3. An entry in the `PBXGroup` children (puts it in the file tree)
4. An entry in `PBXSourcesBuildPhase` (compiles it)

Each entry needs a unique 24-character hex UUID.

---

## Step 10: Commit and Push

```powershell
cd c:\Users\phucl\OneDrive\Desktop\phuc\Projects\autoscroll-lyrics-widget
git add .
git commit -m "add core app code: models, API, storage, search and display views"
git push origin main
```

---

## File Summary

After this phase, your `LyricsWidget/` folder looks like:

```
LyricsWidget/
├── LyricsWidgetApp.swift              (modified — launches SearchView)
├── Models/
│   └── LyricsModel.swift              (LRCSearchResult, LyricLine, LRCParser)
├── Services/
│   └── LyricsAPI.swift                (LRCLIB client — search, get)
├── Storage/
│   └── LyricsStore.swift              (shared storage, settings, Color helper)
├── Views/
│   ├── LyricsSearchView.swift         (search bar, results, navigation)
│   └── LyricsDisplayView.swift        (lyrics display, highlight, set-as-widget)
├── Assets.xcassets/
└── Preview Content/
```

---

## What's Next

→ **[Phase 3: GitHub Actions CI](./phase-3-github-actions.md)** — set up the automated build pipeline
