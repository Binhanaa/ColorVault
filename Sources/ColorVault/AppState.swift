import SwiftUI
import Observation
import AppKit

@Observable
public final class AppState {
    public static let shared = AppState()

    // Navigation Tab (0: Harmonies, 1: Contrast & Match, 2: Collections, 3: Vault, 4: Settings)
    public var selectedTab: Int = 0

    // Theme & Appearance (Light / Dark / System)
    public var selectedTheme: AppTheme = .dark
    public var selectedLanguage: AppLanguage = .english

    // In-App Color Picker Toggle
    public var showCustomPicker: Bool = false
    public var pickerHue: Double = 243.0
    public var pickerSaturation: Double = 0.75
    public var pickerLightness: Double = 0.59
    public var pickerHexInput: String = "#4F46E5"

    // Harmony View State
    public var baseHex: String = "#4F46E5"
    public var harmonyResult: HarmonyResult?
    public var harmonyFilter: Int = 0 // 0: All, 1: Duos, 2: Trios, 3: Tetrads

    // Designer & Developer Smart Features
    public var activeShades: [ShadeItem] = []
    public var colorBlindSim: ColorBlindSimulation?
    public var showColorBlindness: Bool = false

    // Pair Matcher State
    public var pairHex1: String = "#2563EB"
    public var pairHex2: String = "#F97316"
    public var pairEvaluation: MatchEvaluation?
    public var activePairPicker: Int = 0 // 0: None, 1: Color A, 2: Color B

    // Curated Collections State
    public var curatedPalettes: [CuratedPalette] = []
    public var curatedCategory: String = "all"

    // History & Vault State
    public var permanentFavorites: [FavoriteRecord] = []
    public var customSavedPalettes: [SavedPaletteRecord] = []
    public var historyRecords: [HistoryRecord] = []
    public var vaultTab: Int = 0 // 0: Favorites, 1: Custom Palettes, 2: History
    public var vaultSearchQuery: String = ""

    // New Palette Creator State
    public var showingNewPaletteDialog: Bool = false
    public var newPaletteTitle: String = ""
    public var newPaletteTag: String = "UI Design"
    public var newPaletteColors: [ColorItem] = []
    public var newPalettePickerHex: String = "#6366F1"
    public var newPaletteShowPicker: Bool = false

    // Settings
    public var defaultCopyFormat: CopyFormat = .hex
    public var enableSound: Bool = false // Strictly silent by default
    public var showShadesSection: Bool = true

    // Subtle Silent Copy Toast
    public var toastMessage: ToastMessage?
    public var copiedHex: String?
    private var toastTimer: Timer?
    private var copyTimer: Timer?

    public init() {
        refreshAll()
    }

    public func refreshAll() {
        refreshHarmonies()
        refreshPairMatch()
        refreshCurated()
        refreshVault()
    }

    public func refreshHarmonies() {
        if let res = RustBridge.shared.generateHarmonies(hex: baseHex) {
            self.harmonyResult = res
        }
        self.activeShades = RustBridge.shared.getShades(hex: baseHex)
        self.colorBlindSim = RustBridge.shared.simulateColorBlind(hex: baseHex)
    }

    public func setBaseHex(_ hex: String) {
        self.baseHex = hex
        self.pickerHexInput = hex
        refreshHarmonies()
        _ = RustBridge.shared.recordColor(hex: hex, source: "harmony_base")
        refreshVault()
    }

    public func refreshPairMatch() {
        if let eval = RustBridge.shared.evaluatePair(hex1: pairHex1, hex2: pairHex2) {
            self.pairEvaluation = eval
        }
    }

    public func updatePair1(_ hex: String) {
        self.pairHex1 = hex
        refreshPairMatch()
        _ = RustBridge.shared.recordColor(hex: hex, source: "pair_matcher")
        refreshVault()
    }

    public func updatePair2(_ hex: String) {
        self.pairHex2 = hex
        refreshPairMatch()
        _ = RustBridge.shared.recordColor(hex: hex, source: "pair_matcher")
        refreshVault()
    }

