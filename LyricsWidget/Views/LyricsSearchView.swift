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
        Color.white.opacity(store.backgroundColorHex == "#3A2C5C" ? 0.12 : 0.6)
    }

    
    var body: some View {
        NavigationStack {
            ZStack {
                PaperBackground(color: themeBg)
                
                VStack(spacing: 0) {
                    // Header Area
                    headerSection
                    
                    DottedDivider()
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
                            .opacity(0.6)
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
                .font(DesignSystem.display(size: 14, weight: .light, italic: true))
                .opacity(0.9)
            Spacer()
            Text("VOL. I")
                .font(.system(size: 10))
                .tracking(2)
                .opacity(0.6)
        }
        .padding(.horizontal, 24)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }
    
    // MARK: - Search Bar
    
    private var searchBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "pencil.line")
                .foregroundColor(themeText.opacity(0.7))
                .font(.system(size: 18))
            
            TextField("Search song or artist...", text: $searchText)
                .foregroundColor(themeText)
                .font(DesignSystem.body(size: 16))
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
                        .foregroundColor(themeText.opacity(0.7))
                        .font(.system(size: 14, weight: .bold))
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
                        .stroke(themeText.opacity(0.3), lineWidth: 1)
                )
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
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
            .padding(.vertical, 8)
            .padding(.bottom, 32)
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: results)
    }
    
    private func resultRow(_ result: LRCSearchResult) -> some View {
        Button(action: {
            selectedSong = result
            showingLyrics = true
        }) {
            HStack(spacing: 16) {
                // Mock "Book Spine"
                ZStack(alignment: .top) {
                    Rectangle()
                        .fill(result.syncedLyrics != nil ? Color.lpMint : Color.lpPumpkin)
                        .frame(width: 48, height: 64)
                        .cornerRadius(4, corners: [.topLeft, .bottomLeft])
                        .shadow(color: .black.opacity(0.1), radius: 2, x: 2, y: 0)
                    
                    // Ribbon
                    Rectangle()
                        .fill(Color.lpCrimson)
                        .frame(width: 8, height: 20)
                        .padding(.top, -4)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(result.trackName)
                        .font(DesignSystem.display(size: 18, weight: .bold))
                        .foregroundColor(themeText)
                        .lineLimit(1)
                    
                    Text(result.artistName)
                        .font(DesignSystem.body(size: 14, weight: .medium))
                        .foregroundColor(themeText.opacity(0.85))
                        .lineLimit(1)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    if result.syncedLyrics != nil {
                        Text("SYNCED")
                            .font(.system(size: 8, weight: .black))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Color.lpMint)
                            .foregroundColor(Color.lpInk)
                            .cornerRadius(4)
                            .overlay(RoundedRectangle(cornerRadius: 4).stroke(themeText.opacity(0.8), lineWidth: 1))
                    }
                    
                    Text(formatDuration(result.duration))
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(themeText.opacity(0.7))
                }
            }
            .padding(.trailing, 16)
            .background(
                PaperCutShape()
                    .fill(cardBgColor)
                    .overlay(
                        PaperCutShape()
                            .stroke(themeText.opacity(0.15), lineWidth: 1)
                    )
            )
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
            VStack(spacing: 28) {
                // Melodic Fox Card (Hero)
                ZStack {
                    PaperCutShape()
                        .fill(themeHighlight.opacity(0.2))
                        .paperCutShadow()
                    
                    VStack(spacing: 20) {
                        AsyncImage(url: URL(string: "https://kombai-assets.b-cdn.net/generated_assets/546bcd6a-ae6d-45c1-85a6-b370c2cc2f99/7faea13a823a42299a4a3a537ac4b85b.jpg")) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 220, height: 280)
                                .clipShape(PaperCutShape())
                                .overlay(PaperCutShape().stroke(themeText, lineWidth: 2))
                                .paperCutShadow()
                        } placeholder: {
                            ZStack {
                                Rectangle().fill(themeText.opacity(0.1)).frame(width: 220, height: 280)
                                ProgressView().tint(themeText)
                            }
                        }
                        
                        Text("Stories that unfold in the dark.")
                            .font(DesignSystem.display(size: 32, weight: .black))
                            .foregroundColor(themeText)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                    }
                    .padding(32)
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                
                VStack(spacing: 12) {
                    Text("A glanceable viewport for your Home Screen.")
                        .font(DesignSystem.display(size: 16, weight: .medium, italic: true))
                        .foregroundColor(themeText.opacity(0.8))
                        .multilineTextAlignment(.center)
                    
                    Text("Step through lyrics line-by-line with interactive controls.")
                        .font(DesignSystem.body(size: 14))
                        .foregroundColor(themeText.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                .padding(.horizontal, 32)
                
                if let song = store.currentSong {
                    VStack(spacing: 6) {
                        Text("CURRENTLY ON WIDGET")
                            .font(.system(size: 10, weight: .black))
                            .tracking(2)
                            .foregroundColor(themeText.opacity(0.4))
                        
                        Text("\(song.trackName) — \(song.artistName)")
                            .font(DesignSystem.display(size: 16, weight: .bold))
                            .foregroundColor(Color.lpCrimson)
                    }
                    .padding(.vertical, 20)
                    .padding(.horizontal, 32)
                    .background(
                        WashiTape(color: Color.lpPumpkin, rotation: .degrees(-1.5))
                    )
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
