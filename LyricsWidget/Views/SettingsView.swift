import SwiftUI

@MainActor
struct SettingsView: View {
    @EnvironmentObject var store: LyricsStore
    
    @State private var showLineCapacityPicker = false
    
    // Midnight Mood presets
    private let themes = [
        Theme(name: "Midnight Mood", bg: "#3A2C5C", text: "#F4E9D0", highlight: "#E08244"),
        Theme(name: "Minty Fresh", bg: "#A8D6B8", text: "#3A2C5C", highlight: "#C23D3D"),
        Theme(name: "Classic Press", bg: "#F4E9D0", text: "#3A2C5C", highlight: "#E08244")
    ]
    
    var body: some View {
        ZStack {
            MidnightStippleBackground()
            
            ScrollView {
                VStack(spacing: 44) {
                    headerSection
                    widgetPreviewSection
                    themePresetsSection
                    customTweaksSection
                    diagnosticsSection
                }
                .padding(.horizontal, 24)
                .padding(.top, 48)
                .padding(.bottom, 100)
            }
        }
    }
    
    // MARK: - Header
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("CONFIGURE\nYOUR SETUP")
                .font(DesignSystem.display(size: 42, weight: .black))
                .foregroundColor(.lpCream)
                .lineSpacing(-6)
            
            HStack(spacing: 12) {
                Rectangle()
                    .fill(Color.lpPumpkin)
                    .frame(width: 64, height: 8)
                    .shadow(color: Color.lpDeepShadow, radius: 0, x: 4, y: 4)
                
                Text("Version 2.0.4")
                    .font(DesignSystem.display(size: 14, weight: .bold, italic: true))
                    .foregroundColor(.lpMint)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Widget Preview
    
    private var widgetPreviewSection: some View {
        ZStack {
            // Decorative layered paper sheets
            PaperCutShape()
                .fill(Color.lpMint)
                .frame(width: 280, height: 180)
                .offset(x: -60, y: -60)
                .rotationEffect(.degrees(3))
                .shadow(color: .lpDeepShadow, radius: 0, x: 8, y: 8)
            
            PaperCutShape()
                .fill(Color.lpCream)
                .frame(width: 260, height: 180)
                .offset(x: -50, y: -50)
                .rotationEffect(.degrees(-2))
                .shadow(color: .lpDeepShadow, radius: 0, x: 8, y: 8)
            
            // Deep-shadow offset layer behind main card
            Rectangle()
                .fill(Color.lpDeepShadow.opacity(0.30))
                .frame(width: 320, height: 340)
                .offset(x: 4, y: 4)
            
            // Main cream preview card
            ZStack(alignment: .topTrailing) {
                ZStack {
                    Rectangle()
                        .fill(Color.lpCream)
                        .overlay(Rectangle().stroke(Color.lpDeepShadow, lineWidth: 6))
                    
                    VStack(spacing: 16) {
                        // Deep-shadow lyrics viewport
                        ZStack {
                            Color.lpDeepShadow
                                .overlay(Rectangle().stroke(Color.lpDeepShadow, lineWidth: 2))
                            
                            VStack(spacing: 12) {
                                Text("You told me that we were forever")
                                    .font(DesignSystem.display(size: CGFloat(store.fontSize), weight: .medium, italic: true))
                                    .foregroundColor(.lpCream.opacity(0.3))
                                    .multilineTextAlignment(.center)
                                    .lineLimit(2)
                                    .frame(maxWidth: .infinity)
                                    .padding(.horizontal, 12)
                                
                                DotPatternDivider(color: .lpPumpkin.opacity(0.4))
                                    .padding(.horizontal, 20)
                                
                                ZStack {
                                    Color.lpPumpkin
                                        .clipShape(TornTapeShape())
                                    
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
                                    
                                    Text("But forever\nwas a lie...")
                                        .font(DesignSystem.display(size: CGFloat(store.fontSize + 4), weight: .black))
                                        .foregroundColor(.lpInk)
                                        .multilineTextAlignment(.center)
                                        .lineLimit(2)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                }
                                .padding(.horizontal, 8)
                                
                                Text("And now I'm here alone")
                                    .font(DesignSystem.display(size: CGFloat(store.fontSize), weight: .medium, italic: true))
                                    .foregroundColor(.lpCream.opacity(0.4))
                                    .multilineTextAlignment(.center)
                                    .lineLimit(2)
                                    .frame(maxWidth: .infinity)
                                    .padding(.horizontal, 12)
                            }
                            .padding(.vertical, 20)
                        }
                        .frame(height: 220)
                        
                        // Preview Window label + color squares
                        HStack {
                            HStack(spacing: 6) {
                                Image(systemName: "music.note")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.lpInk)
                                
                                Text("Preview Window")
                                    .font(.system(size: 10, weight: .black))
                                    .tracking(0.2)
                                    .foregroundColor(.lpInk)
                            }
                            
                            Spacer()
                            
                            HStack(spacing: 6) {
                                themeColorSquare(.lpPumpkin)
                                themeColorSquare(.lpMint)
                                themeColorSquare(.lpInk)
                            }
                        }
                        .padding(.horizontal, 4)
                    }
                    .padding(20)
                }
                .compositingGroup()
                .shadow(color: .lpDeepShadow, radius: 0, x: 8, y: 8)
                
                // LIVE badge
                ZStack {
                    Rectangle()
                        .fill(Color.lpPumpkin)
                        .frame(width: 48, height: 48)
                        .rotationEffect(.degrees(12))
                        .overlay(Rectangle().stroke(Color.lpDeepShadow, lineWidth: 2))
                        .shadow(color: .lpDeepShadow, radius: 0, x: 4, y: 4)
                    
                    Text("LIVE")
                        .font(DesignSystem.display(size: 11, weight: .black))
                        .foregroundColor(.lpDeepShadow)
                        .rotationEffect(.degrees(12))
                }
                .offset(x: 10, y: -10)
            }
            .frame(width: 320, height: 340)
        }
        .frame(height: 380)
    }
    
