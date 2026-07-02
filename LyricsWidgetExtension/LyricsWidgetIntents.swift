import AppIntents
import Foundation

// MARK: - Next Line Intent

struct AdvanceLineIntent: AppIntent {
    static var title: LocalizedStringResource = "Advance Lyric Line"
    static var description = IntentDescription("Moves the widget lyrics display to the next line.")
    
    init() {}
    
    func perform() async throws -> some IntentResult {
        await LyricsStore.shared.advanceLine(reload: false)
        return .result()
    }
}

// MARK: - Previous Line Intent

struct PreviousLineIntent: AppIntent {
    static var title: LocalizedStringResource = "Previous Lyric Line"
    static var description = IntentDescription("Moves the widget lyrics display to the previous line.")
    
    init() {}
    
    func perform() async throws -> some IntentResult {
        await LyricsStore.shared.previousLine(reload: false)
        return .result()
    }
}

// MARK: - Reset Position Intent

struct ResetLineIntent: AppIntent {
    static var title: LocalizedStringResource = "Reset Lyric Line"
    static var description = IntentDescription("Resets the widget lyrics display to the beginning.")
    
    init() {}
    
    func perform() async throws -> some IntentResult {
        await LyricsStore.shared.resetPosition(reload: false)
        return .result()
    }
}
