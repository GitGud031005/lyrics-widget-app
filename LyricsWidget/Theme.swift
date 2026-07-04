import SwiftUI

// MARK: - Design System: Lamplight Press Aesthetic

extension Color {
    static let lpCream = Color(hex: "#F4E9D0")
    static let lpCream2 = Color(hex: "#EFE0BE")
    static let lpInk = Color(hex: "#3A2C5C")
    static let lpInkDark = Color(hex: "#2A1E45")
    static let lpPumpkin = Color(hex: "#E08244")
    static let lpMint = Color(hex: "#A8D6B8")
    static let lpCrimson = Color(hex: "#C23D3D")
    static let lpDeepShadow = Color(hex: "#1A1230")
    
    // Legacy aliases for compatibility or semantic usage
    static let lpBackground = lpCream
    static let lpHumanRead = lpPumpkin
    static let lpHighlight = lpCrimson
}

struct DesignSystem {
    /// PostScript/full name of the bundled display font.
    /// Verify this matches the name reported by `UIFont.fontNames(forFamilyName:)`
    /// after adding the font files to the app and widget targets.
    static let displayFont = "Lyrico Display Midnight"
    static let bodyFont = "Inter"
    
    static func display(size: CGFloat, weight: Font.Weight = .bold, italic: Bool = false) -> Font {
        let base = Font.custom(displayFont, size: size, relativeTo: .largeTitle)
            .weight(weight)
        return italic ? base.italic() : base
    }
    
    static func body(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        Font.custom(bodyFont, size: size, relativeTo: .body)
            .weight(weight)
    }
}

// MARK: - Custom Shapes & Modifiers

struct PaperCutShape: Shape {
    var seed: CGFloat = 0
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        
        // Simulating the hand-cut imperfect edges from the design
        path.move(to: CGPoint(x: w * 0.01, y: h * 0.02))
        path.addLine(to: CGPoint(x: w * 0.08, y: 0))
        path.addLine(to: CGPoint(x: w * 0.22, y: h * 0.03))
        path.addLine(to: CGPoint(x: w * 0.45, y: h * 0.01))
        path.addLine(to: CGPoint(x: w * 0.70, y: h * 0.02))
        path.addLine(to: CGPoint(x: w * 0.88, y: 0))
        path.addLine(to: CGPoint(x: w * 0.99, y: h * 0.03))
        path.addLine(to: CGPoint(x: w, y: h * 0.18))
        path.addLine(to: CGPoint(x: w * 0.98, y: h * 0.40))
        path.addLine(to: CGPoint(x: w, y: h * 0.62))
        path.addLine(to: CGPoint(x: w * 0.99, y: h * 0.82))
        path.addLine(to: CGPoint(x: w, y: h * 0.97))
        path.addLine(to: CGPoint(x: w * 0.84, y: h))
        path.addLine(to: CGPoint(x: w * 0.60, y: h * 0.98))
        path.addLine(to: CGPoint(x: w * 0.36, y: h))
        path.addLine(to: CGPoint(x: w * 0.14, y: h * 0.99))
        path.addLine(to: CGPoint(x: w * 0.02, y: h))
        path.addLine(to: CGPoint(x: 0, y: h * 0.80))
        path.addLine(to: CGPoint(x: w * 0.02, y: h * 0.55))
        path.addLine(to: CGPoint(x: 0, y: h * 0.30))
        path.addLine(to: CGPoint(x: w * 0.01, y: h * 0.12))
        path.closeSubpath()
        
        return path
    }
}

struct PaperBackground: View {
    var color: Color = .lpCream
    var hasGrain: Bool = true
    @Environment(\.widgetFamily) var widgetFamily // Detect if in widget
    