    private func themeColorSquare(_ color: Color) -> some View {
        Rectangle()
            .fill(color)
            .frame(width: 10, height: 10)
            .overlay(Rectangle().stroke(Color.lpDeepShadow, lineWidth: 1))
            .shadow(color: .lpDeepShadow, radius: 0, x: 2, y: 2)
    }
    
    // MARK: - Theme Presets
    
    private var themePresetsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 12) {
                Text("Quick Presets")
                    .font(DesignSystem.display(size: 24, weight: .bold))
                    .foregroundColor(.lpCream)
                
                Rectangle()
                    .fill(Color.lpCream.opacity(0.2))
                    .frame(height: 2)
            }
            
            VStack(spacing: -50) {
                ForEach(0..<themes.count, id: \.self) { index in
                    let theme = themes[index]
                    Button(action: { applyTheme(theme) }) {
                        polaroidCard(theme: theme, index: index)
                    }
                    .buttonStyle(.plain)
                    .zIndex(Double(themes.count - index))
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 50)
        }
    }
    
    private func polaroidCard(theme: Theme, index: Int) -> some View {
        let rotations: [Double] = [-4, 5, -2]
        let offsets: [CGFloat] = [0, 24, -16]
        let isFirst = index == 0
        
        return ZStack {
            VStack(spacing: 0) {
                ZStack {
                    Rectangle()
                        .fill(Color(hex: theme.bg))
                        .aspectRatio(16.0 / 8.0, contentMode: .fit)
                        .overlay(Rectangle().stroke(Color.lpDeepShadow, lineWidth: 2))
                    
                    Text(theme.name.uppercased())
                        .font(DesignSystem.display(size: 20, weight: .black))
                        .foregroundColor(Color(hex: theme.text))
                        .lineLimit(1)
                        .tracking(-0.5)
                }
                .padding([.horizontal, .top], 12)
                .padding(.bottom, 40)
            }
            .background(Color.lpCream)
            .overlay(Rectangle().stroke(Color.lpDeepShadow, lineWidth: 3))
            .compositingGroup()
            .shadow(color: .lpDeepShadow, radius: 0, x: 8, y: 8)
            
            if isFirst {
                VStack {
                    Rectangle()
                        .fill(Color.lpPumpkin.opacity(0.8))
                        .frame(width: 15, height: 40)
                        .overlay(Rectangle().stroke(Color.lpDeepShadow, lineWidth: 1))
                        .shadow(color: .lpDeepShadow, radius: 0, x: 2, y: 2)
                        .rotationEffect(.degrees(-5))
                        .offset(y: -20)
                    Spacer()
                }
            }
        }
        .rotationEffect(.degrees(rotations[index % rotations.count]))
        .offset(x: offsets[index % offsets.count])
    }
    
    // MARK: - Custom Tweaks
    
    private var customTweaksSection: some View {
        ZStack {
            // Deep shadow offset
            ScallopedTornBorderShape()
                .fill(Color.lpDeepShadow.opacity(0.40))
                .offset(x: 3, y: 3)
            
            ScallopedTornBorderShape()
                .fill(Color.lpMint.opacity(0.10))
                .overlay(ScallopedTornBorderShape().stroke(Color.lpMint.opacity(0.30), lineWidth: 4))
                .compositingGroup()
                .shadow(color: Color.lpDeepShadow, radius: 0, x: 4, y: 4)
            
            // Subtle internal stipple overlay
            StipplePatternView(dotRadius: 0.5, spacing: 10, opacity: 0.08)
                .clipShape(ScallopedTornBorderShape())
                .allowsHitTesting(false)
            
            VStack(spacing: 28) {
                HStack {
                    Text("Custom Tweaks")
                        .font(DesignSystem.display(size: 24, weight: .bold))
                        .foregroundColor(.lpMint)
                    
                    Spacer()
                    
                    ZStack {
                        Circle()
                            .strokeBorder(Color.lpMint.opacity(0.40), style: StrokeStyle(lineWidth: 2, dash: [4]))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.lpMint.opacity(0.70))
                    }
                }
                
                // Text Sizing
                VStack(spacing: 8) {
                    HStack {
                        Text("TEXT SIZING")
                            .font(.system(size: 11, weight: .black))
                            .tracking(2)
                            .foregroundColor(Color.lpCream.opacity(0.6))
                        
                        Spacer()
                        
                        Text("\(Int(store.fontSize))pt")
                            .font(DesignSystem.display(size: 28, weight: .black))
                            .foregroundColor(Color.lpPumpkin)
                    }
                    
                    MidnightSlider(value: $store.fontSize, range: 12...22, step: 1)
                    
                    HStack {
                        Text("PETITE")
                        Spacer()
                        Text("STANDARD")
                        Spacer()
                        Text("ENORMOUS")
                    }
                    .font(.system(size: 10, weight: .black))
                    .tracking(1)
                    .foregroundColor(Color.lpCream.opacity(0.4))
                }
                
                // Line Capacity
                HStack {
                    Text("LINE CAPACITY")
                        .font(.system(size: 11, weight: .black))
                        .tracking(2)
                        .foregroundColor(Color.lpCream.opacity(0.6))
                    
                    Spacer()
                    
                    Button(action: { showLineCapacityPicker = true }) {
                        HStack(spacing: 6) {
                            Text("\(store.linesVisible) LINES")
                                .font(DesignSystem.display(size: 14, weight: .black))
                            
                            Image(systemName: "chevron.down")
                                .font(.system(size: 10, weight: .black))
                        }
                        .foregroundColor(Color.lpInk)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.lpPumpkin)
                        .overlay(Rectangle().stroke(Color.lpDeepShadow, lineWidth: 2))
                        .shadow(color: Color.lpDeepShadow, radius: 0, x: 4, y: 4)
                    }
                    .confirmationDialog("Line Capacity", isPresented: $showLineCapacityPicker, titleVisibility: .hidden) {
                        Button("3 Lines") { store.linesVisible = 3 }
                        Button("5 Lines") { store.linesVisible = 5 }
                        Button("7 Lines") { store.linesVisible = 7 }
                        Button("Cancel", role: .cancel) { }
                    }
                }
            }
            .padding(24)
        }
    }
    
    // MARK: - Diagnostics
    
    private var diagnosticsSection: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.lpMint)
                    .frame(width: 28, height: 28)
                    .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.lpDeepShadow, lineWidth: 2))
                    .rotationEffect(.degrees(3))
                
                Image(systemName: "checkmark")
                    .font(.system(size: 14, weight: .black))
                    .foregroundColor(.lpDeepShadow)
            }
            
            Text(AppGroupHelper.isAppGroupAccessible ? "Storage Sync Active" : "Connection Required")
                .font(DesignSystem.display(size: 14, weight: .black))
                .tracking(0.5)
                .foregroundColor(.lpDeepShadow)
            
            Spacer()
            
            HStack(spacing: 6) {
                Circle()
                    .fill(AppGroupHelper.isAppGroupAccessible ? Color.lpDeepShadow : Color.lpCrimson)
                    .frame(width: 6, height: 6)
                
                Text("v1.2")
                    .font(.system(size: 10, weight: .black))
                    .foregroundColor(.lpDeepShadow.opacity(0.6))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(
            TornWashiTape()
                .rotationEffect(.degrees(-2))
        )
        .compositingGroup()
        .shadow(color: .lpDeepShadow, radius: 0, x: 4, y: 4)
    }
    
    // MARK: - Helper Methods
    
    private func applyTheme(_ theme: Theme) {
        withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
            store.performBatchUpdate {
                store.backgroundColorHex = theme.bg
                store.textColorHex = theme.text
                store.highlightColorHex = theme.highlight
            }
        }
        
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
    
    struct Theme: Identifiable {
        let id = UUID()
        let name: String
        let bg: String
        let text: String
        let highlight: String
    }
}

