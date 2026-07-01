import SwiftUI

@main
struct LyricsWidgetApp: App {
    @StateObject private var store = LyricsStore.shared
    
    var body: some Scene {
        WindowGroup {
            LyricsSearchView()
                .environmentObject(store)
        }
    }
}
