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
    private var isDark: Bool { store.backgroundColorHex.uppercased() == "#3A2C5C" }
    private var cardBg: Color { isDark ? Color(hex: "#A8D6B8").opacity(0.12) : Color.lpCream }
    private var shadowColor: Color { isDark ? Color(hex: "#1A1230") : Color.lpInk.opacity(0.35) }
    
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
                    VStack(spacing: 40) {
                        // Live Preview Box
                        widgetPreviewSection
                        
                        // Theme Presets
                        themePresetsSection
                        
                        // Fine-tuned settings
                        customTweaksSection
                        
                        // Diagnostics & Connectivity
                        diagnosticsSection
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                    .padding(.bottom, 80)
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
            
            // Scrap-paper collage backdrop
            ZStack {
                // Decorative layered paper sheets
                PaperCutShape()
                    .fill(Color.lpMint)
                    .frame(width: 280, height: 180)
                    .offset(x: -70, y: -70)
                    .rotationEffect(.degrees(5))
                    .shadow(color: shadowColor, radius: 0, x: 8, y: 8)
                
                PaperCutShape()
                    .fill(Color.lpCream2)
                    .frame(width: 200, height: 120)
                    .offset(x: 90, y: 60)
                    .rotationEffect(.degrees(-10))
                    .shadow(color: shadowColor, radius: 0, x: 8, y: 8)
                
                // The Widget Mockup
                ZStack {
                    PaperCutShape()
                        .fill(Color(hex: store.backgroundColorHex))
                        .shadow(color: shadowColor, radius: 0, x: 8, y: 8)
                    
                    VStack(spacing: 0) {
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
                        .padding(.bottom, 12)
                        
                        // Mock lyrics window
                        VStack(alignment: .leading, spacing: 6) {
                            let lines = ["You told me that we were forever", "But forever was a lie...", "And now I'm here alone"]
                            
                            ForEach(0..<lines.count, id: \.self) { index in
                                let text = lines[index]
                                let isCurrent = (index == 1)
                                
                                Text(text)
                                    .font(DesignSystem.display(size: CGFloat(store.fontSize), weight: isCurrent ? .black : .medium))
                                    .foregroundColor(isCurrent ? Color.lpInk : Color(hex: store.textColorHex).opacity(0.55))
                                    .lineLimit(2)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .multilineTextAlignment(.center)
                                    .padding(.vertical, 6)
                                    .padding(.horizontal, 12)
                                    .background(
                                        Group {
                                            if isCurrent {
                                                lyricHighlightTape
                                            }
                                        }
                                    )
                            }
                        }
                    }
                    .padding(20)
                }
                .frame(width: 300, height: 200)
            }
            .frame(height: 260)
        }
    }
    
    private var lyricHighlightTape: some View {
        GeometryReader { geo in
            ZStack {
                Color.lpPumpkin
                    .rotationEffect(.degrees(-1))
                    .offset(x: 2, y: 0)
                // Subtle blurred white stripes
                Canvas { context, size in
                    let stripeColor = Color.white.opacity(0.2)
                    let step: CGFloat = 14
                    let stripeWidth: CGFloat = 7
                    for x in stride(from: -size.height, to: size.width + step, by: step) {
                        var path = Path()
                        path.move(to: CGPoint(x: x + size.height, y: 0))
                        path.addLine(to: CGPoint(x: x + size.height + stripeWidth, y: 0))
                        path.addLine(to: CGPoint(x: x + stripeWidth, y: size.height))
                        path.addLine(to: CGPoint(x: x, y: size.height))
                        path.closeSubpath()
                        context.fill(path, with: .color(stripeColor))
                    }
                }
                .blur(radius: 1.5)
                .allowsHitTesting(false)
            }
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
            
            // Stacked polaroid-style presets
            VStack(spacing: -24) {
                ForEach(0..<themes.count, id: \.self) { index in
                    let theme = themes[index]
                    Button(action: { applyTheme(theme) }) {
                        polaroidCard(theme: theme, index: index, isSelected: isThemeApplied(theme))
                    }
                    .buttonStyle(.plain)
                    .zIndex(Double(themes.count - index))
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
    }
    
    private func polaroidCard(theme: Theme, index: Int, isSelected: Bool) -> some View {
        let rotations: [Double] = [-4, 5, -2, 3]
        let offsets: [CGFloat] = [0, 24, -16, 8]
        
        return VStack(spacing: 10) {
            ZStack {
                PaperCutShape()
                    .fill(Color(hex: theme.bg))
                    .frame(height: 72)
                    .overlay(PaperCutShape().stroke(Color.lpInk.opacity(0.2), lineWidth: 1))
                
                HStack(spacing: 12) {
                    Circle()
                        .fill(Color(hex: theme.text))
                        .frame(width: 14, height: 14)
                    
                    Circle()
                        .fill(Color(hex: theme.highlight))
                        .frame(width: 20, height: 20)
                    
                    Spacer()
                    
                    Text(theme.name.uppercased())
                        .font(DesignSystem.display(size: 18, weight: .black))
                        .foregroundColor(Color(hex: theme.text))
                }
                .padding(.horizontal, 16)
            }
        }
        .padding(12)
        .padding(.bottom, 28)
        .background(
            PaperCutShape()
                .fill(Color.lpCream)
                .overlay(
                    PaperCutShape()
                        .stroke(isSelected ? Color.lpPumpkin : Color.lpInk.opacity(0.15), lineWidth: isSelected ? 3 : 1)
                )
        )
        .shadow(color: shadowColor, radius: 0, x: 6, y: 6)
        .rotationEffect(.degrees(rotations[index % rotations.count]))
        .offset(x: offsets[index % offsets.count])
    }
    
    // MARK: - Custom Tweaks
    
    private var customTweaksSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("CUSTOM TWEAKS")
                .font(.system(size: 10, weight: .black))
                .tracking(2)
                .foregroundColor(themeText.opacity(0.8))
                .padding(.leading, 8)
            
            VStack(spacing: 0) {
                // Text Sizing
                VStack(spacing: 4) {
                    HStack {
                        Text("TEXT SIZING")
                            .font(.system(size: 11, weight: .black))
                            .tracking(2)
                            .foregroundColor(themeText.opacity(0.6))
                        Spacer()
                        Text("\(Int(store.fontSize))pt")
                            .font(DesignSystem.display(size: 22, weight: .black))
                            .foregroundColor(themeHighlight)
                    }
                    
                    Slider(value: $store.fontSize, in: 12...22, step: 1)
                        .tint(themeHighlight)
                    
                    HStack {
                        Text("PETITE")
                        Spacer()
                        Text("STANDARD")
                        Spacer()
                        Text("ENORMOUS")
                    }
                    .font(.system(size: 10, weight: .black))
                    .tracking(1)
                    .foregroundColor(themeText.opacity(0.4))
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                
                Divider().background(themeText.opacity(0.08)).padding(.horizontal, 20)
                
                // Line Capacity
                HStack {
                    Text("LINE CAPACITY")
                        .font(.system(size: 11, weight: .black))
                        .tracking(2)
                        .foregroundColor(themeText.opacity(0.6))
                    Spacer()
                    Picker("", selection: $store.linesVisible) {
                        Text("3 Lines").tag(3)
                        Text("5 Lines").tag(5)
                        Text("7 Lines").tag(7)
                    }
                    .pickerStyle(.menu)
                    .tint(themeHighlight)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(themeHighlight)
                    .foregroundColor(Color.lpInk)
                    .clipShape(PaperCutShape())
                    .shadow(color: shadowColor, radius: 0, x: 4, y: 4)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .background(
                PaperCutShape()
                    .fill(cardBg)
                    .overlay(PaperCutShape().stroke(themeText.opacity(0.15), lineWidth: 1))
            )
            .shadow(color: shadowColor, radius: 0, x: 6, y: 6)
        }
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
            .foregroundColor(Color.lpInk)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(
                WashiTape(color: Color.lpCream2, rotation: .degrees(-0.5))
                    .overlay(Rectangle().stroke(Color.lpInk.opacity(0.15), lineWidth: 1))
            )
            .shadow(color: shadowColor, radius: 0, x: 4, y: 4)
            
            VStack(spacing: 4) {
                Text("LYRICO v1.0")
                    .font(.system(size: 10, weight: .black))
                    .tracking(1)
                Text("picture books for the home screen")
                    .font(DesignSystem.display(size: 10, weight: .light, italic: true))
            }
            .foregroundColor(themeText.opacity(0.4))
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
        
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
    
    private func isThemeApplied(_ theme: Theme) -> Bool {
        return store.backgroundColorHex.uppercased() == theme.bg.uppercased() &&
               store.textColorHex.uppercased() == theme.text.uppercased() &&
               store.highlightColorHex.uppercased() == theme.highlight.uppercased()
    }
    
    struct Theme: Identifiable {
        let id = UUID()
        let name: String
        let bg: String
        let text: String
        let highlight: String
    }
}
