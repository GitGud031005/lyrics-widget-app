import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            // Deep, dark space background with radial gradients for depth
            Color(hex: "#0F0F1A")
                .ignoresSafeArea()
            
            RadialGradient(
                colors: [Color(hex: "#E94560").opacity(0.15), Color.clear],
                center: .topLeading,
                startRadius: 50,
                endRadius: 500
            )
            .ignoresSafeArea()
            
            RadialGradient(
                colors: [Color(hex: "#0F3460").opacity(0.3), Color.clear],
                center: .bottomTrailing,
                startRadius: 100,
                endRadius: 600
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                // Pulsing glowing emblem
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "#E94560"), Color(hex: "#8A2387")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 90, height: 90)
                        .blur(radius: 8)
                        .opacity(0.6)
                    
                    Circle()
                        .fill(Color(hex: "#1A1A2E"))
                        .frame(width: 86, height: 86)
                    
                    Image(systemName: "music.note.list")
                        .font(.system(size: 38, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: "#E94560"), Color(hex: "#FF5E62")],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                }
                
                // App Title
                VStack(spacing: 8) {
                    Text("LYRICO")
                        .font(.system(size: 40, weight: .black, design: .rounded))
                        .tracking(4)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, Color(hex: "#FFD269").opacity(0.9)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    
                    Text("Interactive Lyrics Widget")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.gray)
                }
                
                // Status Glassmorphic Card
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "desktopcomputer")
                            .foregroundColor(Color(hex: "#4ECCA3"))
                        Text("Windows Bootstrapped")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color(hex: "#4ECCA3"))
                        Spacer()
                        Circle()
                            .fill(Color(hex: "#4ECCA3"))
                            .frame(width: 8, height: 8)
                    }
                    .padding(.bottom, 4)
                    
                    Text("Your development workspace has been successfully initialized on Windows. All files are structured for GitHub Actions building.")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.85))
                        .lineSpacing(4)
                    
                    Divider()
                        .background(Color.white.opacity(0.1))
                    
                    HStack(spacing: 12) {
                        statusBadge(text: "iOS 17+", color: .blue)
                        statusBadge(text: "SwiftUI", color: .purple)
                        statusBadge(text: "Unsigned IPA", color: .orange)
                    }
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.04))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                )
                .padding(.horizontal, 28)
                
                Spacer()
                
                // Footer
                Text("Ready for Phase 2: Core App Implementation")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white.opacity(0.3))
                    .padding(.bottom, 20)
            }
        }
    }
    
    private func statusBadge(text: String, color: Color) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(color.opacity(0.12))
            )
    }
}

// Helper Extension for Hex Colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    ContentView()
}