// MARK: - Midnight Slider

struct MidnightSlider: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                HandDrawnTrack()
                    .fill(Color.lpDeepShadow)
                    .frame(height: 8)
                
                Rectangle()
                    .fill(Color.lpPumpkin)
                    .frame(width: 24, height: 12)
                    .overlay(Rectangle().stroke(Color.lpDeepShadow, lineWidth: 2))
                    .shadow(color: .lpDeepShadow, radius: 0, x: 2, y: 2)
                    .offset(x: thumbOffset(in: geo))
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture()
                    .onChanged { drag in
                        updateValue(from: drag.location.x, in: geo)
                    }
            )
        }
        .frame(height: 24)
    }
    
    private func thumbOffset(in geo: GeometryProxy) -> CGFloat {
        let trackWidth = geo.size.width - 24
        let pct = CGFloat((value - range.lowerBound) / (range.upperBound - range.lowerBound))
        return max(0, min(trackWidth, pct * trackWidth))
    }
    
    private func updateValue(from x: CGFloat, in geo: GeometryProxy) {
        let trackWidth = geo.size.width - 24
        let pct = Double(max(0, min(1, x / trackWidth)))
        let raw = range.lowerBound + pct * (range.upperBound - range.lowerBound)
        let stepped = round(raw / step) * step
        value = max(range.lowerBound, min(range.upperBound, stepped))
    }
}

