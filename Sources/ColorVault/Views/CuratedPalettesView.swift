import SwiftUI

public struct CuratedPalettesView: View {
    @Bindable var state: AppState = AppState.shared

    var currentCategories: [(id: String, title: String, count: String)] {
        if state.selectedLanguage == .arabic {
            return [
                ("all", "الكل", "15"),
                ("duo", "ثنائيات (2)", "5"),
                ("trio", "ثلاثيات (3)", "5"),
                ("tetrad", "رباعيات (4)", "5")
            ]
        } else {
            return [
                ("all", "All Sets", "15"),
                ("duo", "Duos (2)", "5"),
                ("trio", "Trios (3)", "5"),
                ("tetrad", "Tetrads (4)", "5")
            ]
        }
    }

    public init(state: AppState = AppState.shared) {
        self.state = state
    }

    public var filteredPalettes: [CuratedPalette] {
        if state.curatedCategory == "all" {
            return state.curatedPalettes
        }
        return state.curatedPalettes.filter { $0.category == state.curatedCategory }
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                // Symmetrical Full-Width Category Filter Bar (No cramped search bar!)
                HStack(spacing: 6) {
                    ForEach(currentCategories, id: \.id) { cat in
                        Button(action: {
                            state.curatedCategory = cat.id
                        }) {
                            HStack(spacing: 4) {
                                Text(cat.title)
                                    .font(.system(size: 10.5, weight: state.curatedCategory == cat.id ? .bold : .medium))
                                Text(cat.count)
                                    .font(.system(size: 8.5, weight: .bold))
                                    .foregroundColor(state.curatedCategory == cat.id ? .white.opacity(0.85) : .secondary)
                                    .padding(.horizontal, 3.5)
                                    .padding(.vertical, 1)
                                    .background(Capsule().fill(state.curatedCategory == cat.id ? Color.white.opacity(0.2) : Color.primary.opacity(0.06)))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(state.curatedCategory == cat.id ? Color.accentColor : Color.white.opacity(0.06))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(state.curatedCategory == cat.id ? Color.accentColor.opacity(0.8) : Color.white.opacity(0.08), lineWidth: 0.8)
                            )
                            .foregroundColor(state.curatedCategory == cat.id ? .white : .primary)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                        .focusable(false)
                    }
                }
                .padding(.horizontal, 1)

                // Palettes List
                ForEach(filteredPalettes) { pal in
                    PaletteRow(
                        title: pal.title,
                        subtitle: "\(pal.tag) • \(pal.title_ar)",
                        colors: pal.colors,
                        onSelectAsBase: { item in
                            state.setBaseHex(item.hex)
                            state.selectedTab = 0
                            state.showCheckmarkToast(text: "Set base color: \(item.hex)", hex: item.hex)
                        }
                    )
                }

                if filteredPalettes.isEmpty {
                    VStack(spacing: 10) {
                        Image(systemName: "paintpalette")
                            .font(.system(size: 28))
                            .foregroundColor(.secondary)
                        Text("No palettes found in this category")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(36)
                }
            }
            .padding(13)
        }
        .onAppear {
            state.refreshCurated()
        }
    }
}
