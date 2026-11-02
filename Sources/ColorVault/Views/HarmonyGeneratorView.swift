import SwiftUI
import AppKit

public struct HarmonyGeneratorView: View {
    @Binding public var baseHex: String
    public var onToast: (String, String?) -> Void

    @State private var harmonyResult: HarmonyResult?
    @State private var selectedFilter: HarmonyFilter = .all
    @State private var baseColorPicker: Color = Color(hex: "#4F46E5")

    public enum HarmonyFilter: String, CaseIterable, Identifiable {
        case all = "الكل"
        case duos = "لونان (2)"
        case trios = "3 ألوان"
        case tetrads = "4 ألوان"

        public var id: String { rawValue }
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Base Color Control & Info Header
                baseColorHeader

                // Filter Segmented Bar
                HStack(spacing: 8) {
                    ForEach(HarmonyFilter.allCases) { filter in
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.15)) {
                                selectedFilter = filter
                            }
                        }) {
                            Text(filter.rawValue)
                                .font(.system(size: 11, weight: selectedFilter == filter ? .bold : .medium))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 5)
                                .background(
                                    Capsule()
                                        .fill(selectedFilter == filter ? Color.accentColor : Color.primary.opacity(0.06))
                                )
                                .foregroundColor(selectedFilter == filter ? .white : .primary)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    Spacer()
                }

                // Harmonies List
                if let res = harmonyResult {
                    if selectedFilter == .all || selectedFilter == .duos {
                        sectionHeader(title: "تناغم ثنائي (لونان يتماشيان معاً)", icon: "2.circle.fill", count: res.duos.count)
                        ForEach(res.duos) { duo in
                            PaletteRow(
                                title: duo.title_ar,
                                subtitle: "\(duo.title) — \(duo.description)",
                                colors: duo.colors,
                                onSelectAsBase: { item in
                                    updateBaseHex(item.hex)
                                },
                                onToast: onToast
                            )
                        }
                    }

                    if selectedFilter == .all || selectedFilter == .trios {
                        sectionHeader(title: "تناغم ثلاثي (3 ألوان متناسقة)", icon: "3.circle.fill", count: res.trios.count)
                        ForEach(res.trios) { trio in
                            PaletteRow(
                                title: trio.title_ar,
                                subtitle: "\(trio.title) — \(trio.description)",
                                colors: trio.colors,
                                onSelectAsBase: { item in
                                    updateBaseHex(item.hex)
                                },
                                onToast: onToast
                            )
                        }
                    }

                    if selectedFilter == .all || selectedFilter == .tetrads {
                        sectionHeader(title: "تناغم رباعي (4 ألوان متكاملة)", icon: "4.circle.fill", count: res.tetrads.count)
                        ForEach(res.tetrads) { tetrad in
                            PaletteRow(
                                title: tetrad.title_ar,
                                subtitle: "\(tetrad.title) — \(tetrad.description)",
                                colors: tetrad.colors,
                                onSelectAsBase: { item in
                                    updateBaseHex(item.hex)
                                },
                                onToast: onToast
                            )
                        }
                    }
                }
            }
            .padding(14)
        }
        .onAppear {
            refreshHarmonies()
        }
        .onChange(of: baseHex) { newHex in
            baseColorPicker = Color(hex: newHex)
            refreshHarmonies()
        }
    }

    private var baseColorHeader: some View {
        HStack(spacing: 12) {
            // Interactive Color Picker
            ColorPicker("", selection: $baseColorPicker, supportsOpacity: false)
                .labelsHidden()
                .scaleEffect(1.2)
                .onChange(of: baseColorPicker) { newColor in
                    let ns = NSColor(newColor).usingColorSpace(.sRGB) ?? NSColor.blue
                    let r = Int(round(ns.redComponent * 255))
                    let g = Int(round(ns.greenComponent * 255))
                    let b = Int(round(ns.blueComponent * 255))
                    let hex = String(format: "#%02X%02X%02X", r, g, b)
                    updateBaseHex(hex)
                }

            // Big Color Swatch & Meta
            if let base = harmonyResult?.base_color {
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(base.name)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.primary)

                        Text(base.hex)
                            .font(.system(size: 12, weight: .semibold, design: .monospaced))
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(Color.primary.opacity(0.06)))
                    }

                    HStack(spacing: 10) {
                        Text("RGB: \(base.r), \(base.g), \(base.b)")
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(.secondary)

                        Text("HSL: \(Int(base.h))°, \(Int(base.s * 100))%, \(Int(base.l * 100))%")
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                EyedropperButton(onColorPicked: { picked in
                    updateBaseHex(picked)
                }, onToast: onToast)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.controlBackgroundColor))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.primary.opacity(0.08), lineWidth: 1)
        )
    }

    private func sectionHeader(title: String, icon: String, count: Int) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundColor(.accentColor)
                .font(.system(size: 14, weight: .bold))
            Text(title)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.primary)
            Spacer()
            Text("\(count) مجموعات")
                .font(.system(size: 11))
                .foregroundColor(.secondary)
        }
        .padding(.top, 4)
    }

    private func updateBaseHex(_ hex: String) {
        baseHex = hex
        refreshHarmonies()
        // Record in SQLite via Rust
        _ = RustBridge.shared.recordColor(hex: hex, source: "harmony_base")
    }

    private func refreshHarmonies() {
        if let res = RustBridge.shared.generateHarmonies(hex: baseHex) {
            harmonyResult = res
        }
    }
}
