import SwiftUI
import AppKit

public struct HistoryVaultView: View {
    public var onSelectAsBase: (ColorItem) -> Void
    public var onToast: (String, String?) -> Void

    @State private var history: [HistoryRecord] = []
    @State private var savedPalettes: [SavedPaletteRecord] = []
    @State private var vaultTab: Int = 0 // 0: Colors, 1: Saved Palettes, 2: Favorites
    @State private var filterQuery: String = ""

    public var filteredHistory: [HistoryRecord] {
        history.filter { rec in
            if vaultTab == 2 && !rec.is_favorite { return false }
            if filterQuery.isEmpty { return true }
            return rec.color.hex.localizedCaseInsensitiveContains(filterQuery) ||
                rec.color.name.localizedCaseInsensitiveContains(filterQuery) ||
                rec.source.localizedCaseInsensitiveContains(filterQuery)
        }
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Header Controls
            VStack(spacing: 10) {
                HStack {
                    Picker("", selection: $vaultTab) {
                        Text("سجل الألوان (\(history.count))").tag(0)
                        Text("المجموعات (\(savedPalettes.count))").tag(1)
                        Text("المفضلة ⭐").tag(2)
                    }
                    .pickerStyle(SegmentedPickerStyle())

                    Spacer()

                    Menu {
                        Button("تصدير السجل بتنسيق JSON") {
                            exportHistoryAsJSON()
                        }
                        Button("تصدير كأكواد HEX") {
                            exportHexList()
                        }
                        Divider()
                        Button(role: .destructive, action: clearHistory) {
                            Text("مسح السجل (باستثناء المفضلة)")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    .menuStyle(BorderlessButtonMenuStyle())
                    .frame(width: 30)
                }

                if vaultTab != 1 {
                    HStack(spacing: 6) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        TextField("تصفية الألوان بالاسم أو الكود...", text: $filterQuery)
                            .textFieldStyle(PlainTextInputStyle())
                    }
                    .padding(6)
                    .background(RoundedRectangle(cornerRadius: 8).fill(Color.primary.opacity(0.06)))
                }
            }
            .padding(12)
            .background(Color(NSColor.controlBackgroundColor))

            Divider()

            // Content List
            ScrollView {
                if vaultTab == 1 {
                    // Saved Palettes
                    VStack(spacing: 12) {
                        if savedPalettes.isEmpty {
                            emptyState(text: "لا توجد مجموعات محفوظة حالياً.\nيمكنك حفظ أي مجموعة بالضغط على زر الحفظ 🔖 في أي شاشة.")
                        } else {
                            ForEach(savedPalettes) { pal in
                                PaletteRow(
                                    title: pal.title,
                                    subtitle: "\(pal.category) • \(pal.created_at.prefix(10))",
                                    colors: pal.colors,
                                    onSelectAsBase: onSelectAsBase,
                                    onToast: onToast
                                )
                            }
                        }
                    }
                    .padding(14)
                } else {
                    // Color Grid
                    if filteredHistory.isEmpty {
                        emptyState(text: "لا توجد ألوان مسجلة حتى الآن.\nأي لون تختاره أو تلتقطه بالقطارة سيتحفظ تلقائياً هنا في قاعدة البيانات.")
                    } else {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 3), spacing: 10) {
                            ForEach(filteredHistory) { rec in
                                historyCard(rec: rec)
                            }
                        }
                        .padding(14)
                    }
                }
            }
        }
        .onAppear {
            refreshData()
        }
    }

    private func historyCard(rec: HistoryRecord) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(rec.color.swiftUIColor)
                    .frame(height: 54)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.primary.opacity(0.1), lineWidth: 1))

                Button(action: {
                    toggleFavorite(rec: rec)
                }) {
                    Image(systemName: rec.is_favorite ? "star.fill" : "star")
                        .font(.system(size: 11))
                        .foregroundColor(rec.is_favorite ? .yellow : .white.opacity(0.7))
                        .padding(4)
                        .background(Circle().fill(Color.black.opacity(0.5)))
                }
                .buttonStyle(PlainButtonStyle())
                .padding(4)
            }

            Text(rec.color.hex)
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundColor(.primary)

            HStack {
                Text(rec.color.name)
                    .font(.system(size: 9))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                Spacer()
                Text("×\(rec.use_count)")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(.secondary)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(rec.color.hex, forType: .string)
            NSSound.beep()
            onToast("تم نسخ: \(rec.color.hex)", rec.color.hex)
        }
        .contextMenu {
            Button("نسخ HEX") {
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(rec.color.hex, forType: .string)
                onToast("تم النسخ: \(rec.color.hex)", rec.color.hex)
            }
            Button("جعله اللون الأساسي للهارموني") {
                onSelectAsBase(rec.color)
            }
            Button(rec.is_favorite ? "إزالة من المفضلة" : "إضافة للمفضلة") {
                toggleFavorite(rec: rec)
            }
        }
    }

    private func emptyState(text: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "archivebox")
                .font(.system(size: 36))
                .foregroundColor(.secondary)
            Text(text)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
    }

    private func toggleFavorite(rec: HistoryRecord) {
        let isFav = RustBridge.shared.toggleFavorite(hex: rec.color.hex)
        onToast(isFav ? "تمت الإضافة إلى المفضلة" : "تمت الإزالة من المفضلة", rec.color.hex)
        refreshData()
    }

    private func clearHistory() {
        RustBridge.shared.clearHistory()
        refreshData()
        onToast("تم مسح السجل", nil)
    }

    private func exportHistoryAsJSON() {
        guard let data = try? JSONEncoder().encode(history),
              let jsonStr = String(data: data, encoding: .utf8) else { return }
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(jsonStr, forType: .string)
        onToast("تم نسخ السجل بتنسيق JSON للحافظة", nil)
    }

    private func exportHexList() {
        let hexes = history.map { "\($0.color.hex) - \($0.color.name)" }.joined(separator: "\n")
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(hexes, forType: .string)
        onToast("تم نسخ قائمة الألوان للحافظة", nil)
    }

    private func refreshData() {
        history = RustBridge.shared.getHistory(limit: 100)
        savedPalettes = RustBridge.shared.getSavedPalettes()
    }
}
