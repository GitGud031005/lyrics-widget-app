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
        
        // Matches one or more timestamp patterns at the start, followed by the remaining text
        let pattern = #"^((?:\[\d{1,2}:\d{2}(?:[\.:]\d{2,3})?\]\s*)+)(.*)"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return []
        }
        
        let timePattern = #"\[(\d{1,2}):(\d{2})(?:[\.:](\d{2,3}))?\]"#
        guard let timeRegex = try? NSRegularExpression(pattern: timePattern) else {
            return []
        }
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
            let range = NSRange(trimmedLine.startIndex..., in: trimmedLine)
            
            guard let match = regex.firstMatch(in: trimmedLine, range: range) else {
                continue
            }
            
            guard let timestampGroupRange = Range(match.range(at: 1), in: trimmedLine),
                  let textRange = Range(match.range(at: 2), in: trimmedLine) else {
                continue
            }
            
            let timestampGroup = String(trimmedLine[timestampGroupRange])
            let text = String(trimmedLine[textRange]).trimmingCharacters(in: .whitespaces)
            
            // Skip empty lyric lines
            guard !text.isEmpty else { continue }
            
            // Parse all individual timestamps inside the timestamp group
            let nsGroup = timestampGroup as NSString
            let groupRange = NSRange(location: 0, length: nsGroup.length)
            let timeMatches = timeRegex.matches(in: timestampGroup, range: groupRange)
            
            for timeMatch in timeMatches {
                guard let minRange = Range(timeMatch.range(at: 1), in: timestampGroup),
                      let secRange = Range(timeMatch.range(at: 2), in: timestampGroup) else {
                    continue
                }
                
                let minutes = Double(timestampGroup[minRange]) ?? 0
                let seconds = Double(timestampGroup[secRange]) ?? 0
                
                var ms: Double = 0
                if let msRange = Range(timeMatch.range(at: 3), in: timestampGroup) {
                    let msString = String(timestampGroup[msRange])
                    let rawMs = Double(msString) ?? 0
                    let msDivisor: Double = msString.count >= 3 ? 1000.0 : 100.0
                    ms = rawMs / msDivisor
                }
                
                let timestamp = minutes * 60.0 + seconds + ms
                result.append(LyricLine(timestamp: timestamp, text: text))
            }
        }
        
        return result.sorted { $0.timestamp < $1.timestamp }
    }
}