    var body: some View {
        ZStack {
            color
            
            if hasGrain {
                // Repeating pattern of dots (stippled texture) matching the canvas design
                Canvas { context, size in
                    let dotRadius: CGFloat = 1.0
                    let spacing: CGFloat = 20.0
                    let dotColor = Color.lpInk.opacity(0.04)
                    
                    for y in stride(from: 0, to: size.height, by: spacing) {
                        for x in stride(from: 0, to: size.width, by: spacing) {
                            let rect = CGRect(x: x - dotRadius, y: y - dotRadius, width: dotRadius * 2, height: dotRadius * 2)
                            context.fill(Path(ellipseIn: rect), with: .color(dotColor))
                        }
                    }
                }
                .allowsHitTesting(false)
            }
        }
        .ignoresSafeArea()
    }
}

// MARK: - Midnight Mood Background

/// Deep ink background with cream stipple dots used by the Midnight Mood settings screen.
struct MidnightStippleBackground: View {
    var body: some View {
        ZStack {
            Color.lpInk
            
            Canvas { context, size in
                let dotRadius: CGFloat = 0.8
                let spacing: CGFloat = 10.0
                let dotColor = Color.lpCream.opacity(0.12)
                
                for y in stride(from: 0, to: size.height, by: spacing) {
                    for x in stride(from: 0, to: size.width, by: spacing) {
                        let rect = CGRect(x: x - dotRadius, y: y - dotRadius, width: dotRadius * 2, height: dotRadius * 2)
                        context.fill(Path(ellipseIn: rect), with: .color(dotColor))
                    }
                }
            }
            .allowsHitTesting(false)
        }
        .ignoresSafeArea()
    }
}

struct WashiTape: View {
    var color: Color = .lpPumpkin
    var rotation: Angle = .degrees(0)
    
    var body: some View {
        Canvas { context, size in
            let baseColor = color.opacity(0.55)
            let stripeColor = color.opacity(0.4)
            
            // Fill background with base color
            context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(baseColor))
            
            // Draw diagonal stripes slanted /
            let width = size.width
            let height = size.height
            let step: CGFloat = 16
            let stripeWidth: CGFloat = 8
            
            for x in stride(from: -height, to: width + step, by: step) {
                var path = Path()
                path.move(to: CGPoint(x: x + height, y: 0))
                path.addLine(to: CGPoint(x: x + height + stripeWidth, y: 0))
                path.addLine(to: CGPoint(x: x + stripeWidth, y: height))
                path.addLine(to: CGPoint(x: x, y: height))
                path.closeSubpath()
                context.fill(path, with: .color(stripeColor))
            }
        }
        .frame(height: 22)
        .overlay(
            Rectangle()
                .stroke(Color.lpInk.opacity(0.25), style: StrokeStyle(lineWidth: 1, dash: [4]))
        )
        .rotationEffect(rotation)
    }
}

struct DottedDivider: View {
    var color: Color = .lpInk
    
    var body: some View {
        GeometryReader { geo in
            Path { path in
                path.move(to: CGPoint(x: 0, y: geo.size.height / 2))
                path.addLine(to: CGPoint(x: geo.size.width, y: geo.size.height / 2))
            }
            .stroke(color, style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [0.1, 12]))
        }
        .frame(height: 12)
    }
}

struct DotPatternDivider: View {
    var color: Color = .lpPumpkin
    var dotSize: CGFloat = 2.5
    var spacing: CGFloat = 12
    
    var body: some View {
        GeometryReader { geo in
            Canvas { context, size in
                let radius = dotSize / 2
                let rowY = size.height / 2
                for x in stride(from: 0, to: size.width, by: spacing) {
                    let rect = CGRect(x: x - radius, y: rowY - radius, width: dotSize, height: dotSize)
                    context.fill(Path(ellipseIn: rect), with: .color(color))
                }
            }
        }
        .frame(height: 12)
    }
}

// MARK: - Midnight Settings Shapes

/// Subtle scalloped/torn border matching the canvas `torn-border` clip-path.
struct ScallopedTornBorderShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        let steps = 20
        let step = w / CGFloat(steps)
        let notch = h * 0.025
        
        // Top edge: gentle scallops
        path.move(to: CGPoint(x: 0, y: notch * 0.8))
        for i in 0...steps {
            let x = CGFloat(i) * step
            let y = (i % 2 == 0) ? 0 : notch
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        // Right edge
        path.addLine(to: CGPoint(x: w, y: h - notch * 0.8))
        
        // Bottom edge: gentle scallops
        for i in (0...steps).reversed() {
            let x = CGFloat(i) * step
            let y = (i % 2 == 0) ? h : h - notch
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        // Left edge
        path.addLine(to: CGPoint(x: 0, y: notch * 0.8))
        path.closeSubpath()
        return path
    }
}

