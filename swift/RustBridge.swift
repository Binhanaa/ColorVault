import Foundation

// C-FFI Declarations
@_silgen_name("cv_init_db")
func cv_init_db() -> Int32

@_silgen_name("cv_record_color")
func cv_record_color(_ hex: UnsafePointer<CChar>, _ name: UnsafePointer<CChar>, _ source: UnsafePointer<CChar>) -> UnsafeMutablePointer<CChar>

@_silgen_name("cv_generate_harmonies")
func cv_generate_harmonies(_ hex: UnsafePointer<CChar>) -> UnsafeMutablePointer<CChar>

@_silgen_name("cv_evaluate_pair")
func cv_evaluate_pair(_ hex1: UnsafePointer<CChar>, _ hex2: UnsafePointer<CChar>) -> UnsafeMutablePointer<CChar>

@_silgen_name("cv_get_shades")
func cv_get_shades(_ hex: UnsafePointer<CChar>) -> UnsafeMutablePointer<CChar>

@_silgen_name("cv_simulate_colorblind")
func cv_simulate_colorblind(_ hex: UnsafePointer<CChar>) -> UnsafeMutablePointer<CChar>

@_silgen_name("cv_get_curated_palettes")
func cv_get_curated_palettes() -> UnsafeMutablePointer<CChar>

@_silgen_name("cv_get_history")
func cv_get_history(_ limit: Int32) -> UnsafeMutablePointer<CChar>

@_silgen_name("cv_toggle_favorite")
func cv_toggle_favorite(_ hex: UnsafePointer<CChar>, _ name: UnsafePointer<CChar>) -> Int32

@_silgen_name("cv_get_favorites")
func cv_get_favorites() -> UnsafeMutablePointer<CChar>

@_silgen_name("cv_save_palette")
func cv_save_palette(_ title: UnsafePointer<CChar>, _ category: UnsafePointer<CChar>, _ colorsJson: UnsafePointer<CChar>) -> Int64

@_silgen_name("cv_delete_saved_palette")
func cv_delete_saved_palette(_ id: Int64) -> Int32

@_silgen_name("cv_get_saved_palettes")
func cv_get_saved_palettes() -> UnsafeMutablePointer<CChar>

@_silgen_name("cv_clear_history")
func cv_clear_history() -> Int32

@_silgen_name("cv_free_string")
func cv_free_string(_ ptr: UnsafeMutablePointer<CChar>)

public final class RustBridge {
    public static let shared = RustBridge()

    private init() {
        _ = cv_init_db()
    }

    private func parseAndFree<T: Decodable>(_ ptr: UnsafeMutablePointer<CChar>?) -> T? {
        guard let ptr = ptr else { return nil }
        defer { cv_free_string(ptr) }
        let jsonStr = String(cString: ptr)
        guard let data = jsonStr.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    @discardableResult
    public func recordColor(hex: String, name: String = "", source: String = "app") -> ColorItem? {
        let ptr = cv_record_color(hex, name, source)
        return parseAndFree(ptr)
    }

    public func generateHarmonies(hex: String) -> HarmonyResult? {
        let ptr = cv_generate_harmonies(hex)
        return parseAndFree(ptr)
    }

    public func evaluatePair(hex1: String, hex2: String) -> MatchEvaluation? {
        let ptr = cv_evaluate_pair(hex1, hex2)
        return parseAndFree(ptr)
    }

    public func getShades(hex: String) -> [ShadeItem] {
        let ptr = cv_get_shades(hex)
        return parseAndFree(ptr) ?? []
    }

    public func simulateColorBlind(hex: String) -> ColorBlindSimulation? {
        let ptr = cv_simulate_colorblind(hex)
        return parseAndFree(ptr)
    }

    public func getCuratedPalettes() -> [CuratedPalette] {
        let ptr = cv_get_curated_palettes()
        return parseAndFree(ptr) ?? []
    }

    public func getHistory(limit: Int = 100) -> [HistoryRecord] {
        let ptr = cv_get_history(Int32(limit))
        return parseAndFree(ptr) ?? []
    }

    public func toggleFavorite(hex: String, name: String = "") -> Bool {
        return cv_toggle_favorite(hex, name) == 1
    }

    public func getFavorites() -> [FavoriteRecord] {
        let ptr = cv_get_favorites()
        return parseAndFree(ptr) ?? []
    }

    public func savePalette(title: String, category: String, colors: [ColorItem]) -> Int64 {
        guard let data = try? JSONEncoder().encode(colors),
              let jsonStr = String(data: data, encoding: .utf8) else {
            return -1
        }
        return cv_save_palette(title, category, jsonStr)
    }

    public func deleteSavedPalette(id: Int64) {
        _ = cv_delete_saved_palette(id)
    }

    public func getSavedPalettes() -> [SavedPaletteRecord] {
        let ptr = cv_get_saved_palettes()
        return parseAndFree(ptr) ?? []
    }

    public func clearHistory() {
        _ = cv_clear_history()
    }
}
