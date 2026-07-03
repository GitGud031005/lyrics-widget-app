import SwiftUI

@MainActor
struct SettingsView: View {
    @EnvironmentObject var store: LyricsStore
    
    @State private var localBgHex: String = ""
    @State private var localTextHex: String = ""
    @State private var localHighlightHex: String = ""
    
    private var themeBg: Color { Color(hex: store.backgroundColorHex) }
    private var themeText: Color { Color(hex: store.textColorHex) }
    private var themeHighlight: Color { Color(hex: store.highlightColorHex) }
    
    // Preset themes (Updated for Lamplight Press)
    private let themes = [
        Theme(name: "Classic", bg: "#F4E9D0", text: "#3A2C5C", highlight: "#E08244"),
        Theme(name: "Mint", bg: "#A8D6B8", text: "#3A2C5C", highlight: "#C23D3D"),
        Theme(name: "Midnight", bg: "#3A2C5C", text: "#F4E9D0", highlight: "#E08244"),
        Theme(name: "Parchment", bg: "#EFE0BE", text: "#3A2C5C", highlight: "#C23D3D")
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                PaperBackground(color: themeBg)
                
                ScrollView {
                    VStack(spacing: 36) {
                        // Live Preview Box
                        widgetPreviewSection
                        
                        // Theme Presets
                        themePresetsSection
                        
                        // Fine-tuned settings
                        appearanceSettingsSection
                        
                        // Diagnostics & Connectivity
                        diagnosticsSection
                    }
                    .padding(24)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("CONFIGURE YOUR SETUP")
                        .font(DesignSystem.display(size: 16, weight: .black))
                        .tracking(2.5)
                        .foregroundColor(themeText)
                }
            }
            .onAppear {
                localBgHex = store.backgroundColorHex
                localTextHex = store.textColorHex
                localHighlightHex = store.highlightColorHex
            }
        }
    }
    
    // MARK: - Widget Preview
    
    private var widgetPreviewSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("REAL-TIME PREVIEW")
                .font(.system(size: 10, weight: .black))
                .tracking(2)
                .foregroundColor(themeText.opacity(0.8))
                .padding(.leading, 8)
            
            // Mock "Home Screen" Backdrop
            ZStack {
                // Background texture
                PaperBackground(color: themeHighlight.opacity(0.15), hasGrain: false)
                
                // Decorative Paper Clouds (Collage style)
                Group {
                    PaperCutShape()
                        .fill(themeBg.opacity(0.5))
                        .frame(width: 280, height: 180)
                        .offset(x: -80, y: -80)
                        .rotationEffect(.degrees(5))
                    
                    PaperCutShape()
                        .fill(themeHighlight.opacity(0.15))
                        .frame(width: 200, height: 120)
                        .offset(x: 100, y: 60)
                        .rotationEffect(.degrees(-10))
                }
                
                // The Widget Mockup
                ZStack {
                    PaperCutShape()
                        .fill(Color(hex: store.backgroundColorHex))
                        .paperCutShadow()
                    
                    VStack(spacing: 8) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(store.currentSong?.trackName ?? "Song Name")
                                    .font(DesignSystem.display(size: 14, weight: .black))
                                    .foregroundColor(Color(hex: store.textColorHex))
                                    .lineLimit(1)
                                
                                Text(store.currentSong?.artistName ?? "Artist Name")
                                    .font(DesignSystem.display(size: 11, weight: .medium, italic: true))
                                    .foregroundColor(Color(hex: store.textColorHex).opacity(0.7))
                                    .lineLimit(1)
                            }
                            Spacer()
                            Image(systemName: "music.note.list")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(Color(hex: store.highlightColorHex))
                        }
                        .padding(.bottom, 6)
                        
                        // Mock lyrics window
                        VStack(alignment: .leading, spacing: 6) {
                            let lines = ["...borrowed the moon.", "Tonight, said the rabbit...", "Just for safe keeping."]
                            
                            ForEach(Array(lines.enumerated()), id: \.offset) { index, text in
                                let isCurrent = (index == 1)
                                Text(text)
                                    .font(DesignSystem.display(size: CGFloat(store.fontSize), weight: isCurrent ? .black : .medium))
                                    .foregroundColor(isCurrent ? Color(hex: store.textColorHex) : Color(hex: store.textColorHex).opacity(0.55))
                                    .lineLimit(1)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.vertical, 3)
                                    .padding(.horizontal, 8)
                                    .background(
                                        ZStack {
                                            if isCurrent {
                                                WashiTape(color: Color(hex: store.highlightColorHex), rotation: .degrees(-1.2))
                                            }
                                        }
                                    )
                            }
                        }
                    }
                    .padding(20)
                }
                .frame(width: 310, height: 170)
            }
            .frame(height: 240)
            .clipShape(PaperCutShape())
            .overlay(PaperCutShape().stroke(themeText.opacity(0.25), lineWidth: 2))
            .paperCutShadow()
        }
    }
    
    // MARK: - Themes
    
    private var themePresetsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("QUICK STYLING PRESETS")
                .font(.system(size: 10, weight: .black))
                .tracking(2)
                .foregroundColor(themeText.opacity(0.8))
                .padding(.leading, 8)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(themes) { theme in
                        Button(action: { applyTheme(theme) }) {
                            VStack(spacing: 14) {
                                // Palette preview in a small paper cut shape
                                ZStack {
                                    PaperCutShape()
                                        .fill(Color(hex: theme.bg))
                                        .frame(width: 64, height: 44)
                                        .overlay(PaperCutShape().stroke(Color.lpInk.opacity(0.2), lineWidth: 1))
                                    
                                    Circle()
                                        .fill(Color(hex: theme.highlight))
                                        .frame(width: 18, height: 18)
                                        .offset(x: 12, y: 8)
                                    
                                    Circle()
                                        .fill(Color(hex: theme.text))
                                        .frame(width: 14, height: 14)
                                        .offset(x: -18, y: -6)
                                }
                                
                                Text(theme.name.uppercased())
                                    .font(.system(size: 10, weight: .black))
                                    .tracking(1)
                                    .foregroundColor(themeText)
                            }
                            .padding(.vertical, 18)
                            .padding(.horizontal, 14)
                            .background(
                                PaperCutShape()
                                    .fill(isThemeApplied(theme) ? themeHighlight.opacity(0.25) : themeText.opacity(0.05))
                                    .overlay(
                                        PaperCutShape()
                                            .stroke(isThemeApplied(theme) ? themeHighlight : themeText.opacity(0.1), lineWidth: isThemeApplied(theme) ? 2 : 1)
                                    )
                            )
                            .paperCutShadow()
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 10)
                .padding(.bottom, 10)
            }
        }
    }
    
    // MARK: - Options Group
    
    private var appearanceSettingsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("MANUAL ADJUSTMENTS")
                .font(.system(size: 10, weight: .black))
                .tracking(2)
                .foregroundColor(themeText.opacity(0.8))
                .padding(.leading, 8)
            
            VStack(spacing: 0) {
                customColorRow(title: "Background", hex: $localBgHex, onCommit: { applyHexIfValid($localBgHex, field: .background) })
                customColorRow(title: "Context Lines", hex: $localTextHex, onCommit: { applyHexIfValid($localTextHex, field: .text) })
                customColorRow(title: "Active Highlight", hex: $localHighlightHex, onCommit: { applyHexIfValid($localHighlightHex, field: .highlight) })
                
                DottedDivider().padding(.horizontal, 20).padding(.vertical, 12)
                
                // Font Size Slider
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Text Sizing")
                            .font(DesignSystem.display(size: 16, weight: .bold))
                            .foregroundColor(themeText)
                        Spacer()
                        Text("\(Int(store.fontSize)) pt")
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(themeText.opacity(0.8))
                    }
                    
                    Slider(value: $store.fontSize, in: 12...22, step: 1)
                        .tint(themeHighlight)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                
                Divider().background(themeText.opacity(0.08)).padding(.horizontal, 20)
                
                // Visible lines
                HStack {
                    Text("Line Capacity")
                        .font(DesignSystem.display(size: 16, weight: .bold))
                        .foregroundColor(themeText)
                    Spacer()
                    Picker("", selection: $store.linesVisible) {
                        Text("3 Lines").tag(3)
                        Text("5 Lines").tag(5)
                        Text("7 Lines").tag(7)
                    }
                    .pickerStyle(.menu)
                    .tint(themeHighlight)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
            }
            .background(
                PaperCutShape()
                    .fill(Color.white.opacity(0.35))
                    .overlay(PaperCutShape().stroke(themeText.opacity(0.15), lineWidth: 1))
            )
            .paperCutShadow()
        }
    }
    
    private func customColorRow(title: String, hex: Binding<String>, onCommit: @escaping () -> Void) -> some View {
        HStack {
            Text(title)
                .font(DesignSystem.display(size: 16, weight: .bold))
                .foregroundColor(themeText)
            Spacer()
            
            TextField("#FFFFFF", text: hex)
                .onSubmit(onCommit)
                .frame(width: 80)
                .multilineTextAlignment(.trailing)
                .foregroundColor(themeText.opacity(0.9))
                .font(.system(size: 13, weight: .medium, design: .monospaced))
                .autocorrectionDisabled()
                .textInputAutocapitalization(.characters)
            
            PaperCutShape()
                .fill(Color(hex: hex.wrappedValue))
                .frame(width: 26, height: 26)
                .overlay(PaperCutShape().stroke(themeText.opacity(0.4), lineWidth: 1.5))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
    
    // MARK: - Diagnostics
    
    private var diagnosticsSection: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: AppGroupHelper.isAppGroupAccessible ? "checkmark.seal.fill" : "exclamationmark.shield.fill")
                    .font(.system(size: 18))
                Text(AppGroupHelper.isAppGroupAccessible ? "SHARED STORAGE ACTIVE" : "CONNECTION REQUIRED")
                    .font(DesignSystem.display(size: 12, weight: .black))
                    .tracking(1)
            }
            .foregroundColor(AppGroupHelper.isAppGroupAccessible ? Color.lpMint : Color.lpCrimson)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(
                WashiTape(color: themeText.opacity(0.08), rotation: .degrees(-0.5))
                    .overlay(Rectangle().stroke(themeText.opacity(0.1), lineWidth: 1))
            )
            .paperCutShadow()
            
            VStack(spacing: 4) {
                Text("LYRICO v1.0")
                    .font(.system(size: 10, weight: .black))
                    .tracking(1)
                Text("picture books for the home screen")
                    .font(DesignSystem.display(size: 10, weight: .light, italic: true))
            }
            .opacity(0.4)
            .padding(.top, 16)
        }
        .padding(.bottom, 32)
    }
    
    // MARK: - Helper Methods
    
    private func applyTheme(_ theme: Theme) {
        withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
            store.performBatchUpdate {
                store.backgroundColorHex = theme.bg
                store.textColorHex = theme.text
                store.highlightColorHex = theme.highlight
            }
            localBgHex = theme.bg
            localTextHex = theme.text
            localHighlightHex = theme.highlight
        }
        
        // Haptic Feedback
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
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