/// Slanted torn rectangle for the active lyric line washi tape.
struct TornTapeShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        
        path.move(to: CGPoint(x: w * 0.02, y: 0))
        path.addLine(to: CGPoint(x: w * 0.98, y: h * 0.05))
        path.addLine(to: CGPoint(x: w, y: h * 0.95))
        path.addLine(to: CGPoint(x: 0, y: h))
        path.closeSubpath()
        return path
    }
}

/// Small cream stipple dots usable as an overlay/clipped pattern.
struct StipplePatternView: View {
    var dotRadius: CGFloat = 0.6
    var spacing: CGFloat = 10
    var opacity: Double = 0.12
    
    var body: some View {
        GeometryReader { geo in
            Canvas { context, size in
                let dotColor = Color.lpCream.opacity(opacity)
                
                for y in stride(from: 0, to: size.height, by: spacing) {
                    for x in stride(from: 0, to: size.width, by: spacing) {
                        let r = CGRect(x: x - dotRadius, y: y - dotRadius, width: dotRadius * 2, height: dotRadius * 2)
                        context.fill(Path(ellipseIn: r), with: .color(dotColor))
                    }
                }
            }
        }
    }
}

/// Pumpkin washi tape with torn/notched left and right ends.
struct TornWashiTape: View {
    var body: some View {
        GeometryReader { geo in
            let h = geo.size.height
            let notch: CGFloat = min(10, h * 0.35)
            
            Canvas { context, size in
                var path = Path()
                // Main body
                path.move(to: CGPoint(x: notch, y: 0))
                path.addLine(to: CGPoint(x: size.width - notch, y: 0))
                // Right torn edge
                path.addLine(to: CGPoint(x: size.width - notch * 0.2, y: h * 0.1))
                path.addLine(to: CGPoint(x: size.width - notch * 0.8, y: h * 0.25))
                path.addLine(to: CGPoint(x: size.width, y: h * 0.4))
                path.addLine(to: CGPoint(x: size.width - notch * 0.1, y: h * 0.6))
                path.addLine(to: CGPoint(x: size.width - notch * 0.9, y: h * 0.8))
                path.addLine(to: CGPoint(x: size.width - notch, y: h))
                // Bottom
                path.addLine(to: CGPoint(x: notch, y: h))
                // Left torn edge
                path.addLine(to: CGPoint(x: notch * 0.9, y: h * 0.8))
                path.addLine(to: CGPoint(x: notch * 0.1, y: h * 0.6))
                path.addLine(to: CGPoint(x: 0, y: h * 0.4))
                path.addLine(to: CGPoint(x: notch * 0.8, y: h * 0.25))
                path.addLine(to: CGPoint(x: notch * 0.2, y: h * 0.1))
                path.closeSubpath()
                
                context.fill(path, with: .color(Color.lpPumpkin))
                context.stroke(path, with: .color(Color.lpCream.opacity(0.4)), style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [6, 6]))
            }
        }
        .frame(minHeight: 44)
    }
}

// MARK: - Midnight Display Background

/// Deep ink background with two-layer stipple dots and grain overlay
/// used by the Lyrico Display – Midnight canvas design.
struct MidnightDisplayBackground: View {
    var baseColor: Color = .lpInk
    
