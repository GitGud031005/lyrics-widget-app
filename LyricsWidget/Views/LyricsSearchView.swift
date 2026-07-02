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
        .onDisappear {
            searchTask?.cancel()
            isLoading = false
        }
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