    public func swapPair() {
        let tH = pairHex1
        pairHex1 = pairHex2
        pairHex2 = tH
        refreshPairMatch()
    }

    public func refreshCurated() {
        self.curatedPalettes = RustBridge.shared.getCuratedPalettes()
    }

    public func refreshVault() {
        self.permanentFavorites = RustBridge.shared.getFavorites()
        self.customSavedPalettes = RustBridge.shared.getSavedPalettes()
        self.historyRecords = RustBridge.shared.getHistory(limit: 100)
    }

    public func isFavorite(hex: String) -> Bool {
        permanentFavorites.contains { $0.hex.caseInsensitiveCompare(hex) == .orderedSame }
    }

    public func toggleFavorite(color: ColorItem) {
        _ = RustBridge.shared.toggleFavorite(hex: color.hex, name: color.name)
        refreshVault()
        let isNowFav = isFavorite(hex: color.hex)
        let msg = isNowFav ? "Added to Favorites ⭐" : "Removed from Favorites"
        showCheckmarkToast(text: "\(msg) (\(color.hex))", hex: color.hex)
    }

    public func createCustomPalette(title: String, category: String, colors: [ColorItem]) {
        _ = RustBridge.shared.savePalette(title: title, category: category, colors: colors)
        refreshVault()
        showCheckmarkToast(text: "Palette saved: \(title)")
    }

    public func addColorToNewPalette(hex: String) {
        if let item = RustBridge.shared.recordColor(hex: hex, source: "custom_palette") {
            if !newPaletteColors.contains(where: { $0.hex.caseInsensitiveCompare(item.hex) == .orderedSame }) {
                newPaletteColors.append(item)
            }
        }
    }

    public func deleteCustomPalette(id: Int64) {
        RustBridge.shared.deleteSavedPalette(id: id)
        refreshVault()
        showCheckmarkToast(text: "Palette deleted")
    }

    public func clearHistory() {
        RustBridge.shared.clearHistory()
        refreshVault()
        showCheckmarkToast(text: "History cleared (Favorites preserved)")
    }

    /// Intelligent Smart Shuffle Palette
    public func shuffleSmartPalette() {
        let sampleHues = [
            "#6366F1", "#EC4899", "#10B981", "#F59E0B", "#06B6D4",
            "#8B5CF6", "#3B82F6", "#EF4444", "#14B8A6", "#84CC16",
            "#D97706", "#4F46E5", "#0EA5E9", "#F43F5E", "#10B981"
        ]
        if let randomHex = sampleHues.randomElement() {
            setBaseHex(randomHex)
            showCheckmarkToast(text: "Generated smart palette for \(randomHex)", hex: randomHex)
        }
    }

    /// Primary Copy Engine: Completely silent, lightweight checkmark
    public func copyColor(_ color: ColorItem, format: CopyFormat? = nil) {
        let targetFormat = format ?? defaultCopyFormat
        let textToCopy = targetFormat.format(color: color)

        let pb = NSPasteboard.general
        pb.clearContents()
        pb.setString(textToCopy, forType: .string)

        if enableSound {
            NSSound.beep()
        }

        // Trigger in-place checkmark on the swatch
        copiedHex = color.hex
        copyTimer?.invalidate()
        copyTimer = Timer.scheduledTimer(withTimeInterval: 0.9, repeats: false) { [weak self] _ in
            self?.copiedHex = nil
        }

        // Show subtle, quick floating checkmark
        showCheckmarkToast(text: "Copied: \(textToCopy)", hex: color.hex)

        // Auto-save in SQLite
        _ = RustBridge.shared.recordColor(hex: color.hex, name: color.name, source: "copy_\(targetFormat.rawValue)")
        refreshVault()
    }

    public func showCheckmarkToast(text: String, hex: String? = nil) {
        toastTimer?.invalidate()
        withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
            toastMessage = ToastMessage(text: text, colorHex: hex)
        }
        toastTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [weak self] _ in
            withAnimation(.easeOut(duration: 0.18)) {
                self?.toastMessage = nil
            }
        }
    }
}
