import SwiftUI

struct MetallicStyle: Identifiable, Codable, Hashable, Sendable {
    let id: String
    let name: String
    let colorHexes: [String]

    var colors: [Color] {
        colorHexes.map { Color(hex: $0) }
    }

    static let presets: [MetallicStyle] = [
        MetallicStyle(id: "silver_wave", name: "Silver Wave", colorHexes: ["#C0C0C0", "#A9A9A9", "#D3D3D3"]),
        MetallicStyle(id: "copper_flow", name: "Copper Flow", colorHexes: ["#B87333", "#DA8A67", "#CD7F32"]),
        MetallicStyle(id: "midnight_pearl", name: "Midnight Pearl", colorHexes: ["#1B1B2F", "#2E2E4A", "#4A4A6A"]),
        MetallicStyle(id: "champagne", name: "Champagne Gold", colorHexes: ["#F7E7CE", "#E6D5B8", "#D4C4A8"]),
        MetallicStyle(id: "emerald_lux", name: "Emerald Lux", colorHexes: ["#1B5E20", "#2E7D32", "#43A047"]),
        MetallicStyle(id: "ocean_tide", name: "Ocean Tide", colorHexes: ["#0D47A1", "#1565C0", "#1E88E5"]),
        MetallicStyle(id: "rose_gold", name: "Rose Gold", colorHexes: ["#B76E79", "#E8A0BF", "#C9A0DC"]),
        MetallicStyle(id: "charcoal", name: "Charcoal Steel", colorHexes: ["#2C2C2C", "#3D3D3D", "#4F4F4F"]),
        MetallicStyle(id: "burgundy", name: "Burgundy Silk", colorHexes: ["#6B1D2A", "#8B2252", "#A0344C"]),
    ]
}
