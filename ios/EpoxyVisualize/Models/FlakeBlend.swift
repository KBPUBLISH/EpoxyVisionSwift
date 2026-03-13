import SwiftUI

struct FlakeBlend: Identifiable, Codable, Hashable, Sendable {
    let id: String
    let name: String
    let colorHexes: [String]

    var colors: [Color] {
        colorHexes.map { Color(hex: $0) }
    }

    static let presets: [FlakeBlend] = [
        FlakeBlend(id: "midnight", name: "Midnight", colorHexes: ["#1a1a2e", "#16213e", "#0f3460", "#533483"]),
        FlakeBlend(id: "sahara", name: "Sahara", colorHexes: ["#d4a574", "#c4956a", "#b08968", "#8B7355"]),
        FlakeBlend(id: "glacier", name: "Glacier", colorHexes: ["#a8d8ea", "#88c8d8", "#6bb8c8", "#4a98a8"]),
        FlakeBlend(id: "autumn", name: "Autumn Leaf", colorHexes: ["#c0392b", "#e67e22", "#f1c40f", "#8B4513"]),
        FlakeBlend(id: "ocean", name: "Ocean Breeze", colorHexes: ["#1a5276", "#2e86c1", "#5dade2", "#85c1e9"]),
        FlakeBlend(id: "granite", name: "Granite", colorHexes: ["#5d6d7e", "#808b96", "#aab7b8", "#d5d8dc"]),
        FlakeBlend(id: "forest", name: "Forest Floor", colorHexes: ["#1e4d2b", "#2d6a4f", "#40916c", "#52b788"]),
        FlakeBlend(id: "volcano", name: "Volcano", colorHexes: ["#641E16", "#922B21", "#C0392B", "#E74C3C"]),
        FlakeBlend(id: "pearl", name: "Pearl White", colorHexes: ["#f8f9fa", "#e9ecef", "#dee2e6", "#ced4da"]),
        FlakeBlend(id: "storm", name: "Storm Cloud", colorHexes: ["#2c3e50", "#34495e", "#7f8c8d", "#95a5a6"]),
        FlakeBlend(id: "coral", name: "Coral Reef", colorHexes: ["#ff6b6b", "#ee5a24", "#f8b739", "#ffc048"]),
        FlakeBlend(id: "arctic", name: "Arctic Ice", colorHexes: ["#dfe6e9", "#b2bec3", "#74b9ff", "#0984e3"]),
    ]
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
