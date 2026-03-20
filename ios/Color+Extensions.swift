import SwiftUI

extension Color {
    static let shieldBackground = Color(hex: "#08101B")
    static let shieldSurface = Color.white.opacity(0.05)
    static let shieldBorder = Color.white.opacity(0.10)
    static let shieldBlue = Color(hex: "#4FB5FF")
    static let shieldGreen = Color(hex: "#34C759")
    static let shieldYellow = Color(hex: "#FFD60A")
    static let shieldOrange = Color(hex: "#FF9F0A")
    static let shieldRed = Color(hex: "#FF453A")
}

extension Color {
    init(hex: String) {
        let clean = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: clean).scanHexInt64(&int)
        let r, g, b: UInt64
        switch clean.count {
        case 6:
            (r, g, b) = (int >> 16, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (0, 0, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: 1)
    }
}
