import SwiftUI

nonisolated enum EpoxyType: String, CaseIterable, Identifiable, Codable, Sendable {
    case flake = "Flake"
    case metallic = "Metallic"
    case quartz = "Quartz"
    case solidColor = "Solid Color"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .flake: return "sparkles"
        case .metallic: return "diamond.fill"
        case .quartz: return "cube.fill"
        case .solidColor: return "paintbrush.fill"
        }
    }

    var subtitle: String {
        switch self {
        case .flake: return "Decorative chip blends"
        case .metallic: return "Pearlescent finishes"
        case .quartz: return "Natural stone textures"
        case .solidColor: return "Clean single-tone coats"
        }
    }

    var previewColors: [Color] {
        switch self {
        case .flake: return [Color(red: 0.2, green: 0.2, blue: 0.3), Color(red: 0.4, green: 0.15, blue: 0.15)]
        case .metallic: return [Color(red: 0.3, green: 0.25, blue: 0.4), Color(red: 0.15, green: 0.2, blue: 0.35)]
        case .quartz: return [Color(red: 0.35, green: 0.3, blue: 0.25), Color(red: 0.25, green: 0.2, blue: 0.18)]
        case .solidColor: return [Color(red: 0.15, green: 0.15, blue: 0.2), Color(red: 0.2, green: 0.12, blue: 0.12)]
        }
    }
}
