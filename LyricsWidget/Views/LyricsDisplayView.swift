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
                    Color.lyricBg,
                    Color.lyricCardBg
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
                            colors: [Color.lyricHighlight, Color.lyricHighlightDark],
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
                    tagView(text: "Synced", color: Color.lyricGreen)
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
                                            ? Color.lyricHighlight
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
                                            ? Color.lyricHighlight.opacity(0.1)
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
                                ? AnyShapeStyle(Color.lyricGreen)
                                : AnyShapeStyle(LinearGradient(
                                    colors: [Color.lyricHighlight, Color.lyricHighlightDark],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ))
                        )
                )
            }
            .disabled(song.syncedLyrics == nil && song.plainLyrics == nil)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(Color.lyricBg.opacity(0.95))
    }
    
    // MARK: - Actions
    
    private func setAsWidget() {
        store.selectSong(song, initialIndex: highlightedIndex)
        
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
                    .foregroundColor(Color.lyricGreen)
                Text("Lyrics saved to widget!")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background(
                Capsule()
                    .fill(Color.lyricCardBg)
                    .overlay(
                        Capsule()
                            .stroke(Color.lyricGreen.opacity(0.3), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.3), radius: 10)
            )
            .padding(.bottom, 100)
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .animation(.spring(response: 0.3), value: showConfirmation)
    }
}
