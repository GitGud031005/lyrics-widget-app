import SwiftUI

// MARK: - Lyrics Display View

/// Full-screen view showing all lyrics for a song.
@MainActor
struct LyricsDisplayView: View {
    @EnvironmentObject var store: LyricsStore
    @Environment(\.dismiss) var dismiss
    
    let song: LRCSearchResult
    
    @State private var lines: [LyricLine] = []
    @State private var highlightedIndex: Int = 0
    @State private var isSetAsWidget = false
    @State private var showConfirmation = false
    
    private var themeBg: Color { Color(hex: store.backgroundColorHex) }
    private var themeText: Color { Color(hex: store.textColorHex) }
    private var themeHighlight: Color { Color(hex: store.highlightColorHex) }
    
    var body: some View {
        ZStack {
            PaperBackground(color: themeBg)
            
            VStack(spacing: 0) {
                // Song header
                songHeader
                
                DottedDivider()
                    .padding(.horizontal, 24)
                
                // Lyrics content
                ZStack {
                    if !lines.isEmpty {
                        syncedLyricsView
                    } else if let plain = song.plainLyrics, !plain.isEmpty {
                        plainLyricsView(plain)
                    } else {
                        noLyricsView
                    }
                    
                    // Decorative Fox (bottom left)
                    VStack {
                        Spacer()
                        HStack {
                            AsyncImage(url: URL(string: "https://kombai-assets.b-cdn.net/generated_assets/546bcd6a-ae6d-45c1-85a6-b370c2cc2f99/7faea13a823a42299a4a3a537ac4b85b.jpg")) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 70, height: 90)
                                    .clipShape(PaperCutShape())
                                    .overlay(PaperCutShape().stroke(themeText, lineWidth: 1))
                                    .paperCutShadow()
                                    .opacity(0.3)
                                    .rotationEffect(.degrees(-5))
                            } placeholder: {
                                EmptyView()
                            }
                            Spacer()
                        }
                    }
                    .padding(20)
                    .allowsHitTesting(false)
                }
                
                // Bottom bar
                bottomBar
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if let synced = song.syncedLyrics {
                lines = LRCParser.parse(synced)
            } else if let plain = song.plainLyrics, !plain.isEmpty {
                lines = plain.components(separatedBy: "\n")
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .map { $0.isEmpty ? " " : $0 }
                    .enumerated()
                    .map { LyricLine(timestamp: Double($0.offset), text: $0.element) }
            }
            isSetAsWidget = store.currentSong?.id == song.id
            if isSetAsWidget {
                highlightedIndex = store.currentLineIndex
            }
        }
        .overlay {
            if showConfirmation {
                confirmationToast
            }
        }
    }
    
    // MARK: - Song Header
    
    private var songHeader: some View {
        VStack(spacing: 6) {
            Text(song.trackName)
                .font(DesignSystem.display(size: 26, weight: .black))
                .foregroundColor(themeText)
                .multilineTextAlignment(.center)
                .lineLimit(2)
            
            Text(song.artistName)
                .font(DesignSystem.display(size: 16, weight: .medium, italic: true))
                .foregroundColor(themeText.opacity(0.7))
            
            // Meta Info
            HStack(spacing: 12) {
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.system(size: 10))
                    Text(formatDuration(song.duration))
                        .font(.system(size: 11, design: .monospaced))
                }
                .foregroundColor(themeText.opacity(0.5))
                
                if song.syncedLyrics != nil {
                    tagView(text: "SYNCED", color: themeHighlight.opacity(0.2))
                } else {
                    tagView(text: "PLAIN TEXT", color: themeText.opacity(0.1))
                }
            }
            .padding(.top, 4)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
    }
    
    private func tagView(text: String, color: Color) -> some View {
        Text(text)
            .font(.system(size: 9, weight: .black))
            .tracking(1)
            .foregroundColor(themeText)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                PaperCutShape()
                    .fill(color)
                    .overlay(PaperCutShape().stroke(themeText, lineWidth: 1))
            )
    }
    
    private func formatDuration(_ duration: Double) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    // MARK: - Synced Lyrics View
    
    private var syncedLyricsView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(Array(lines.enumerated()), id: \.element.id) { index, line in
                        Button(action: {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                highlightedIndex = index
                            }
                        }) {
                            HStack(spacing: 16) {
                                // Timestamp
                                Text(line.formattedTime)
                                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                                    .foregroundColor(themeText.opacity(index == highlightedIndex ? 0.8 : 0.15))
                                    .frame(width: 45, alignment: .trailing)
                                
                                // Lyric text
                                Text(line.text)
                                    .font(DesignSystem.display(
                                        size: index == highlightedIndex ? 22 : 16,
                                        weight: index == highlightedIndex ? .black : .medium
                                    ))
                                    .foregroundColor(index == highlightedIndex ? themeText : themeText.opacity(0.4))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .multilineTextAlignment(.leading)
                                    .scaleEffect(index == highlightedIndex ? 1.05 : 1.0, anchor: .leading)
                            }
                            .padding(.horizontal, 24)
                            .padding(.vertical, 14)
                            .background(
                                ZStack {
                                    if index == highlightedIndex {
                                        WashiTape(color: themeHighlight, rotation: .degrees(-0.8))
                                            .transition(.asymmetric(
                                                insertion: .scale(scale: 0.95).combined(with: .opacity),
                                                removal: .opacity
                                            ))
                                    }
                                }
                            )
                        }
                        .buttonStyle(.plain)
                        .id(index)
                    }
                }
                .padding(.vertical, 24)
            }
            .onChange(of: highlightedIndex) { _, newValue in
                withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
                    proxy.scrollTo(newValue, anchor: .center)
                }
            }
            .onAppear {
                proxy.scrollTo(highlightedIndex, anchor: .center)
            }
        }
    }
    
    // MARK: - Plain Lyrics View
    
    private func plainLyricsView(_ text: String) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text(text)
                    .font(DesignSystem.display(size: 19, weight: .medium))
                    .foregroundColor(themeText.opacity(0.85))
                    .lineSpacing(10)
                    .padding(32)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(
                PaperCutShape()
                    .fill(themeText.opacity(0.04))
                    .padding(16)
                    .paperCutShadow()
            )
            .padding(.vertical, 20)
        }
    }
    
    // MARK: - No Lyrics
    
    private var noLyricsView: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "text.page.slash")
                .font(.system(size: 54))
                .foregroundColor(themeText.opacity(0.2))
            
            VStack(spacing: 8) {
                Text("No lyrics available")
                    .font(DesignSystem.display(size: 22, weight: .bold))
                    .foregroundColor(themeText)
                
                Text("This track doesn't have lyrics in the database")
                    .font(DesignSystem.display(size: 15, weight: .light, italic: true))
                    .foregroundColor(themeText.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            Spacer()
        }
    }
    
    // MARK: - Bottom Bar
    
    private var bottomBar: some View {
        VStack(spacing: 0) {
            DottedDivider()
            
            Button(action: setAsWidget) {
                HStack(spacing: 12) {
                    Image(systemName: isSetAsWidget ? "checkmark.seal.fill" : "hand.tap.fill")
                        .font(.system(size: 20))
                    
                    Text(isSetAsWidget ? "ACTIVE ON WIDGET" : "SET TO WIDGET")
                        .font(DesignSystem.display(size: 16, weight: .black))
                        .tracking(1.5)
                }
                .foregroundColor(Color.lpInk)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(
                    PaperCutShape()
                        .fill(isSetAsWidget ? Color.lpMint : themeHighlight)
                        .overlay(PaperCutShape().stroke(themeText, lineWidth: 2))
                )
                .paperCutShadow()
                .scaleEffect(isSetAsWidget ? 0.98 : 1.0)
            }
            .disabled(song.syncedLyrics == nil && song.plainLyrics == nil)
            .padding(.horizontal, 24)
            .padding(.top, 20)
            .padding(.bottom, 24)
        }
        .background(PaperBackground(color: themeBg, hasGrain: false).opacity(0.98))
    }
    
    // MARK: - Actions
    
    private func setAsWidget() {
        store.selectSong(song, initialIndex: highlightedIndex)
        isSetAsWidget = true
        withAnimation(.spring()) { showConfirmation = true }
        
        // Impact feedback (Haptic)
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation { showConfirmation = false }
        }
    }
    
    // MARK: - Toast
    
    private var confirmationToast: some View {
        VStack {
            Spacer()
            HStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.lpMint)
                Text("Lyrics sent to widget!")
                    .font(DesignSystem.display(size: 16, weight: .bold))
                    .foregroundColor(themeText)
            }
            .padding(.horizontal, 28)
            .padding(.vertical, 18)
            .background(
                PaperCutShape()
                    .fill(themeBg)
                    .overlay(PaperCutShape().stroke(themeText, lineWidth: 1.5))
                    .paperCutShadow()
            )
            .padding(.bottom, 130)
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}

#Preview {
    LyricsDisplayView(song: LRCSearchResult(
        id: 12345,
        trackName: "Lie to Me",
        artistName: "Tate McRae",
        albumName: "Too Young to Be Sad",
        duration: 180.0,
        plainLyrics: "You told me that we were forever\nBut forever was a lie...\nAnd now I'm here alone",
        syncedLyrics: "[00:10.00] You told me that we were forever\n[00:15.00] But forever was a lie...\n[00:20.00] And now I'm here alone"
    ))
    .environmentObject(LyricsStore.shared)
}
