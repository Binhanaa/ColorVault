import SwiftUI
import AppKit

public struct HistoryVaultView: View {
    @Bindable var state: AppState = AppState.shared

    public init(state: AppState = AppState.shared) {
        self.state = state
    }

    public var filteredHistory: [HistoryRecord] {
        if state.vaultSearchQuery.isEmpty {
            return state.historyRecords
        }
        return state.historyRecords.filter { rec in
            rec.color.hex.localizedCaseInsensitiveContains(state.vaultSearchQuery) ||
            rec.color.name.localizedCaseInsensitiveContains(state.vaultSearchQuery) ||
            rec.source.localizedCaseInsensitiveContains(state.vaultSearchQuery)
        }
    }

    var favTitle: String {
        state.selectedLanguage == .arabic ? "المفضلة ⭐ (\(state.permanentFavorites.count))" : "Favorites ⭐ (\(state.permanentFavorites.count))"
    }
    var palettesTitle: String {
        state.selectedLanguage == .arabic ? "المجموعات المخصصة (\(state.customSavedPalettes.count))" : "Custom Palettes (\(state.customSavedPalettes.count))"
    }
    var historyTitle: String {
        state.selectedLanguage == .arabic ? "سجل الألوان (\(state.historyRecords.count))" : "History Log (\(state.historyRecords.count))"
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Header Controls
            VStack(spacing: 8) {
                HStack {
                    Picker("", selection: $state.vaultTab) {
                        Text(favTitle).tag(0)
                        Text(palettesTitle).tag(1)
                        Text(historyTitle).tag(2)
                    }
                    .pickerStyle(SegmentedPickerStyle())

                    Spacer()

                    if state.vaultTab == 1 {
                        Button(action: {
                            openNewPaletteModal()
                        }) {
                            HStack(spacing: 3) {
                                Image(systemName: "plus")
                                Text(state.selectedLanguage == .arabic ? "مجموعة جديدة" : "New Palette")
                            }
                            .font(.system(size: 10, weight: .bold))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Capsule().fill(Color.accentColor))
                            .foregroundColor(.white)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .focusable(false)
                        .help("Create a new custom palette")
                    } else if state.vaultTab == 2 {
                        Menu {
                            Button(state.selectedLanguage == .arabic ? "تصدير السجل كـ JSON" : "Export History as JSON") {
                                exportHistoryAsJSON()
                            }
                            Button(state.selectedLanguage == .arabic ? "نسخ قائمة HEX" : "Copy HEX List") {
                                exportHexList()
                            }
                            Divider()
                            Button(role: .destructive, action: {
                                state.clearHistory()
                            }) {
                                Text(state.selectedLanguage == .arabic ? "مسح السجل (يحفظ المفضلة)" : "Clear History (Preserves Favorites)")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                        }
                        .menuStyle(BorderlessButtonMenuStyle())
                        .frame(width: 24)
                    }
                }

                if state.vaultTab == 2 {
                    HStack(spacing: 5) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                        TextField(state.selectedLanguage == .arabic ? "بحث في السجل بالاسم أو HEX..." : "Filter history by name or HEX...", text: $state.vaultSearchQuery)
                            .textFieldStyle(PlainTextFieldStyle())
                            .font(.system(size: 10.5))
                    }
                    .padding(5)
                    .background(RoundedRectangle(cornerRadius: 6).fill(Color.primary.opacity(0.06)))
                }
            }
            .padding(10)
            .background(Color(NSColor.controlBackgroundColor))

            Divider()

            // Modal / Inline Sheet for New Palette Creation
            if state.showingNewPaletteDialog {
                newPaletteCreatorBox
            }

            // Content List
            ScrollView {
                if state.vaultTab == 0 {
                    // TAB 0: Permanent Favorites (NEVER DISAPPEARS!)
                    if state.permanentFavorites.isEmpty {
                        emptyState(
                            icon: "star",
                            title: "No Favorites Saved Yet",
                            desc: "Click the ⭐ star icon on any color swatch to save it permanently in your SQLite database."
                        )
                    } else {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4), spacing: 8) {
                            ForEach(state.permanentFavorites) { fav in
                                ColorCard(
                                    color: fav.color,
                                    isCompact: false,
                                    onSelectAsBase: { item in
                                        state.setBaseHex(item.hex)
                                        state.selectedTab = 0
                                    }
                                )
                            }
                        }
                        .padding(12)
                    }
                } else if state.vaultTab == 1 {
                    // TAB 1: Custom User Palettes
                    if state.customSavedPalettes.isEmpty {
                        emptyState(
                            icon: "folder.badge.plus",
                            title: "No Custom Palettes",
                            desc: "Click '+ New' above to create and name your custom palette with chosen colors."
                        )
                    } else {
                        VStack(spacing: 10) {
                            ForEach(state.customSavedPalettes) { pal in
                                HStack {
                                    VStack(alignment: .leading, spacing: 6) {
                                        PaletteRow(
                                            title: pal.title,
                                            subtitle: "\(pal.category) • \(pal.created_at.prefix(10))",
                                            colors: pal.colors,
                                            onSelectAsBase: { item in
                                                state.setBaseHex(item.hex)
                                                state.selectedTab = 0
                                            }
                                        )
                                    }

                                    Button(action: {
                                        state.deleteCustomPalette(id: pal.id)
                                    }) {
                                        Image(systemName: "trash")
                                            .font(.system(size: 10))
                                            .foregroundColor(.red.opacity(0.7))
                                            .padding(6)
                                            .background(Circle().fill(Color.red.opacity(0.08)))
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .focusable(false)
                                    .help("Delete palette")
                                }
                            }
                        }
                        .padding(12)
                    }
                } else {
                    // TAB 2: History Log
                    if filteredHistory.isEmpty {
                        emptyState(
                            icon: "clock.arrow.circlepath",
                            title: "No Color History",
                            desc: "Every color you sample, click, or test will be automatically logged in SQLite."
                        )
                    } else {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
                            ForEach(filteredHistory) { rec in
                                historyCard(rec: rec)
                            }
                        }
                        .padding(12)
                    }
                }
            }
        }
        .onAppear {
            state.refreshVault()
        }
    }

    private var newPaletteCreatorBox: some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack {
                Text(state.selectedLanguage == .arabic ? "إنشاء مجموعة ألوان مخصصة" : "Create Custom Palette")
                    .font(.system(size: 11.5, weight: .bold))
                Spacer()
                Button(state.selectedLanguage == .arabic ? "إلغاء" : "Cancel") {
                    state.showingNewPaletteDialog = false
                    state.newPaletteShowPicker = false
                }
                .font(.system(size: 10))
                .buttonStyle(PlainButtonStyle())
                .focusable(false)
            }

            HStack(spacing: 8) {
                TextField(state.selectedLanguage == .arabic ? "اسم المجموعة (مثل: هوية براند)" : "Palette Name (e.g. Brand Identity)", text: $state.newPaletteTitle)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(5.5)
                    .background(RoundedRectangle(cornerRadius: 6).fill(Color.primary.opacity(0.06)))
                    .font(.system(size: 11))

                TextField(state.selectedLanguage == .arabic ? "التصنيف (UI)" : "Tag (e.g. UI Design)", text: $state.newPaletteTag)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(5.5)
                    .background(RoundedRectangle(cornerRadius: 6).fill(Color.primary.opacity(0.06)))
                    .frame(width: 95)
                    .font(.system(size: 11))
            }

            // Colors currently added to this palette
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(state.newPaletteColors) { col in
                        ZStack(alignment: .topTrailing) {
                            RoundedRectangle(cornerRadius: 5)
                                .fill(col.swiftUIColor)
                                .frame(width: 30, height: 30)
                                .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.primary.opacity(0.15), lineWidth: 0.8))

                            Button(action: {
                                state.newPaletteColors.removeAll { $0.hex == col.hex }
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 9))
                                    .foregroundColor(.white)
                                    .background(Circle().fill(Color.black.opacity(0.6)))
                            }
                            .buttonStyle(PlainButtonStyle())
                            .focusable(false)
                            .padding(1)
                        }
                    }

                    if state.newPaletteColors.isEmpty {
                        Text(state.selectedLanguage == .arabic ? "أضف ألوانًا للمجموعة من الخيارات بالأسفل" : "Add colors to this collection below")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                            .padding(.leading, 4)
                    }
                }
            }

            // In-app Color Picker for Palette Builder
            if state.newPaletteShowPicker {
                CustomColorPickerView(selectedHex: $state.newPalettePickerHex)
                    .padding(.top, 2)

                HStack {
                    Button(action: {
                        state.addColorToNewPalette(hex: state.newPalettePickerHex)
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "plus.circle.fill")
                            Text(state.selectedLanguage == .arabic ? "إضافة اللون المحدد (\(state.newPalettePickerHex))" : "Add Selected Color (\(state.newPalettePickerHex))")
                        }
                        .font(.system(size: 10, weight: .bold))
                        .padding(.horizontal, 9)
                        .padding(.vertical, 4.5)
                        .background(Capsule().fill(Color.accentColor))
                        .foregroundColor(.white)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .focusable(false)

                    Spacer()
                }
            }

            // Bottom action row
            HStack(spacing: 6) {
                // Toggle In-App Color Adjuster
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        state.newPaletteShowPicker.toggle()
                    }
                }) {
                    HStack(spacing: 3) {
                        Image(systemName: state.newPaletteShowPicker ? "chevron.up" : "slider.horizontal.3")
                        Text(state.selectedLanguage == .arabic ? "اختيار لون خاص" : "Color Picker")
                    }
                    .font(.system(size: 9.5, weight: .semibold))
                    .padding(.horizontal, 7)
                    .padding(.vertical, 4)
                    .background(RoundedRectangle(cornerRadius: 5).fill(Color.primary.opacity(0.08)))
                    .foregroundColor(.primary)
                }
                .buttonStyle(PlainButtonStyle())
                .focusable(false)

                // Eyedropper directly into palette
                EyedropperButton(onColorPicked: { picked in
                    state.addColorToNewPalette(hex: picked)
                })

                // Add Current Base Color Button
                Button(action: {
                    if let base = state.harmonyResult?.base_color {
                        state.addColorToNewPalette(hex: base.hex)
                    }
                }) {
                    HStack(spacing: 2) {
                        Image(systemName: "plus.circle")
                        Text(state.selectedLanguage == .arabic ? "إضافة الأساس (\(state.baseHex))" : "Add Base (\(state.baseHex))")
                    }
                    .font(.system(size: 9.5, weight: .semibold))
                    .padding(.horizontal, 7)
                    .padding(.vertical, 4)
                    .background(RoundedRectangle(cornerRadius: 5).fill(Color.accentColor.opacity(0.12)))
                    .foregroundColor(.accentColor)
                }
                .buttonStyle(PlainButtonStyle())
                .focusable(false)

                Spacer()

                Button(action: {
                    saveCustomPalette()
                }) {
                    HStack(spacing: 3) {
                        Image(systemName: "checkmark")
                        Text(state.selectedLanguage == .arabic ? "حفظ المجموعة" : "Save Palette")
                    }
                    .font(.system(size: 10, weight: .bold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4.5)
                    .background(Capsule().fill(Color.green))
                    .foregroundColor(.white)
                }
                .buttonStyle(PlainButtonStyle())
                .focusable(false)
                .disabled(state.newPaletteTitle.trimmingCharacters(in: .whitespaces).isEmpty || state.newPaletteColors.isEmpty)
            }
        }
        .padding(10)
        .background(Color(NSColor.controlBackgroundColor).opacity(0.95))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.accentColor.opacity(0.3), lineWidth: 1))
        .padding(10)
    }

    private func openNewPaletteModal() {
        state.newPaletteTitle = ""
        state.newPaletteTag = "UI Design"
        state.newPaletteColors = []
        state.newPaletteShowPicker = false
        if let base = state.harmonyResult?.base_color {
            state.newPaletteColors.append(base)
        }
        state.showingNewPaletteDialog = true
    }

    private func saveCustomPalette() {
        state.createCustomPalette(
            title: state.newPaletteTitle.trimmingCharacters(in: .whitespaces),
            category: state.newPaletteTag.trimmingCharacters(in: .whitespaces),
            colors: state.newPaletteColors
        )
        state.showingNewPaletteDialog = false
    }

    private func historyCard(rec: HistoryRecord) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 7)
                    .fill(rec.color.swiftUIColor)
                    .frame(height: 46)
                    .overlay(RoundedRectangle(cornerRadius: 7).stroke(Color.primary.opacity(0.1), lineWidth: 0.8))

                Button(action: {
                    state.toggleFavorite(color: rec.color)
                }) {
                    Image(systemName: state.isFavorite(hex: rec.color.hex) ? "star.fill" : "star")
                        .font(.system(size: 8.5))
                        .foregroundColor(state.isFavorite(hex: rec.color.hex) ? .yellow : .white.opacity(0.75))
                        .padding(3.5)
                        .background(Circle().fill(Color.black.opacity(0.55)))
                }
                .buttonStyle(PlainButtonStyle())
                .focusable(false)
                .padding(2.5)
            }

            Text(rec.color.hex)
                .font(.system(size: 9.5, weight: .bold, design: .monospaced))
                .foregroundColor(.primary)

            HStack {
                Text(rec.color.name)
                    .font(.system(size: 8.5))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                Spacer()
                Text("×\(rec.use_count)")
                    .font(.system(size: 7.5, weight: .bold))
                    .foregroundColor(.secondary)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            state.copyColor(rec.color)
        }
        .contextMenu {
            Button("Copy (\(state.defaultCopyFormat.rawValue))") {
                state.copyColor(rec.color)
            }
            Button("Set as Base Harmony Color") {
                state.setBaseHex(rec.color.hex)
                state.selectedTab = 0
            }
            Button(state.isFavorite(hex: rec.color.hex) ? "Remove from Favorites" : "Add to Permanent Favorites ⭐") {
                state.toggleFavorite(color: rec.color)
            }
        }
    }

    private func emptyState(icon: String, title: String, desc: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(.secondary.opacity(0.6))
            Text(title)
                .font(.system(size: 11.5, weight: .bold))
                .foregroundColor(.primary)
            Text(desc)
                .font(.system(size: 10))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
        .frame(maxWidth: .infinity)
        .padding(36)
    }

    private func exportHistoryAsJSON() {
        guard let data = try? JSONEncoder().encode(state.historyRecords),
              let jsonStr = String(data: data, encoding: .utf8) else { return }
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(jsonStr, forType: .string)
        state.showCheckmarkToast(text: "Copied history as JSON")
    }

    private func exportHexList() {
        let hexes = state.historyRecords.map { "\($0.color.hex) - \($0.color.name)" }.joined(separator: "\n")
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(hexes, forType: .string)
        state.showCheckmarkToast(text: "Copied HEX list to clipboard")
    }
}
