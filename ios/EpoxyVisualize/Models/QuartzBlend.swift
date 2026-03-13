import SwiftUI

struct QuartzBlend: Identifiable, Codable, Hashable, Sendable {
    let id: String
    let name: String
    let colorHexes: [String]

    var colors: [Color] {
        colorHexes.map { Color(hex: $0) }
    }

    static let presets: [QuartzBlend] = [
        QuartzBlend(id: "sandstone", name: "Sandstone", colorHexes: ["#C2B280", "#D2C6A0", "#B8A870"]),
        QuartzBlend(id: "obsidian", name: "Obsidian", colorHexes: ["#1C1C1C", "#2D2D2D", "#3E3E3E"]),
        QuartzBlend(id: "arctic_white", name: "Arctic White", colorHexes: ["#F5F5F5", "#E8E8E8", "#DCDCDC"]),
        QuartzBlend(id: "terra_cotta", name: "Terra Cotta", colorHexes: ["#C04000", "#D2691E", "#E07020"]),
        QuartzBlend(id: "slate_gray", name: "Slate Gray", colorHexes: ["#708090", "#8899A6", "#9AABB8"]),
        QuartzBlend(id: "desert_tan", name: "Desert Tan", colorHexes: ["#D2B48C", "#C8A882", "#BEA078"]),
        QuartzBlend(id: "river_rock", name: "River Rock", colorHexes: ["#5F6B6D", "#7A8B8D", "#95AAAC"]),
        QuartzBlend(id: "canyon_red", name: "Canyon Red", colorHexes: ["#7B3F00", "#8B4513", "#A0522D"]),
        QuartzBlend(id: "coastal", name: "Coastal Blue", colorHexes: ["#4682B4", "#5F9EA0", "#78B4C8"]),
    ]
}
