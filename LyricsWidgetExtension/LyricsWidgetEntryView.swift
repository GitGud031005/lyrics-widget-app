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
