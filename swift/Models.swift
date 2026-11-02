import SwiftUI
import AppKit

// MARK: - App Theme
public enum AppTheme: String, CaseIterable, Identifiable, Codable {
    case system = "System"
    case dark = "Dark"
    case light = "Light"

    public var id: String { rawValue }

    public var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .dark: return .dark
        case .light: return .light
        }
    }
}

// MARK: - App Language
public enum AppLanguage: String, CaseIterable, Identifiable, Codable {
    case english = "English"
    case arabic = "العربية"

    public var id: String { rawValue }
}

// MARK: - Copy Format
public enum CopyFormat: String, CaseIterable, Identifiable, Codable {
    case hex = "HEX (#4F46E5)"
    case hexNoHash = "HEX Raw (4F46E5)"
    case rgb = "RGB rgb(79, 70, 229)"
    case hsl = "HSL hsl(243, 75%, 60%)"
    case swiftUI = "SwiftUI Color(...)"
    case uiKit = "UIKit UIColor(...)"
    case css = "CSS Variable (--color)"
    case tailwind = "Tailwind CSS ('brand': ...)"
    case jetpackCompose = "Jetpack Compose Color(0xFF...)"
    case flutter = "Flutter Color(0xFF...)"
    case androidXml = "Android XML <color>"

    public var id: String { rawValue }

    public func format(color: ColorItem) -> String {
        switch self {
        case .hex: return color.hex
        case .hexNoHash: return color.hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        case .rgb: return color.rgb_code
        case .hsl: return color.hsl_code
        case .swiftUI: return color.swift_code
        case .uiKit: return color.uikit_code
        case .css: return color.css_code
        case .tailwind: return color.tailwind_code
        case .jetpackCompose: return color.compose_code
        case .flutter: return color.flutter_code
        case .androidXml: return color.android_xml
        }
    }
}

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
    // Developer export codes
    public let swift_code: String
    public let uikit_code: String
    public let css_code: String
    public let rgb_code: String
    public let hsl_code: String
    public let tailwind_code: String
    public let compose_code: String
    public let flutter_code: String
    public let android_xml: String

    public var swiftUIColor: Color {
        Color(
            red: Double(r) / 255.0,
            green: Double(g) / 255.0,
            blue: Double(b) / 255.0
        )
    }

    public var isDark: Bool {
        l < 0.55
    }

    public var textColor: Color {
        isDark ? .white : .black
    }
}

// MARK: - ShadeItem
public struct ShadeItem: Identifiable, Codable {
    public var id: UInt16 { weight }
    public let weight: UInt16
    public let color: ColorItem
}

// MARK: - ColorBlindSimulation
public struct ColorBlindSimulation: Codable {
    public let normal: String
    public let protanopia: String
    public let deuteranopia: String
    public let tritanopia: String
    public let achromatopsia: String
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
    public let auto_fixed_color2_aa: ColorItem
    public let auto_fixed_color2_aaa: ColorItem
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

// MARK: - Favorite Record (Permanent in SQLite)
public struct FavoriteRecord: Identifiable, Codable {
    public var id: String { hex }
    public let hex: String
    public let color: ColorItem
    public let created_at: String
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

// MARK: - Color Extensions
public extension Color {
    init(hex: String) {
        let clean = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: clean).scanHexInt64(&int)
        let r, g, b: UInt64
        switch clean.count {
        case 3: // RGB (12-bit)
            (r, g, b) = ((int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (r, g, b) = (int >> 16, int >> 8 & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (128, 128, 128)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255.0,
            green: Double(g) / 255.0,
            blue: Double(b) / 255.0,
            opacity: 1.0
        )
    }

    static func hslToRgb(h: Double, s: Double, l: Double) -> (r: Int, g: Int, b: Int) {
        let hNorm = (h.truncatingRemainder(dividingBy: 360.0) + 360.0).truncatingRemainder(dividingBy: 360.0) / 360.0
        let c = (1.0 - abs(2.0 * l - 1.0)) * s
        let x = c * (1.0 - abs((hNorm * 6.0).truncatingRemainder(dividingBy: 2.0) - 1.0))
        let m = l - c / 2.0

        var rPrime = 0.0
        var gPrime = 0.0
        var bPrime = 0.0

        let segment = Int(hNorm * 6.0) % 6
        switch segment {
        case 0: (rPrime, gPrime, bPrime) = (c, x, 0.0)
        case 1: (rPrime, gPrime, bPrime) = (x, c, 0.0)
        case 2: (rPrime, gPrime, bPrime) = (0.0, c, x)
        case 3: (rPrime, gPrime, bPrime) = (0.0, x, c)
        case 4: (rPrime, gPrime, bPrime) = (x, 0.0, c)
        case 5: (rPrime, gPrime, bPrime) = (c, 0.0, x)
        default: break
        }

        let r = max(0, min(255, Int(round((rPrime + m) * 255.0))))
        let g = max(0, min(255, Int(round((gPrime + m) * 255.0))))
        let b = max(0, min(255, Int(round((bPrime + m) * 255.0))))
        return (r, g, b)
    }

    static func fromHsl(h: Double, s: Double, l: Double) -> Color {
        let (r, g, b) = hslToRgb(h: h, s: s, l: l)
        return Color(.sRGB, red: Double(r) / 255.0, green: Double(g) / 255.0, blue: Double(b) / 255.0, opacity: 1.0)
    }

    var isDarkColor: Bool {
        let ns = NSColor(self).usingColorSpace(.sRGB) ?? NSColor.black
        let lum = 0.2126 * ns.redComponent + 0.7152 * ns.greenComponent + 0.0722 * ns.blueComponent
        return lum < 0.5
    }
}
