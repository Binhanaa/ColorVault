import SwiftUI
import AppKit

public struct HarmonyGeneratorView: View {
    @Bindable var state: AppState = AppState.shared

    public init(state: AppState = AppState.shared) {
        self.state = state
    }

    private var isAr: Bool {
        state.selectedLanguage == .arabic
    }

    private var currentFilters: [String] {
        if isAr {
            return ["الكل", "لونان (2)", "3 ألوان", "4 ألوان"]
        } else {
            return ["All Harmonies", "Duos (2)", "Trios (3)", "Tetrads (4)"]
        }
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                // Base Color Control & Info Header
                baseColorHeader

                // In-App Custom Color Picker (No external NSColorPanel!)
                if state.showCustomPicker {
                    CustomColorPickerView(selectedHex: $state.baseHex) { newHex in
                        state.setBaseHex(newHex)
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                }

                // UI Design System 50-950 Shades (For Developers & Designers)
                if state.showShadesSection && !state.activeShades.isEmpty {
                    shadesScaleSection
                }

                // Color Blindness Accessibility Simulation Card
                if state.showColorBlindness, let sim = state.colorBlindSim {
                    colorBlindnessSection(sim: sim)
                }

                // Symmetrical Filter Segmented Bar
                HStack(spacing: 6) {
                    ForEach(0..<currentFilters.count, id: \.self) { idx in
                        Button(action: {
                            state.harmonyFilter = idx
                        }) {
                            Text(currentFilters[idx])
                                .font(.system(size: 10.5, weight: state.harmonyFilter == idx ? .bold : .medium))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 5.5)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(state.harmonyFilter == idx ? Color.accentColor : Color.white.opacity(0.06))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(state.harmonyFilter == idx ? Color.accentColor.opacity(0.8) : Color.white.opacity(0.08), lineWidth: 0.8)
                                )
                                .foregroundColor(state.harmonyFilter == idx ? .white : .primary)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                        .focusable(false)
                    }
                }
                .padding(.horizontal, 1)

                // Harmonies List
                if let res = state.harmonyResult {
                    if state.harmonyFilter == 0 || state.harmonyFilter == 1 {
                        sectionHeader(title: isAr ? "تناغم ثنائي (لونان يتماشيان معاً)" : "2-Color Harmonies (Duos)", icon: "2.circle.fill", count: res.duos.count)
                        ForEach(res.duos) { duo in
                            PaletteRow(
                                title: isAr ? duo.title_ar : duo.title,
                                subtitle: duo.description,
                                colors: duo.colors,
                                onSelectAsBase: { item in
                                    state.setBaseHex(item.hex)
                                }
                            )
                        }
                    }

                    if state.harmonyFilter == 0 || state.harmonyFilter == 2 {
                        sectionHeader(title: isAr ? "تناغم ثلاثي (3 ألوان متناسقة)" : "3-Color Harmonies (Trios)", icon: "3.circle.fill", count: res.trios.count)
                        ForEach(res.trios) { trio in
                            PaletteRow(
                                title: isAr ? trio.title_ar : trio.title,
                                subtitle: trio.description,
                                colors: trio.colors,
                                onSelectAsBase: { item in
                                    state.setBaseHex(item.hex)
                                }
                            )
                        }
                    }

                    if state.harmonyFilter == 0 || state.harmonyFilter == 3 {
                        sectionHeader(title: isAr ? "تناغم رباعي (4 ألوان متناسقة)" : "4-Color Harmonies (Tetrads)", icon: "4.circle.fill", count: res.tetrads.count)
                        ForEach(res.tetrads) { tetrad in
                            PaletteRow(
                                title: isAr ? tetrad.title_ar : tetrad.title,
                                subtitle: tetrad.description,
                                colors: tetrad.colors,
                                onSelectAsBase: { item in
                                    state.setBaseHex(item.hex)
                                }
                            )
                        }
                    }
                }
            }
            .padding(13)
        }
        .onAppear {
            state.refreshHarmonies()
        }
    }

    private var baseColorHeader: some View {
        HStack(spacing: 10) {
            // In-App Custom Color Trigger Button (Replaces NSColorPanel!)
            Button(action: {
                withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                    state.showCustomPicker.toggle()
                }
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(hex: state.baseHex))
                        .frame(width: 36, height: 36)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.primary.opacity(0.15), lineWidth: 1))
                        .shadow(color: Color(hex: state.baseHex).opacity(0.3), radius: 3, x: 0, y: 1.5)

                    Image(systemName: state.showCustomPicker ? "chevron.up" : "slider.horizontal.3")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Color(hex: state.baseHex).isDarkColor ? .white : .black)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
            .focusable(false)
            .help("Click to toggle in-app Color Adjuster (No native popup)")

            // Big Color Swatch & Meta
            if let base = state.harmonyResult?.base_color {
                VStack(alignment: .leading, spacing: 2.5) {
                    HStack(spacing: 5) {
                        Text(base.name)
                            .font(.system(size: 12.5, weight: .bold))
                            .foregroundColor(.primary)

                        Text(base.hex)
                            .font(.system(size: 10.5, weight: .bold, design: .monospaced))
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 1.5)
                            .background(Capsule().fill(Color.primary.opacity(0.06)))
                    }

                    HStack(spacing: 7) {
                        Text("RGB: \(base.r), \(base.g), \(base.b)")
                            .font(.system(size: 9, design: .monospaced))
                            .foregroundColor(.secondary)

                        Text("HSL: \(Int(base.h))°, \(Int(base.s * 100))%, \(Int(base.l * 100))%")
                            .font(.system(size: 9, design: .monospaced))
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                HStack(spacing: 5) {
                    // Smart Shuffle Button
                    Button(action: {
                        state.shuffleSmartPalette()
                    }) {
                        Image(systemName: "shuffle")
                            .font(.system(size: 10, weight: .semibold))
                            .padding(5.5)
                            .background(Circle().fill(Color.white.opacity(0.08)))
                            .foregroundColor(.primary)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .focusable(false)
                    .help("Generate an intelligent harmonious palette")

                    // Toggle Color Blindness simulator
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            state.showColorBlindness.toggle()
                        }
                    }) {
                        Image(systemName: "eye.trianglebadge.exclamationmark")
                            .font(.system(size: 10, weight: .semibold))
                            .padding(5.5)
                            .background(Circle().fill(state.showColorBlindness ? Color.accentColor : Color.white.opacity(0.08)))
                            .foregroundColor(state.showColorBlindness ? .white : .primary)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .focusable(false)
                    .help("Simulate color blindness for accessibility")

                    // Clean Eyedropper without ugly highlight
                    EyedropperButton(onColorPicked: { picked in
                        state.setBaseHex(picked)
                    })
                }
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(NSColor.controlBackgroundColor).opacity(0.8))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.primary.opacity(0.08), lineWidth: 0.8)
        )
    }

    private var shadesScaleSection: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(isAr ? "مقياس تدرجات الواجهات (50 — 950):" : "UI Lightness Scale (50 — 950 Shades):")
                    .font(.system(size: 10.5, weight: .bold))
                    .foregroundColor(.secondary)
                Spacer()
                Text(isAr ? "انقر لنسخ أي درجة" : "Click any weight to copy")
                    .font(.system(size: 8.5))
                    .foregroundColor(.secondary)
            }

            HStack(spacing: 2.5) {
                ForEach(state.activeShades) { shade in
                    Button(action: {
                        state.copyColor(shade.color)
                    }) {
                        VStack(spacing: 2) {
                            RoundedRectangle(cornerRadius: 3.5)
                                .fill(shade.color.swiftUIColor)
                                .frame(height: 26)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 3.5)
                                        .stroke(Color.primary.opacity(0.1), lineWidth: 0.5)
                                )
                            Text("\(shade.weight)")
                                .font(.system(size: 7.5, weight: .semibold, design: .monospaced))
                                .foregroundColor(.secondary)
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                    .focusable(false)
                    .help("Weight \(shade.weight): \(shade.color.hex)")
                }
            }
            .environment(\.layoutDirection, isAr ? .rightToLeft : .leftToRight)
        }
        .padding(9)
        .background(
            RoundedRectangle(cornerRadius: 9)
                .fill(Color.primary.opacity(0.04))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 9)
                .stroke(Color.primary.opacity(0.06), lineWidth: 0.8)
        )
    }

    private func colorBlindnessSection(sim: ColorBlindSimulation) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Color Vision Deficiency Simulation:")
                .font(.system(size: 10.5, weight: .bold))
                .foregroundColor(.secondary)

            HStack(spacing: 5) {
                simBox(title: "Normal", hex: sim.normal)
                simBox(title: "Protan", hex: sim.protanopia)
                simBox(title: "Deuter", hex: sim.deuteranopia)
                simBox(title: "Tritan", hex: sim.tritanopia)
                simBox(title: "Mono", hex: sim.achromatopsia)
            }
        }
        .padding(9)
        .background(
            RoundedRectangle(cornerRadius: 9)
                .fill(Color(NSColor.controlBackgroundColor).opacity(0.45))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 9)
                .stroke(Color.accentColor.opacity(0.25), lineWidth: 0.8)
        )
    }

    private func simBox(title: String, hex: String) -> some View {
        VStack(spacing: 2) {
            RoundedRectangle(cornerRadius: 4.5)
                .fill(Color(hex: hex))
                .frame(height: 20)
            Text(title)
                .font(.system(size: 8, weight: .medium))
                .foregroundColor(.secondary)
                .lineLimit(1)
            Text(hex)
                .font(.system(size: 7, design: .monospaced))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private func sectionHeader(title: String, icon: String, count: Int) -> some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .foregroundColor(.accentColor)
                .font(.system(size: 12, weight: .bold))
            Text(title)
                .font(.system(size: 11.5, weight: .bold))
                .foregroundColor(.primary)
            Spacer()
            Text("\(count) sets")
                .font(.system(size: 9.5))
                .foregroundColor(.secondary)
        }
        .padding(.top, 2)
    }
}


