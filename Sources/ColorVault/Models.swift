import SwiftUI
import AppKit

// MARK: - ColorItem
public struct ColorItem: Identifiable, Codable, Equatable, Hashable {
    public var id: String { hex }
    public let hex: String
    public let r: UInt8
    public let g: UInt8
    public let b: UInt8
    public let h: Double
    public let s: Double
    public let l: Double
    public let name: String
    public let swift_code: String
    public let css_code: String
    public let rgb_code: String

    public var swiftUIColor: Color {
        Color(
            red: Double(r) / 255.0,
            green: Double(g) / 255.0,
            blue: Double(b) / 255.0
        )
    }

    public var nsColor: NSColor {
        NSColor(
            calibratedRed: CGFloat(r) / 255.0,
            green: CGFloat(g) / 255.0,
            blue: CGFloat(b) / 255.0,
            alpha: 1.0
        )
    }

    public var isDark: Bool {
        l < 0.55
    }

    public var textColor: Color {
        isDark ? .white : .black
    }
}

// MARK: - Harmony Group
public struct HarmonyGroup: Identifiable, Codable {
    public let id: String
    public let title: String
    public let title_ar: String
    public let count: Int
    public let description: String
    public let colors: [ColorItem]
}

// MARK: - Harmony Result
public struct HarmonyResult: Codable {
    public let base_color: ColorItem
    public let duos: [HarmonyGroup]
    public let trios: [HarmonyGroup]
    public let tetrads: [HarmonyGroup]
}

// MARK: - Match Evaluation
public struct MatchEvaluation: Codable {
    public let color1: ColorItem
    public let color2: ColorItem
    public let score_pct: Int
    public let relationship: String
    public let relationship_ar: String
    public let contrast_ratio: Double
    public let wcag_rating: String
    public let advice_ar: String
    public let advice_en: String
    public let suggested_trio_color: ColorItem
    public let suggested_tetrad_color: ColorItem
}

// MARK: - Curated Palette
public struct CuratedPalette: Identifiable, Codable {
    public let id: String
    public let title: String
    public let title_ar: String
    public let category: String
    public let tag: String
    public let colors: [ColorItem]
}

// MARK: - History Record
public struct HistoryRecord: Identifiable, Codable {
    public let id: Int64
    public let color: ColorItem
    public let source: String
    public var is_favorite: Bool
    public let created_at: String
    public let use_count: Int64
}

// MARK: - Saved Palette Record
public struct SavedPaletteRecord: Identifiable, Codable {
    public let id: Int64
    public let title: String
    public let category: String
    public let colors: [ColorItem]
    public let is_favorite: Bool
    public let created_at: String
}
