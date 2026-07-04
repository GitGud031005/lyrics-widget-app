import SwiftUI

struct MainContainerView: View {
    @EnvironmentObject var store: LyricsStore
    @State private var selectedTab: Tab = .search
    
    enum Tab {
        case search
        case settings
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // View Switcher
            Group {
                switch selectedTab {
                case .search:
                    LyricsSearchView()
                        .environmentObject(store)
                case .settings:
                    SettingsView()
                        .environmentObject(store)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Custom Tab Bar overlay
            VStack(spacing: 0) {
                // Top border matching design: border-t border-[var(--lp-ink)]/10
                Rectangle()
                    .fill(Color.lpInk.opacity(0.1))
                    .frame(height: 1)
                
                HStack(spacing: 0) {
                    // Search Tab Button
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            selectedTab = .search
                        }
                    }) {
                        VStack(spacing: 4) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 24, weight: selectedTab == .search ? .black : .regular))
                            Text("Search")
                                .font(.system(size: 10, weight: selectedTab == .search ? .black : .bold))
                        }
                        .foregroundColor(selectedTab == .search ? Color.lpCrimson : Color.lpInk.opacity(0.4))
                        .padding(.top, 12)
                        .padding(.bottom, 12)
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.plain)
                    
                    // Settings Tab Button
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            selectedTab = .settings
                        }
                    }) {
                        VStack(spacing: 4) {
                            Image(systemName: "gearshape")
                                .font(.system(size: 24, weight: selectedTab == .settings ? .black : .regular))
                            Text("Settings")
                                .font(.system(size: 10, weight: selectedTab == .settings ? .black : .bold))
                        }
                        .foregroundColor(selectedTab == .settings ? Color.lpCrimson : Color.lpInk.opacity(0.4))
                        .padding(.top, 12)
                        .padding(.bottom, 12)
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 32)
            }
            .background(
                Color.white.opacity(0.9)
                    .background(.ultraThinMaterial)
                    .ignoresSafeArea(edges: .bottom)
            )
        }
    }
}

@main
struct LyricsWidgetApp: App {
    @StateObject private var store = LyricsStore.shared
    
    var body: some Scene {
        WindowGroup {
            MainContainerView()
                .environmentObject(store)
                .preferredColorScheme(.dark)
        }
    }
}

#Preview {
    MainContainerView()
        .environmentObject(LyricsStore.shared)
}
