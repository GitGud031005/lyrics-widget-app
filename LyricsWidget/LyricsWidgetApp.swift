import SwiftUI

@main
struct LyricsWidgetApp: App {
    @StateObject private var store = LyricsStore.shared
    
    var body: some Scene {
        WindowGroup {
            TabView {
                LyricsSearchView()
                    .environmentObject(store)
                    .tabItem {
                        Label("Search", systemImage: "magnifyingglass")
                    }
                
                SettingsView()
                    .environmentObject(store)
                    .tabItem {
                        Label("Settings", systemImage: "gearshape")
                    }
            }
            .preferredColorScheme(.dark)
        }
    }
}
