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
