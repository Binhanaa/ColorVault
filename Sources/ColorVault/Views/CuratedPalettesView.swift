import SwiftUI

public struct CuratedPalettesView: View {
    public var onSelectAsBase: (ColorItem) -> Void
    public var onToast: (String, String?) -> Void

    @State private var palettes: [CuratedPalette] = []
    @State private var filterCategory: String = "all"
    @State private var searchText: String = ""

    public var filteredPalettes: [CuratedPalette] {
        palettes.filter { p in
            let matchesCategory = filterCategory == "all" || p.category == filterCategory
            let matchesSearch = searchText.isEmpty ||
                p.title.localizedCaseInsensitiveContains(searchText) ||
                p.title_ar.localizedCaseInsensitiveContains(searchText) ||
                p.tag.localizedCaseInsensitiveContains(searchText)
            return matchesCategory && matchesSearch
        }
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                // Search bar & Filter
                HStack(spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        TextField("بحث في المجموعات والأنماط...", text: $searchText)
                            .textFieldStyle(PlainTextInputStyle())
                    }
                    .padding(6)
                    .background(RoundedRectangle(cornerRadius: 8).fill(Color.primary.opacity(0.06)))

                    // Category Filter Picker
                    Picker("", selection: $filterCategory) {
                        Text("الكل").tag("all")
                        Text("ثنائيات (2)").tag("duo")
                        Text("ثلاثيات (3)").tag("trio")
                        Text("رباعيات (4)").tag("tetrad")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .frame(width: 200)
                }

                // Palettes List
                ForEach(filteredPalettes) { pal in
                    PaletteRow(
                        title: pal.title_ar,
                        subtitle: "\(pal.title) • \(pal.tag)",
                        colors: pal.colors,
                        onSelectAsBase: onSelectAsBase,
                        onToast: onToast
                    )
                }

                if filteredPalettes.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "paintpalette")
                            .font(.system(size: 32))
                            .foregroundColor(.secondary)
                        Text("لا توجد مجموعات تطابق البحث")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(40)
                }
            }
            .padding(14)
        }
        .onAppear {
            palettes = RustBridge.shared.getCuratedPalettes()
        }
    }
}
