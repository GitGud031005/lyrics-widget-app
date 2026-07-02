import SwiftUI
import WidgetKit
import AppIntents

// MARK: - Widget View

struct LyricsWidgetEntryView : View {
    var entry: LyricsTimelineProvider.Entry
    @Environment(\.widgetFamily) var family

    private var adaptiveFontSize: CGFloat {
        switch family {
        case .systemSmall:
            return min(CGFloat(entry.fontSize), 14.0)
        default:
            return CGFloat(entry.fontSize)
        }
    }
    
    private var adaptiveLinesCount: Int {
        switch family {
        case .systemSmall:
            return 3
        case .systemMedium:
            return 3
        case .systemLarge:
            return 7
        @unknown default:
            return 3
        }
    }

    var body: some View {
        ZStack {
            // Paper Background
            PaperBackground(color: Color(hex: entry.backgroundColorHex))
            
            // Decorative Crease/Fold
            if family != .systemSmall {
                HStack {
                    Spacer()
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [Color.lpInk.opacity(0.12), Color.clear],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: 45)
                    Spacer()
                }
                .allowsHitTesting(false)
            }
            
            VStack(spacing: 8) {
                // Header (Medium/Large)
                if family != .systemSmall {
                    headerView
                    DottedDivider()
                        .opacity(0.4)
                        .scaleEffect(x: 0.9, y: 0.5)
                        .padding(.top, -4)
                }
                
                // Lyrics Viewport
                lyricsWindowView
                
                // Controls (Medium/Large)
                if family != .systemSmall {
                    Spacer(minLength: 0)
                    controlsView
                }
            }
            .padding(family == .systemSmall ? 14 : 16)
            
            // Decorative Elements (Large only)
            if family == .systemLarge {
                VStack {
                    HStack {
                        Spacer()
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.lpPumpkin)
                            .opacity(0.4)
                            .padding(20)
                    }
                    Spacer()
                }
            }
        }
        .containerBackground(Color(hex: entry.backgroundColorHex), for: .widget)
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 1) {
                Text(entry.trackName)
                    .font(DesignSystem.display(size: 13, weight: .black))
                    .foregroundColor(Color(hex: entry.textColorHex))
                    .lineLimit(1)
                
                Text(entry.artistName)
                    .font(DesignSystem.display(size: 10, weight: .medium, italic: true))
                    .foregroundColor(Color(hex: entry.textColorHex).opacity(0.7))
                    .lineLimit(1)
            }
            
            Spacer()
            
            Image(systemName: "music.note")
                .font(.system(size: 12, weight: .black))
                .foregroundColor(Color(hex: entry.highlightColorHex))
                .padding(6)
                .background(
                    PaperCutShape().fill(Color.lpCream2.opacity(0.5))
                )
        }
    }
    
    // MARK: - Lyrics Window
    
    private var lyricsWindowView: some View {
        VStack(alignment: .leading, spacing: 5) {
            if entry.lines.isEmpty {
                Spacer()
                VStack(spacing: 8) {
                    Image(systemName: "text.justify.left")
                        .font(.system(size: 20))
                        .opacity(0.3)
                    Text("Open Lyrico to\nset your song.")
                        .font(DesignSystem.display(size: 12, weight: .bold, italic: true))
                        .multilineTextAlignment(.center)
                }
                .foregroundColor(Color(hex: entry.textColorHex).opacity(0.6))
                .frame(maxWidth: .infinity)
                Spacer()
            } else {
                let visibleRange = getVisibleLineIndices(count: adaptiveLinesCount)
                
                ForEach(visibleRange, id: \.self) { index in
                    if index >= 0 && index < entry.lines.count {
                        let line = entry.lines[index]
                        let isCurrent = (index == entry.currentIndex)
                        
                        Text(line.text)
                            .font(DesignSystem.display(
                                size: isCurrent ? adaptiveFontSize + 2 : adaptiveFontSize,
                                weight: isCurrent ? .black : .medium
                            ))
                            .foregroundColor(
                                isCurrent
                                    ? Color(hex: entry.highlightColorHex)
                                    : Color(hex: entry.textColorHex).opacity(0.55)
                            )
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 3)
                            .padding(.horizontal, 8)
                            .background(
                                ZStack {
                                    if isCurrent {
                                        WashiTape(color: Color(hex: entry.highlightColorHex).opacity(0.25), rotation: .degrees(-1.5))
                                            .padding(.horizontal, -4)
                                    }
                                }
                            )
                            .scaleEffect(isCurrent ? 1.02 : 1.0, anchor: .leading)
                    } else {
                        Text(" ")
                            .font(.system(size: adaptiveFontSize))
                            .padding(.vertical, 3)
                    }
                }
            }
        }
    }
    
    // MARK: - Controls
    
    private var controlsView: some View {
        HStack(spacing: 16) {
            // Backward
            controlButton(icon: "backward.fill", intent: PreviousLineIntent(), color: Color.lpInk.opacity(0.08))
            
            // Reset
            controlButton(icon: "goforward", intent: ResetLineIntent(), color: Color.lpCrimson.opacity(0.12))
            
            // Forward
            controlButton(icon: "forward.fill", intent: AdvanceLineIntent(), color: Color.lpPumpkin.opacity(0.2))
        }
        .padding(.top, 4)
    }
    
    private func controlButton(icon: String, intent: any AppIntent, color: Color) -> some View {
        Button(intent: intent) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .black))
                .foregroundColor(Color.lpInk)
                .frame(width: 40, height: 32)
                .background(
                    PaperCutShape()
                        .fill(color)
                        .overlay(PaperCutShape().stroke(Color.lpInk.opacity(0.15), lineWidth: 1))
                )
                .paperCutShadow()
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Range Calculation
    
    private func getVisibleLineIndices(count: Int) -> [Int] {
        guard !entry.lines.isEmpty else {
            return Array(0..<count)
        }
        let half = count / 2
        var start = entry.currentIndex - half
        if start < 0 { start = 0 }
        if start + count > entry.lines.count {
            start = max(0, entry.lines.count - count)
        }
        return Array(start..<(start + count))
    }
}
