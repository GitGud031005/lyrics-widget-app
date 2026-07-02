import SwiftUI

@MainActor
struct SettingsView: View {
    @EnvironmentObject var store: LyricsStore
    
    @State private var localBgHex: String = ""
    @State private var localTextHex: String = ""
    @State private var localHighlightHex: String = ""
    
    // Preset themes
    private let themes = [
        Theme(name: "Midnight", bg: "#1A1A2E", text: "#8888AA", highlight: "#E94560"),
        Theme(name: "Forest", bg: "#1E2022", text: "#686D76", highlight: "#198964"),
        Theme(name: "Ocean", bg: "#0F172A", text: "#64748B", highlight: "#38BDF8"),
        Theme(name: "Nordic", bg: "#2E3440", text: "#D8DEE9", highlight: "#88C0D0"),
        Theme(name: "Sakura", bg: "#2B2129", text: "#A890A2", highlight: "#FFB7C5")
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.lyricBg.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Live Preview Box
                        widgetPreviewSection
                        
                        // Theme Presets
                        themePresetsSection
                        
                        // Fine-tuned settings
                        appearanceSettingsSection
                        
                        // About
                        aboutSection
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Widget Settings")
            .toolbarColorScheme(.dark, for: .navigationBar)
            .onAppear {
                localBgHex = store.backgroundColorHex
                localTextHex = store.textColorHex
                localHighlightHex = store.highlightColorHex
            }
        }
    }
    
    // MARK: - Widget Preview
    
    private var widgetPreviewSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("LIVE PREVIEW (MEDIUM WIDGET)")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.gray)
                .padding(.leading, 4)
            
            // Re-use Widget styling
            ZStack {
                Color(hex: store.backgroundColorHex)
                
                VStack(spacing: 4) {
                    HStack {
                        VStack(alignment: .leading, spacing: 1) {
                            Text(store.currentSong?.trackName ?? "Song Name")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text(store.currentSong?.artistName ?? "Artist Name")
                                .font(.system(size: 11))
                                .foregroundColor(Color(hex: store.textColorHex).opacity(0.8))
                        }
                        Spacer()
                        Image(systemName: "music.note.list")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: store.highlightColorHex))
                    }
                    .padding(.bottom, 4)
                    
                    // Mock lyrics
                    VStack(alignment: .leading, spacing: 4) {
                        let lines = ["Previous lyric line goes here", "This is the active highlighted line", "The next lines display below"]
                        
                        ForEach(Array(lines.enumerated()), id: \.offset) { index, text in
                            let isCurrent = (index == 1)
                            Text(text)
                                .font(.system(size: CGFloat(store.fontSize), weight: isCurrent ? .bold : .regular))
                                .foregroundColor(isCurrent ? Color(hex: store.highlightColorHex) : Color(hex: store.textColorHex))
                                .lineLimit(1)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 2)
                                .background(isCurrent ? Color(hex: store.highlightColorHex).opacity(0.1) : Color.clear)
                                .cornerRadius(4)
                        }
                    }
                }
                .padding(12)
            }
            .frame(height: 140)
            .cornerRadius(18)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
            .shadow(radius: 10)
        }
    }
    
    // MARK: - Themes
    
    private var themePresetsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("THEME PRESETS")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.gray)
                .padding(.leading, 4)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(themes) { theme in
                        Button(action: { applyTheme(theme) }) {
                            VStack(spacing: 8) {
                                // Mini palette circle
                                HStack(spacing: -8) {
                                    Circle().fill(Color(hex: theme.bg)).frame(width: 24, height: 24)
                                    Circle().fill(Color(hex: theme.text)).frame(width: 24, height: 24)
                                    Circle().fill(Color(hex: theme.highlight)).frame(width: 24, height: 24)
                                }
                                .padding(.top, 8)
                                
                                Text(theme.name)
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.white)
                                    .padding(.bottom, 8)
                            }
                            .frame(width: 80)
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(
                                        isThemeApplied(theme)
                                            ? Color(hex: theme.highlight)
                                            : Color.white.opacity(0.1),
                                        lineWidth: isThemeApplied(theme) ? 2 : 1
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
    
    // MARK: - Options Group
    
    private var appearanceSettingsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("MANUAL CUSTOMIZATION")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.gray)
                .padding(.leading, 4)
            
            VStack(spacing: 0) {
                // Background Hex input
                customColorRow(title: "Background Hex", hex: $localBgHex, onCommit: { applyHexIfValid($localBgHex, field: .background) })
                
                Divider().background(Color.white.opacity(0.08)).padding(.leading, 16)
                
                // Text Hex
                customColorRow(title: "Text Hex", hex: $localTextHex, onCommit: { applyHexIfValid($localTextHex, field: .text) })
                
                Divider().background(Color.white.opacity(0.08)).padding(.leading, 16)
                
                // Highlight Hex
                customColorRow(title: "Highlight Hex", hex: $localHighlightHex, onCommit: { applyHexIfValid($localHighlightHex, field: .highlight) })
                
                Divider().background(Color.white.opacity(0.08)).padding(.leading, 16)
                
                // Font Size Stepper
                HStack {
                    Text("Font Size")
                        .foregroundColor(.white)
                    Spacer()
                    Text("\(Int(store.fontSize)) pt")
                        .foregroundColor(.gray)
                        .padding(.trailing, 8)
                    Stepper("", value: $store.fontSize, in: 10...24)
                        .labelsHidden()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                
                Divider().background(Color.white.opacity(0.08)).padding(.leading, 16)
                
                // Visible lines selector
                HStack {
                    Text("Visible Lines")
                        .foregroundColor(.white)
                    Spacer()
                    Picker("", selection: $store.linesVisible) {
                        Text("3 Lines").tag(3)
                        Text("5 Lines").tag(5)
                        Text("7 Lines").tag(7)
                    }
                    .pickerStyle(.menu)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
            .background(Color.white.opacity(0.04))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
        }
    }
    
    private func customColorRow(title: String, hex: Binding<String>, onCommit: @escaping () -> Void) -> some View {
        HStack {
            Text(title)
                .foregroundColor(.white)
            Spacer()
            
            // Color preview bubble
            Circle()
                .fill(Color(hex: hex.wrappedValue))
                .frame(width: 20, height: 20)
                .overlay(Circle().stroke(Color.white.opacity(0.3), lineWidth: 1))
            
            TextField("#FFFFFF", text: hex)
                .onSubmit(onCommit)
                .frame(width: 80)
                .multilineTextAlignment(.trailing)
                .foregroundColor(.gray)
                .font(.system(size: 14, design: .monospaced))
                .autocorrectionDisabled()
                .textInputAutocapitalization(.characters)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    // MARK: - About
    
    private var aboutSection: some View {
        VStack(spacing: 6) {
            Text("Lyrico v1.0")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.gray)
            
            Text("Powered by LRCLIB database")
                .font(.system(size: 10))
                .foregroundColor(.gray.opacity(0.7))
            
            Text("App Group: \(AppGroupHelper.appGroupID) (\(AppGroupHelper.isAppGroupAccessible ? "OK" : "DENIED"))")
                .font(.system(size: 10))
                .foregroundColor(AppGroupHelper.isAppGroupAccessible ? .green.opacity(0.6) : .red.opacity(0.6))
                .padding(.top, 4)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
    }
    
    // MARK: - Helper Methods
    
    private func applyTheme(_ theme: Theme) {
        withAnimation {
            store.performBatchUpdate {
                store.backgroundColorHex = theme.bg
                store.textColorHex = theme.text
                store.highlightColorHex = theme.highlight
            }
            localBgHex = theme.bg
            localTextHex = theme.text
            localHighlightHex = theme.highlight
        }
    }
    
    private func isThemeApplied(_ theme: Theme) -> Bool {
        return store.backgroundColorHex.uppercased() == theme.bg.uppercased() &&
               store.textColorHex.uppercased() == theme.text.uppercased() &&
               store.highlightColorHex.uppercased() == theme.highlight.uppercased()
    }
    
    private enum ColorField {
        case background
        case text
        case highlight
    }
    
    private func applyHexIfValid(_ hexBinding: Binding<String>, field: ColorField) {
        let hex = hexBinding.wrappedValue
        var cleanHex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if !cleanHex.hasPrefix("#") {
            cleanHex = "#" + cleanHex
        }
        let hexVal = cleanHex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        let hexCharacters = CharacterSet(charactersIn: "0123456789ABCDEFabcdef")
        if (hexVal.count == 6 || hexVal.count == 8) &&
           CharacterSet(charactersIn: hexVal).isSubset(of: hexCharacters) {
            withAnimation {
                switch field {
                case .background:
                    store.backgroundColorHex = cleanHex
                case .text:
                    store.textColorHex = cleanHex
                case .highlight:
                    store.highlightColorHex = cleanHex
                }
            }
            hexBinding.wrappedValue = cleanHex
        } else {
            // Revert back to the store's current value on validation failure
            let fallback: String
            switch field {
            case .background:
                fallback = store.backgroundColorHex
            case .text:
                fallback = store.textColorHex
            case .highlight:
                fallback = store.highlightColorHex
            }
            hexBinding.wrappedValue = fallback
        }
    }
    
    struct Theme: Identifiable {
        let id = UUID()
        let name: String
        let bg: String
        let text: String
        let highlight: String
    }
}