    var body: some View {
        ZStack {
            baseColor
            
            // Mint stipple layer (12% opacity, 40 px spacing)
            Canvas { context, size in
                let dotRadius: CGFloat = 1.5
                let spacing: CGFloat = 40.0
                let dotColor = Color.lpMint.opacity(0.12)
                
                for y in stride(from: 0, to: size.height, by: spacing) {
                    for x in stride(from: 0, to: size.width, by: spacing) {
                        let rect = CGRect(x: x - dotRadius, y: y - dotRadius, width: dotRadius * 2, height: dotRadius * 2)
                        context.fill(Path(ellipseIn: rect), with: .color(dotColor))
                    }
                }
            }
            .allowsHitTesting(false)
            
            // Pumpkin stipple layer (8% opacity, 14 px spacing, offset)
            Canvas { context, size in
                let dotRadius: CGFloat = 1.0
                let spacing: CGFloat = 14.0
                let dotColor = Color.lpPumpkin.opacity(0.08)
                let offset: CGFloat = 7.0
                
                for y in stride(from: offset, to: size.height, by: spacing) {
                    for x in stride(from: offset, to: size.width, by: spacing) {
                        let rect = CGRect(x: x - dotRadius, y: y - dotRadius, width: dotRadius * 2, height: dotRadius * 2)
                        context.fill(Path(ellipseIn: rect), with: .color(dotColor))
                    }
                }
            }
            .allowsHitTesting(false)
            
            // Grain overlay
            Canvas { context, size in
                let noiseColor = Color.white.opacity(0.05)
                let step: CGFloat = 3.0
                
                for y in stride(from: 0, to: size.height, by: step) {
                    for x in stride(from: 0, to: size.width, by: step) {
                        // Pseudo-random noise based on position
                        let hash = sin(x * 12.9898 + y * 78.233) * 43758.5453
                        let value = hash - floor(hash)
                        if value < 0.14 {
                            let rect = CGRect(x: x, y: y, width: 1, height: 1)
                            context.fill(Path(rect), with: .color(noiseColor))
                        }
                    }
                }
            }
            .blendMode(.overlay)
            .opacity(0.35)
            .allowsHitTesting(false)
        }
        .ignoresSafeArea()
    }
}

// MARK: - Scallop Divider

/// Repeating semi-circle cutout divider matching the canvas scallop-divider.
struct ScallopDivider: View {
    var color: Color = .lpInk
    var invert: Bool = false
    
    var body: some View {
        GeometryReader { geo in
            let radius: CGFloat = 8
            let diameter = radius * 2
            let count = max(1, Int(geo.size.width / diameter) + 1)
            
            Canvas { context, size in
                for i in 0..<count {
                    let cx = CGFloat(i) * diameter + radius
                    let cy: CGFloat = invert ? size.height : 0
                    let path = Path {
                        if invert {
                            $0.move(to: CGPoint(x: cx - radius, y: 0))
                            $0.addArc(center: CGPoint(x: cx, y: 0), radius: radius, startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
                            $0.addLine(to: CGPoint(x: cx + radius, y: 0))
                            $0.addLine(to: CGPoint(x: cx + radius, y: size.height))
                            $0.addLine(to: CGPoint(x: cx - radius, y: size.height))
                        } else {
                            $0.move(to: CGPoint(x: cx - radius, y: size.height))
                            $0.addArc(center: CGPoint(x: cx, y: size.height), radius: radius, startAngle: .degrees(180), endAngle: .degrees(0), clockwise: true)
                            $0.addLine(to: CGPoint(x: cx + radius, y: size.height))
                            $0.addLine(to: CGPoint(x: cx + radius, y: 0))
                            $0.addLine(to: CGPoint(x: cx - radius, y: 0))
                        }
                        $0.closeSubpath()
                    }
                    context.fill(path, with: .color(color))
                }
            }
        }
        .frame(height: 12)
    }
}

// MARK: - Cut Card Shape

/// Hand-cut irregular card shape from the Lyrico Display – Midnight canvas.
struct CutCardShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        
        path.move(to: CGPoint(x: w * 0.01, y: h * 0.02))
        path.addLine(to: CGPoint(x: w * 0.12, y: 0))
        path.addLine(to: CGPoint(x: w * 0.25, y: h * 0.03))
        path.addLine(to: CGPoint(x: w * 0.48, y: h * 0.01))
        path.addLine(to: CGPoint(x: w * 0.72, y: h * 0.03))
        path.addLine(to: CGPoint(x: w * 0.90, y: 0))
        path.addLine(to: CGPoint(x: w * 0.99, y: h * 0.03))
        path.addLine(to: CGPoint(x: w, y: h * 0.20))
        path.addLine(to: CGPoint(x: w * 0.98, y: h * 0.45))
        path.addLine(to: CGPoint(x: w, y: h * 0.70))
        path.addLine(to: CGPoint(x: w * 0.99, y: h * 0.88))
        path.addLine(to: CGPoint(x: w, y: h * 0.98))
        path.addLine(to: CGPoint(x: w * 0.85, y: h))
        path.addLine(to: CGPoint(x: w * 0.62, y: h * 0.98))
        path.addLine(to: CGPoint(x: w * 0.38, y: h))
        path.addLine(to: CGPoint(x: w * 0.15, y: h * 0.99))
        path.addLine(to: CGPoint(x: w * 0.03, y: h))
        path.addLine(to: CGPoint(x: 0, y: h * 0.82))
        path.addLine(to: CGPoint(x: w * 0.02, y: h * 0.58))
        path.addLine(to: CGPoint(x: 0, y: h * 0.32))
        path.addLine(to: CGPoint(x: w * 0.01, y: h * 0.15))
        path.closeSubpath()
        
