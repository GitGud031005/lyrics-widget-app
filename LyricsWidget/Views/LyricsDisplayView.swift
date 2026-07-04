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
    @State private var hasAppeared = false
    
    private var themeBg: Color { Color(hex: store.backgroundColorHex) }
    private var themeText: Color { Color(hex: store.textColorHex) }
    private var themeHighlight: Color { Color(hex: store.highlightColorHex) }
    
    var body: some View {
        ZStack {
            MidnightDisplayBackground(baseColor: themeBg)
            
            VStack(spacing: 0) {
                // Song header
                midnightHeader
                    .opacity(hasAppeared ? 1 : 0)
                    .offset(y: hasAppeared ? 0 : -30)
                
                ScallopDivider(color: themeText.opacity(0.15))
                    .padding(.horizontal, 24)
                    .opacity(hasAppeared ? 1 : 0)
                
                // Lyrics content
                ZStack {
                    if !lines.isEmpty {
                        syncedLyricsView
                    } else if let plain = song.plainLyrics, !plain.isEmpty {
                        plainLyricsView(plain)
                    } else {
                        noLyricsView
                    }
                    
                    // Decorative background icons
                    decorativeIcons
                }
                
                Spacer(minLength: 0)
            }
            
            // Bottom footer overlay
            VStack {
                Spacer()
                footerView
                    .opacity(hasAppeared ? 1 : 0)
                    .offset(y: hasAppeared ? 0 : 100)
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
            
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                hasAppeared = true
            }
        }
        .overlay {
            if showConfirmation {
                confirmationToast
            }
        }
    }
    
    // MARK: - Midnight Header
    
    private var midnightHeader: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                // Now Streaming pill
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.lpMint)
                        .frame(width: 6, height: 6)
                        .overlay(
                            Circle()
                                .stroke(Color.lpMint, lineWidth: 1)
                                .scaleEffect(1.5)
                                .opacity(0.5)
                        )
                        .modifier(PulseModifier())
                    
                    Text("Now Streaming")
                        .font(.system(size: 10, weight: .black))
                        .tracking(2.5)
                        .foregroundColor(Color.lpMint.opacity(0.7))
                }
                
                // Track name
                Text(song.trackName)
                    .font(DesignSystem.display(size: 32, weight: .black))
                    .foregroundColor(themeText)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                // Artist
                Text(song.artistName)
                    .font(DesignSystem.display(size: 16, weight: .medium, italic: true))
                    .foregroundColor(themeText.opacity(0.6))
                    .lineLimit(1)
            }
            
            Spacer()
            
            // Album art badge
            ZStack {
                Circle()
                    .stroke(Color.lpMint.opacity(0.4), lineWidth: 2)
                    .frame(width: 64, height: 64)
                    .rotationEffect(.degrees(12))
                
                Circle()
                    .fill(Color.lpInkDark)
                    .frame(width: 56, height: 56)
                    .overlay(
                        Circle()
                            .stroke(Color.lpPumpkin, lineWidth: 2)
                    )
                    .shadow(color: Color.black.opacity(0.4), radius: 8, x: 0, y: 4)
                
                // Placeholder album art using artist initial
                ZStack {
                    AsyncImage(url: albumArtURL) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 52, height: 52)
                            .clipShape(Circle())
                            .opacity(0.6)
                            .blendMode(.luminosity)
                    } placeholder: {
                        EmptyView()
                    }
                    
                    Text(albumArtInitial)
                        .font(DesignSystem.display(size: 24, weight: .black))
                        .foregroundColor(themeHighlight)
                }
                .frame(width: 52, height: 52)
                
                // MASTER tab
                Text("MASTER")
                    .font(.system(size: 8, weight: .black))
                    .tracking(0.5)
                    .foregroundColor(Color.lpInk)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Color.lpMint)
                    .overlay(Rectangle().stroke(Color.lpInk, lineWidth: 1.5))
                    .shadow(color: Color.lpInk, radius: 0, x: 2, y: 2)
                    .rotationEffect(.degrees(-8))
                    .offset(x: 14, y: 28)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 12)
        .padding(.bottom, 16)
    }
    
    private var albumArtURL: URL? {
        // Use a deterministic placeholder based on artist name
        let seed = song.artistName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "lyrico"
        return URL(string: "https://i.pravatar.cc/100?u=\(seed)")
    }
    
    private var albumArtInitial: String {
        song.artistName.first?.uppercased() ?? "♪"
    }
    
    // MARK: - Synced Lyrics View
    
    private var syncedLyricsView: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 18) {
                    ForEach(Array(lines.enumerated()), id: \.element.id) { index, line in
                        lyricRow(for: line, at: index)
                            .id(index)
                            .opacity(rowOpacity(for: index))
                            .offset(x: rowOffset(for: index))
                            .scaleEffect(rowScale(for: index), anchor: .leading)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 220)
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
    
    private func lyricRow(for line: LyricLine, at index: Int) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                highlightedIndex = index
            }
        }) {
            Group {
                if index == highlightedIndex {
                    activeLyricCard(for: line)
                } else {
                    inactiveLyricText(for: line, at: index)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
    
    private func inactiveLyricText(for line: LyricLine, at index: Int) -> some View {
        let distance = abs(index - highlightedIndex)
        let isEvenDistance = distance % 2 == 0
        
        return Text(line.text)
            .font(DesignSystem.display(
                size: isEvenDistance ? 22 : 20,
                weight: .medium,
                italic: !isEvenDistance
            ))
            .foregroundColor(isEvenDistance ? Color.lpMint.opacity(0.7) : themeText.opacity(0.8))
            .opacity(isEvenDistance ? 0.65 : 0.5)
            .frame(maxWidth: .infinity, alignment: .leading)
            .multilineTextAlignment(.leading)
    }
    
    private func activeLyricCard(for line: LyricLine) -> some View {
        ZStack(alignment: .topTrailing) {
            // Glow behind card
            CutCardShape()
                .fill(themeHighlight.opacity(0.15))
                .scaleEffect(1.08)
                .blur(radius: 20)
            
            HStack(spacing: 12) {
                // Left indicator bar
                RoundedRectangle(cornerRadius: 4)
                    .fill(themeHighlight)
                    .frame(width: 6, height: 64)
                    .shadow(color: themeHighlight.opacity(0.5), radius: 8, x: 0, y: 0)
                
                // Card content
                ZStack(alignment: .topTrailing) {
                    CutCardShape()
                        .fill(Color.lpInkDark)
                        .overlay(
                            CutCardShape()
                                .stroke(themeHighlight, lineWidth: 2)
                        )
                        .shadow(color: Color.lpInkDark, radius: 0, x: 8, y: 8)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text(line.text)
                            .font(DesignSystem.display(size: 26, weight: .black))
                            .foregroundColor(themeText)
                            .multilineTextAlignment(.leading)
                            .lineSpacing(4)
                        
                        HStack(spacing: 12) {
                            Rectangle()
                                .fill(Color.lpMint.opacity(0.2))
                                .frame(height: 1)
                            
                            Text(line.formattedTime)
                                .font(DesignSystem.display(size: 12, weight: .bold, italic: true))
                                .foregroundColor(Color.lpMint)
                        }
                    }
                    .padding(20)
                    
                    // Mint washi tape
                    MintWashiTape()
                        .frame(width: 64, height: 20)
                        .rotationEffect(.degrees(2))
                        .offset(x: -16, y: -10)
                }
            }
            .padding(.leading, 4)
        }
    }
    
    private func rowOpacity(for index: Int) -> Double {
        hasAppeared ? 1 : 0
    }
    
    private func rowOffset(for index: Int) -> CGFloat {
        guard !hasAppeared else { return 0 }
        let distance = CGFloat(index - highlightedIndex)
        return -30 * (distance + 1)
    }
    
    private func rowScale(for index: Int) -> CGFloat {
        index == highlightedIndex ? 1.0 : 0.95
    }
    
    // MARK: - Plain Lyrics View
    
    private func plainLyricsView(_ text: String) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                Text(text)
                    .font(DesignSystem.display(size: 20, weight: .medium))
                    .foregroundColor(themeText.opacity(0.85))
                    .lineSpacing(12)
                    .padding(28)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(
                CutCardShape()
                    .fill(Color.lpInkDark)
                    .overlay(CutCardShape().stroke(themeText.opacity(0.2), lineWidth: 2))
                    .shadow(color: Color.lpInkDark, radius: 0, x: 8, y: 8)
            )
            .padding(.vertical, 20)
            .padding(.bottom, 200)
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
    
    // MARK: - Decorative Icons
    
    private var decorativeIcons: some View {
        GeometryReader { geo in
            ZStack {
                Image(systemName: "star.fill")
                    .font(.system(size: 48))
                    .foregroundColor(themeHighlight)
                    .opacity(0.08)
                    .position(x: geo.size.width - 30, y: geo.size.height * 0.25)
                
                Image(systemName: "moon.stars.fill")
                    .font(.system(size: 72))
                    .foregroundColor(Color.lpMint)
                    .opacity(0.08)
                    .rotationEffect(.degrees(12))
                    .position(x: -20, y: geo.size.height * 0.65)
            }
        }
        .allowsHitTesting(false)
    }
    
    // MARK: - Footer
    
    private var footerView: some View {
        VStack(spacing: 0) {
            ScallopDivider(color: themeText.opacity(0.15), invert: true)
            
            VStack(spacing: 16) {
                // Progress rail
                progressSection
                
                // Controls row
                HStack(spacing: 12) {
                    Button(action: previousLine) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 22, weight: .black))
                    }
                    .buttonStyle(OffsetShadowButtonStyle(
                        background: .lpInkDark,
                        foreground: .lpCream,
                        border: .lpMint,
                        shadow: Color.lpMint.opacity(0.4),
                        radii: (12, 14, 10, 16),
                        shadowOffset: CGSize(width: 3, height: 3)
                    ))
                    .frame(width: 56, height: 56)
                    
                    Button(action: resetPosition) {
                        Text("Reset Song")
                            .font(DesignSystem.display(size: 13, weight: .black))
                            .tracking(2)
                    }
                    .buttonStyle(OffsetShadowButtonStyle(
                        background: themeHighlight,
                        foreground: .lpInk,
                        border: .lpInkDark,
                        shadow: .lpInkDark,
                        radii: (20, 28, 22, 26),
                        shadowOffset: CGSize(width: 4, height: 4)
                    ))
                    .frame(height: 56)
                    
                    Button(action: advanceLine) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 22, weight: .black))
                    }
                    .buttonStyle(OffsetShadowButtonStyle(
                        background: .lpInkDark,
                        foreground: .lpCream,
                        border: .lpMint,
                        shadow: Color.lpMint.opacity(0.4),
                        radii: (12, 14, 10, 16),
                        shadowOffset: CGSize(width: 3, height: 3)
                    ))
                    .frame(width: 56, height: 56)
                }
                
                // Widget button
                Button(action: setAsWidget) {
                    HStack(spacing: 10) {
                        Image(systemName: isSetAsWidget ? "checkmark.seal.fill" : "sparkles")
                            .font(.system(size: 20))
                        
                        Text(isSetAsWidget ? "Updated on Home Widget" : "Update Home Widget")
                            .font(DesignSystem.display(size: 18, weight: .black))
                            .tracking(1)
                    }
                }
                .buttonStyle(OffsetShadowButtonStyle(
                    background: .lpMint,
                    foreground: .lpInkDark,
                    border: .lpInkDark,
                    shadow: .lpInkDark,
                    radii: (24, 22, 28, 20),
                    shadowOffset: CGSize(width: 4, height: 4)
                ))
                .frame(height: 56)
                .disabled(song.syncedLyrics == nil && song.plainLyrics == nil)
                
                // Footer caption
                Text("— LYRICO · MIDNIGHT INK · EDITION 03 —")
                    .font(.system(size: 9, weight: .black))
                    .tracking(3)
                    .foregroundColor(themeText.opacity(0.35))
                    .padding(.top, 4)
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .padding(.bottom, 24)
            .background(
                themeBg
                    .opacity(0.95)
                    .background(.ultraThinMaterial)
            )
        }
    }
    
    private var progressSection: some View {
        VStack(spacing: 6) {
            HStack {
                Text("Current Spread")
                    .font(.system(size: 10, weight: .black))
                    .tracking(2)
                    .foregroundColor(Color.lpMint)
                
                Spacer()
                
                Text("p. \(String(format: "%02d", highlightedIndex + 1)) / \(String(format: "%02d", max(lines.count, 1)))")
                    .font(DesignSystem.display(size: 14, weight: .bold, italic: true))
                    .foregroundColor(themeText.opacity(0.6))
            }
            
            progressRail
        }
    }
    
    private var progressRail: some View {
        GeometryReader { geo in
            let progress = lines.isEmpty ? 0 : CGFloat(highlightedIndex) / CGFloat(max(lines.count - 1, 1))
            
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.lpInkDark)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.lpMint, lineWidth: 2)
                    )
                
                RoundedRectangle(cornerRadius: 2)
                    .fill(themeHighlight)
                    .frame(width: max(4, geo.size.width * progress))
                    .padding(2)
                    .shadow(color: themeHighlight.opacity(0.4), radius: 8, x: 0, y: 0)
            }
        }
        .frame(height: 12)
    }
    
    // MARK: - Actions
    
    private func advanceLine() {
        guard highlightedIndex < lines.count - 1 else { return }
        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
            highlightedIndex += 1
        }
        if isSetAsWidget {
            store.currentLineIndex = highlightedIndex
        }
    }
    
    private func previousLine() {
        guard highlightedIndex > 0 else { return }
        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
            highlightedIndex -= 1
        }
        if isSetAsWidget {
            store.currentLineIndex = highlightedIndex
        }
    }
    
    private func resetPosition() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
            highlightedIndex = 0
        }
        if isSetAsWidget {
            store.currentLineIndex = 0
        }
    }
    
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
                CutCardShape()
                    .fill(Color.lpInkDark)
                    .overlay(CutCardShape().stroke(themeText, lineWidth: 1.5))
                    .shadow(color: Color.lpInkDark, radius: 0, x: 8, y: 8)
            )
            .padding(.bottom, 180)
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}

// MARK: - Pulse Modifier

struct PulseModifier: ViewModifier {
    @State private var isPulsing = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPulsing ? 1.4 : 1.0)
            .opacity(isPulsing ? 0.5 : 1.0)
            .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: isPulsing)
            .onAppear { isPulsing = true }
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
