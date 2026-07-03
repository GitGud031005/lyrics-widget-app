import SwiftUI

// MARK: - Design System: Lamplight Press Aesthetic

extension Color {
    static let lpCream = Color(hex: "#F4E9D0")
    static let lpCream2 = Color(hex: "#EFE0BE")
    static let lpInk = Color(hex: "#3A2C5C")
    static let lpPumpkin = Color(hex: "#E08244")
    static let lpMint = Color(hex: "#A8D6B8")
    static let lpCrimson = Color(hex: "#C23D3D")
    
    // Legacy aliases for compatibility or semantic usage
    static let lpBackground = lpCream
    static let lpHumanRead = lpPumpkin
    static let lpHighlight = lpCrimson
}

struct DesignSystem {
    static let displayFont = "Fraunces" // Will fallback to system serif if not available
    static let bodyFont = "Inter"       // Will fallback to system sans if not available
    
    static func display(size: CGFloat, weight: Font.Weight = .bold, italic: Bool = false) -> Font {
        let base = Font.system(size: size, weight: weight, design: .serif)
        return italic ? base.italic() : base
    }
    
    static func body(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        Font.system(size: size, weight: weight, design: .default)
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
                // Simpler, more performant grain for both app and widget
                // Using a repeating pattern of dots instead of random Canvas loops
                GeometryReader { geo in
                    ZStack {
                        // Base noise simulation with opacity layers
                        Color.lpInk.opacity(0.02)
                        
                        // Subtle gradient overlay for paper depth
                        RadialGradient(
                            colors: [Color.white.opacity(0.15), Color.clear],
                            center: .topLeading,
                            startRadius: 0,
                            endRadius: 500
                        )
                    }
                }
                .allowsHitTesting(false)
            }
        }
        .ignoresSafeArea()
    }
}

struct WashiTape: View {
    var color: Color = .lpPumpkin
    var rotation: Angle = .degrees(0)
    
    var body: some View {
        Canvas { context, size in
            let baseColor = color.opacity(0.4)
            let stripeColor = color.opacity(0.55)
            
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
                .stroke(Color.lpInk.opacity(0.1), style: StrokeStyle(lineWidth: 1, dash: [4]))
        )
        .rotationEffect(rotation)
    }
}

struct DottedDivider: View {
    var body: some View {
        GeometryReader { geo in
            Path { path in
                path.move(to: CGPoint(x: 0, y: geo.size.height / 2))
                path.addLine(to: CGPoint(x: geo.size.width, y: geo.size.height / 2))
            }
            .stroke(Color.lpInk, style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [0.1, 12]))
        }
        .frame(height: 12)
    }
}

// MARK: - View Extensions

extension View {
    func paperCutShadow() -> some View {
        self.shadow(color: Color.lpInk.opacity(0.35), radius: 10, x: 0, y: 8)
            .shadow(color: Color.lpInk.opacity(0.1), radius: 0, x: 0, y: 4)
    }
}