// MARK: - Hand Drawn Track

struct HandDrawnTrack: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        
        // Matches canvas hand-drawn-slider clip-path: irregular top edge, straight bottom
        let points: [CGFloat] = [
            0.20, 0.00, 0.25, 0.05, 0.30, 0.10, 0.35, 0.15, 0.40, 0.20,
            0.45, 0.25, 0.50, 0.30, 0.55, 0.35, 0.60, 0.40, 0.65, 0.30,
            0.70, 0.55, 0.75, 0.35, 0.80, 0.60, 0.85, 0.40, 0.90, 0.65,
            0.95, 0.45, 1.00, 0.70
        ]
        
        path.move(to: CGPoint(x: 0, y: h * 0.20))
        
        for i in stride(from: 0, to: points.count, by: 2) {
            let x = w * points[i]
            let y = h * points[i + 1]
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        path.addLine(to: CGPoint(x: w, y: h))
        path.addLine(to: CGPoint(x: 0, y: h))
        path.closeSubpath()
        return path
    }
}

// MARK: - Torn Border Shape

struct TornBorderShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        let zigzagCount = 20
        
        // Top edge: zigzag down/up
        path.move(to: CGPoint(x: 0, y: h * 0.02))
        for i in 0...zigzagCount {
            let x = w * CGFloat(i) / CGFloat(zigzagCount)
            let y = (i % 2 == 0) ? 0 : h * 0.03
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        // Right edge
        path.addLine(to: CGPoint(x: w, y: h * 0.98))
        
        // Bottom edge: zigzag up/down
        for i in (0...zigzagCount).reversed() {
            let x = w * CGFloat(i) / CGFloat(zigzagCount)
            let y = (i % 2 == 0) ? h : h * 0.97
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        // Left edge
        path.addLine(to: CGPoint(x: 0, y: h * 0.02))
        path.closeSubpath()
        
        return path
    }
}