        return path
    }
}

// MARK: - Mint Washi Tape

/// Mint washi tape with diagonal stripes used on the active lyric card.
struct MintWashiTape: View {
    var body: some View {
        Canvas { context, size in
            let baseColor = Color.lpMint.opacity(0.45)
            let stripeColor = Color.lpMint.opacity(0.25)
            
            // Fill background
            context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(baseColor))
            
            // Diagonal stripes slanted /
            let step: CGFloat = 16
            let stripeWidth: CGFloat = 8
            
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
        .overlay(
            Rectangle()
                .stroke(Color.lpCream.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [4]))
        )
        .frame(height: 20)
    }
}

// MARK: - Offset Shadow Button Style

/// Neo-brutalist button with an irregular border-radius and hard offset shadow.
struct OffsetShadowButtonStyle: ButtonStyle {
    var background: Color = .lpPumpkin
    var foreground: Color = .lpInk
    var border: Color = .lpInkDark
    var shadow: Color = .lpInkDark
    var radii: (CGFloat, CGFloat, CGFloat, CGFloat) = (20, 28, 22, 26)
    var shadowOffset: CGSize = CGSize(width: 4, height: 4)
    var pressOffset: CGSize = CGSize(width: 1, height: 1)
    
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            // Offset shadow
            UnevenRoundedRectangle(
                topLeadingRadius: radii.0,
                bottomLeadingRadius: radii.2,
                bottomTrailingRadius: radii.3,
                topTrailingRadius: radii.1
            )
            .fill(shadow)
            .offset(x: shadowOffset.width, y: shadowOffset.height)
            
            // Main button
            UnevenRoundedRectangle(
                topLeadingRadius: radii.0,
                bottomLeadingRadius: radii.2,
                bottomTrailingRadius: radii.3,
                topTrailingRadius: radii.1
            )
            .fill(background)
            .overlay(
                UnevenRoundedRectangle(
                    topLeadingRadius: radii.0,
                    bottomLeadingRadius: radii.2,
                    bottomTrailingRadius: radii.3,
                    topTrailingRadius: radii.1
                )
                .stroke(border, lineWidth: 2)
            )
            .offset(
                x: configuration.isPressed ? pressOffset.width : 0,
                y: configuration.isPressed ? pressOffset.height : 0
            )
            
            configuration.label
                .foregroundColor(foreground)
                .offset(
                    x: configuration.isPressed ? pressOffset.width : 0,
                    y: configuration.isPressed ? pressOffset.height : 0
                )
        }
        .compositingGroup()
    }
}

// MARK: - View Extensions

extension View {
    func paperCutShadow() -> some View {
        self.shadow(color: Color.lpInk.opacity(0.35), radius: 10, x: 0, y: 8)
            .shadow(color: Color.lpInk.opacity(0.2), radius: 0, x: 0, y: 4)
    }
}
