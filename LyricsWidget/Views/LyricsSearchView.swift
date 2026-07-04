import SwiftUI

// MARK: - Search View

/// Main view: search for songs and pick lyrics to display on the widget
@MainActor
struct LyricsSearchView: View {
    @EnvironmentObject var store: LyricsStore
    
    @State private var searchText = ""
    @State private var results: [LRCSearchResult] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var searchTask: Task<Void, Never>?
    @State private var selectedSong: LRCSearchResult?
    @State private var showingLyrics = false
    
    private var themeBg: Color { Color(hex: store.backgroundColorHex) }
    private var themeText: Color { Color(hex: store.textColorHex) }
    private var themeHighlight: Color { Color(hex: store.highlightColorHex) }
    private var cardBgColor: Color {
        Color.white.opacity(store.backgroundColorHex == "#3A2C5C" ? 0.12 : 0.7)
    }

    
    var body: some View {
        NavigationStack {
            ZStack {
                PaperBackground(color: themeBg)
                
                VStack(spacing: 0) {
                    // Header Area
                    headerSection
                    
                    DottedDivider()
                        .opacity(0.4)
                        .padding(.horizontal, 16)
                    
                    // Search bar
                    searchBar
                        .padding(.top, 16)
                    
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
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 0) {
                        Text("LYRICO & VERSE")
                            .font(DesignSystem.display(size: 18, weight: .black))
                            .tracking(2)
                        Text("manual lyrics widget · est. 2025")
                            .font(.system(size: 8))
                            .tracking(2)
                            .opacity(0.8)
                    }
                    .foregroundColor(themeText)
                }
            }
            .navigationDestination(isPresented: $showingLyrics) {
                if let song = selectedSong {
                    LyricsDisplayView(song: song)
                        .environmentObject(store)
                }
            }
        }
        .onDisappear {
            searchTask?.cancel()
            isLoading = false
        }
    }
    
    // MARK: - Header
    
    private var headerSection: some View {
        HStack {
            Text("— find your voice, dear reader —")
                .font(DesignSystem.display(size: 11, weight: .light, italic: true))
                .opacity(0.9)
            Spacer()
            Text("VOL. I")
                .font(.system(size: 9))
                .tracking(2)
                .opacity(0.6)
        }
        .padding(.horizontal, 24)
        .padding(.top, 12)
        .padding(.bottom, 8)
        .overlay(
            Rectangle()
                .fill(themeText.opacity(0.1))
                .frame(height: 1),
            alignment: .bottom
        )
    }
    
    // MARK: - Search Bar
    
    private var searchBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "pencil.line")
                .foregroundColor(themeText.opacity(0.8))
                .font(.system(size: 18))
            
            TextField("Search song or artist...", text: $searchText)
                .foregroundColor(themeText)
                .font(DesignSystem.body(size: 14, weight: .black))
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
                    Image(systemName: "xmark")
                        .font(.system(size: 10, weight: .black))
                        .foregroundColor(themeText)
                        .frame(width: 20, height: 20)
                        .background(themeText.opacity(0.15))
                        .clipShape(Circle())
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(
            PaperCutShape()
                .fill(themeText.opacity(0.1))
                .overlay(
                    PaperCutShape()
                        .stroke(themeText.opacity(0.2), lineWidth: 1)
                )
        )
        .paperCutShadow()
        .padding(.horizontal, 16)
        .padding(.bottom, 24)
    }
    
    // MARK: - Results List
    
    private var resultsList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(results) { result in
                    resultRow(result)
                        .transition(.asymmetric(
                            insertion: .move(edge: .bottom).combined(with: .opacity).combined(with: .scale(scale: 0.9)),
                            removal: .opacity
                        ))
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 24)
            .padding(.bottom, 80)
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: results)
    }
    
    private func resultRow(_ result: LRCSearchResult) -> some View {
        Button(action: {
            selectedSong = result
            showingLyrics = true
        }) {
            ZStack(alignment: .leading) {
                // Main Content
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(result.trackName)
                            .font(DesignSystem.display(size: 16, weight: .black))
                            .foregroundColor(themeText)
                            .lineLimit(1)
                        
                        Text(result.artistName)
                            .font(DesignSystem.body(size: 12, weight: .bold))
                            .foregroundColor(themeText.opacity(0.80))
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        if result.syncedLyrics != nil {
                            Text("SYNCED")
                                .font(.system(size: 9, weight: .black))
                                .tracking(-0.5)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(Color.lpMint)
                                .foregroundColor(Color.lpInk)
                                .cornerRadius(4)
                                .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.lpInk, lineWidth: 1))
                        }
                        
                        Text(formatDuration(result.duration))
                            .font(.system(size: 10, weight: .black, design: .monospaced))
                            .tracking(-0.5)
                            .foregroundColor(themeText.opacity(result.syncedLyrics != nil ? 0.6 : 0.4))
                    }
                }
                .padding(.leading, 64)
                .padding(.trailing, 16)
                .padding(.vertical, 16)
                
                // Mock "Book Spine"
                GeometryReader { geo in
                    ZStack(alignment: .top) {
                        Rectangle()
                            .fill(result.syncedLyrics != nil ? Color.lpMint : Color.lpPumpkin)
                            .frame(width: 48, height: geo.size.height)
                        
                        // Ribbon
                        Rectangle()
                            .fill(Color.lpCrimson)
                            .frame(width: 10, height: 24)
                            .shadow(color: Color.lpInk.opacity(0.15), radius: 2, x: 0, y: 1)
                            .padding(.top, 8)
                    }
                }
                .frame(width: 48)
                .allowsHitTesting(false)
            }
            .background(
                PaperCutShape()
                    .fill(cardBgColor)
                    .overlay(
                        PaperCutShape()
                            .stroke(themeText.opacity(0.2), lineWidth: 1)
                    )
            )
            .clipShape(PaperCutShape())
            .paperCutShadow()
        }
        .buttonStyle(.plain)
    }
    
    private func formatDuration(_ duration: Double) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    // MARK: - State Views
    
    private var welcomeView: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Melodic Fox Card (Hero) - Collage Look with Mint Offset Backing Card
                ZStack {
                    // Mint backing sheet
                    PaperCutShape()
                        .fill(Color.lpMint.opacity(0.4))
                        .frame(width: 220, height: 280)
                        .offset(x: 4, y: 8)
                        .paperCutShadow()
                    
                    // Foreground image sheet
                    AsyncImage(url: URL(string: "https://kombai-assets.b-cdn.net/generated_assets/546bcd6a-ae6d-45c1-85a6-b370c2cc2f99/7faea13a823a42299a4a3a537ac4b85b.jpg")) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 220, height: 280)
                            .clipShape(PaperCutShape())
                            .overlay(PaperCutShape().stroke(themeText, lineWidth: 2))
                    } placeholder: {
                        ZStack {
                            Rectangle().fill(themeText.opacity(0.1)).frame(width: 220, height: 280)
                            ProgressView().tint(themeText)
                        }
                    }
                    .paperCutShadow()
                }
                .frame(width: 220, height: 280)
                .padding(.top, 24)
                
                // Typography & Text Style
                VStack(spacing: 16) {
                    Text("Stories that\nunfold in the dark.")
                        .font(DesignSystem.display(size: 30, weight: .black))
                        .lineSpacing(-6)
                        .foregroundColor(themeText)
                        .multilineTextAlignment(.center)
                    
                    VStack(spacing: 8) {
                        Text("A glanceable viewport for your Home Screen.")
                            .font(DesignSystem.display(size: 16, weight: .medium, italic: true))
                            .foregroundColor(themeText.opacity(0.8))
                            .multilineTextAlignment(.center)
                        
                        Text("Step through lyrics line-by-line with interactive controls.")
                            .font(DesignSystem.body(size: 12))
                            .foregroundColor(themeText.opacity(0.6))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                }
                .padding(.horizontal, 32)
                
                // "Currently on Widget" Washi Tape Banner
                if let song = store.currentSong {
                    ZStack {
                        WashiTape(color: Color.lpPumpkin, rotation: .degrees(-1.5))
                            .frame(height: 38)
                        
                        VStack(spacing: 2) {
                            Text("CURRENTLY ON WIDGET")
                                .font(.system(size: 8, weight: .black))
                                .tracking(1.5)
                                .foregroundColor(themeText.opacity(0.4))
                            
                            Text("\(song.trackName) — \(song.artistName)")
                                .font(DesignSystem.display(size: 14, weight: .bold))
                                .foregroundColor(Color.lpCrimson)
                        }
                        .padding(.vertical, 8)
                    }
                    .padding(.horizontal, 32)
                    .padding(.top, 8)
                }
                
                // "Recently Unfolded" History List
                if !store.recentlyPlayed.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        DottedDivider()
                            .opacity(0.2)
                            .padding(.horizontal, 16)
                        
                        Text("RECENTLY UNFOLDED")
                            .font(.system(size: 10, weight: .black))
                            .tracking(2)
                            .foregroundColor(themeText.opacity(0.4))
                            .padding(.horizontal, 24)
                        
                        VStack(spacing: 16) {
                            ForEach(store.recentlyPlayed.prefix(2)) { song in
                                resultRow(song)
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.top, 16)
                }
                
                Spacer()
            }
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            Spacer()
            ProgressView()
                .scaleEffect(1.5)
                .tint(themeHighlight)
            Text("Unfolding the library...")
                .font(DesignSystem.display(size: 18, italic: true))
                .foregroundColor(themeText.opacity(0.6))
            Spacer()
        }
    }
    
    private func errorView(_ message: String) -> some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "exclamationmark.bubble.fill")
                .font(.system(size: 48))
                .foregroundColor(themeHighlight)
                .paperCutShadow()
            
            Text(message)
                .font(DesignSystem.display(size: 20))
                .foregroundColor(themeText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            
            Button(action: performSearch) {
                Text("Try Again")
                    .font(DesignSystem.display(size: 18, weight: .bold))
                    .padding(.horizontal, 32)
                    .padding(.vertical, 14)
                    .background(
                        PaperCutShape()
                            .fill(themeHighlight)
                            .overlay(PaperCutShape().stroke(themeText, lineWidth: 2))
                    )
                    .foregroundColor(Color.lpInk)
                    .paperCutShadow()
            }
            Spacer()
        }
        .padding(.horizontal, 40)
    }
    
    private var emptyView: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "text.page.slash")
                .font(.system(size: 54))
                .foregroundColor(themeText.opacity(0.2))
            
            VStack(spacing: 8) {
                Text("No stories found.")
                    .font(DesignSystem.display(size: 24, weight: .bold))
                    .foregroundColor(themeText)
                
                Text("Perhaps the rabbit borrowed them.")
                    .font(DesignSystem.display(size: 16, weight: .light, italic: true))
                    .foregroundColor(themeText.opacity(0.6))
            }
            Spacer()
        }
    }
    
    // MARK: - Search Logic
    
    @MainActor
    private func debounceSearch(query: String) {
        searchTask?.cancel()
        
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            results = []
            errorMessage = nil
            isLoading = false
            return
        }
        
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 500_000_000)
            guard !Task.isCancelled else { return }
            performSearch()
        }
    }
    
    @MainActor
    private func performSearch() {
        let query = searchText.trimmingCharacters(in: .whitespaces)
        guard !query.isEmpty else { return }
        
        isLoading = true
        errorMessage = nil
        searchTask?.cancel()
        
        searchTask = Task {
            do {
                let searchResults = try await LyricsAPI.shared.search(query: query)
                guard !Task.isCancelled else { return }
                self.results = searchResults
                self.isLoading = false
            } catch {
                guard !Task.isCancelled else { return }
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
}

// MARK: - Helper for Rounded Corners
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

#Preview {
    LyricsSearchView()
        .environmentObject(LyricsStore.shared)
}
