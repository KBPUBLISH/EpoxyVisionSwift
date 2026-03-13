import SwiftUI

struct SolidColorOption: Identifiable, Codable, Hashable, Sendable {
    let id: String
    let name: String
    let hex: String

    var color: Color { Color(hex: hex) }

    static let presets: [SolidColorOption] = [
        SolidColorOption(id: "dove_gray", name: "Dove Gray", hex: "#6D6D6D"),
        SolidColorOption(id: "charcoal", name: "Charcoal", hex: "#333333"),
        SolidColorOption(id: "white", name: "White", hex: "#F5F5F5"),
        SolidColorOption(id: "beige", name: "Beige", hex: "#D4C5A9"),
        SolidColorOption(id: "tan", name: "Tan", hex: "#C4A882"),
        SolidColorOption(id: "terra_cotta", name: "Terra Cotta", hex: "#CC6633"),
        SolidColorOption(id: "navy", name: "Navy", hex: "#1B2A4A"),
        SolidColorOption(id: "forest_green", name: "Forest Green", hex: "#2D5A27"),
        SolidColorOption(id: "burgundy", name: "Burgundy", hex: "#6B1D2A"),
        SolidColorOption(id: "slate_blue", name: "Slate Blue", hex: "#4A6FA5"),
        SolidColorOption(id: "safety_red", name: "Safety Red", hex: "#B22222"),
        SolidColorOption(id: "sand", name: "Sand", hex: "#E0D5B7"),
        SolidColorOption(id: "medium_gray", name: "Medium Gray", hex: "#999999"),
        SolidColorOption(id: "black", name: "Black", hex: "#1A1A1A"),
        SolidColorOption(id: "light_blue", name: "Light Blue", hex: "#87CEEB"),
        SolidColorOption(id: "olive", name: "Olive", hex: "#556B2F"),
    ]
}
