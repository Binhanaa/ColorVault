import SwiftUI
import AppKit

public struct CustomColorPickerView: View {
    @Bindable var state: AppState = AppState.shared
    @Binding var selectedHex: String
    public var onColorChanged: ((String) -> Void)?

    let presets: [String] = [
        "#0F172A", "#334155", "#64748B", "#F8FAFC",
        "#2563EB", "#06B6D4", "#10B981", "#84CC16",
        "#EAB308", "#F97316", "#EF4444", "#EC4899",
        "#8B5CF6", "#6366F1", "#14B8A6", "#D97706"
    ]

    public init(
        state: AppState = AppState.shared,
        selectedHex: Binding<String>,
        onColorChanged: ((String) -> Void)? = nil
    ) {
        self.state = state
        self._selectedHex = selectedHex
        self.onColorChanged = onColorChanged
    }

    public var currentColor: Color {
        Color.fromHsl(h: state.pickerHue, s: state.pickerSaturation, l: state.pickerLightness)
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            // Header with Large Swatch and Hex input
            HStack(spacing: 9) {
                RoundedRectangle(cornerRadius: 7)
                    .fill(currentColor)
                    .frame(width: 40, height: 40)
                    .overlay(RoundedRectangle(cornerRadius: 7).stroke(Color.primary.opacity(0.15), lineWidth: 1))
                    .shadow(color: currentColor.opacity(0.25), radius: 3, x: 0, y: 1.5)

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 5) {
                        Text("HEX:")
                            .font(.system(size: 9.5, weight: .bold))
                            .foregroundColor(.secondary)

                        TextField("#HEX", text: $state.pickerHexInput)
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2.5)
                            .background(RoundedRectangle(cornerRadius: 5).fill(Color.primary.opacity(0.06)))
                            .frame(width: 80)
                            .onSubmit {
                                applyHexInput()
                            }
                    }

                    HStack(spacing: 7) {
                        let rgb = Color.hslToRgb(h: state.pickerHue, s: state.pickerSaturation, l: state.pickerLightness)
                        Text("R: \(rgb.r)")
                            .font(.system(size: 8.5, design: .monospaced))
                            .foregroundColor(.secondary)
                        Text("G: \(rgb.g)")
                            .font(.system(size: 8.5, design: .monospaced))
                            .foregroundColor(.secondary)
                        Text("B: \(rgb.b)")
                            .font(.system(size: 8.5, design: .monospaced))
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                EyedropperButton(onColorPicked: { picked in
                    updateFromHex(picked)
                })
            }

            Divider()

            // Hue Slider (0 - 360)
            VStack(alignment: .leading, spacing: 1) {
                HStack {
                    Text("Hue:")
                        .font(.system(size: 9.5, weight: .medium))
                    Spacer()
                    Text("\(Int(state.pickerHue))°")
                        .font(.system(size: 9.5, design: .monospaced))
                        .foregroundColor(.secondary)
                }

                Slider(value: $state.pickerHue, in: 0...360, step: 1)
                    .onChange(of: state.pickerHue) { _, _ in
                        commitColor()
                    }
            }

            // Saturation Slider (0 - 100)
            VStack(alignment: .leading, spacing: 1) {
                HStack {
                    Text("Saturation:")
                        .font(.system(size: 9.5, weight: .medium))
                    Spacer()
                    Text("\(Int(state.pickerSaturation * 100))%")
                        .font(.system(size: 9.5, design: .monospaced))
                        .foregroundColor(.secondary)
                }

                Slider(value: $state.pickerSaturation, in: 0...1, step: 0.01)
                    .onChange(of: state.pickerSaturation) { _, _ in
                        commitColor()
                    }
            }

            // Lightness Slider (5 - 95)
            VStack(alignment: .leading, spacing: 1) {
                HStack {
                    Text("Lightness:")
                        .font(.system(size: 9.5, weight: .medium))
                    Spacer()
                    Text("\(Int(state.pickerLightness * 100))%")
                        .font(.system(size: 9.5, design: .monospaced))
                        .foregroundColor(.secondary)
                }

                Slider(value: $state.pickerLightness, in: 0.05...0.95, step: 0.01)
                    .onChange(of: state.pickerLightness) { _, _ in
                        commitColor()
                    }
            }

            // Quick Preset Swatches
            VStack(alignment: .leading, spacing: 3) {
                Text("Presets:")
                    .font(.system(size: 8.5, weight: .semibold))
                    .foregroundColor(.secondary)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 8), spacing: 4) {
                    ForEach(presets, id: \.self) { hex in
                        Button(action: {
                            updateFromHex(hex)
                        }) {
                            RoundedRectangle(cornerRadius: 4.5)
                                .fill(Color(hex: hex))
                                .frame(height: 18)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4.5)
                                        .stroke(Color.primary.opacity(0.12), lineWidth: 0.8)
                                )
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                        .focusable(false)
                        .help(hex)
                    }
                }
            }
        }
        .padding(9)
        .background(
            RoundedRectangle(cornerRadius: 9)
                .fill(Color(NSColor.controlBackgroundColor).opacity(0.85))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 9)
                .stroke(Color.primary.opacity(0.1), lineWidth: 0.8)
        )
        .onAppear {
            updateFromHex(selectedHex)
        }
        .onChange(of: selectedHex) { _, newHex in
            if newHex != state.pickerHexInput {
                updateFromHex(newHex)
            }
        }
    }

    private func commitColor() {
        let rgb = Color.hslToRgb(h: state.pickerHue, s: state.pickerSaturation, l: state.pickerLightness)
        let hex = String(format: "#%02X%02X%02X", rgb.r, rgb.g, rgb.b)
        state.pickerHexInput = hex
        selectedHex = hex
        onColorChanged?(hex)
    }

    private func applyHexInput() {
        var clean = state.pickerHexInput.trimmingCharacters(in: .whitespacesAndNewlines)
        if !clean.hasPrefix("#") { clean = "#" + clean }
        if clean.count == 7 {
            updateFromHex(clean)
            commitColor()
        }
    }

    private func updateFromHex(_ hex: String) {
        let clean = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        guard clean.count == 6, let int = UInt64(clean, radix: 16) else { return }
        let r = Double((int >> 16) & 0xFF) / 255.0
        let g = Double((int >> 8) & 0xFF) / 255.0
        let b = Double(int & 0xFF) / 255.0

        let maxC = max(r, max(g, b))
        let minC = min(r, min(g, b))
        let delta = maxC - minC
        let l = (maxC + minC) / 2.0

        var h: Double = 0
        var s: Double = 0

        if delta != 0 {
            s = l > 0.5 ? delta / (2.0 - maxC - minC) : delta / (maxC + minC)
            if maxC == r {
                h = ((g - b) / delta + (g < b ? 6 : 0)) * 60
            } else if maxC == g {
                h = ((b - r) / delta + 2) * 60
            } else {
                h = ((r - g) / delta + 4) * 60
            }
        }

        state.pickerHue = h
        state.pickerSaturation = s
        state.pickerLightness = l
        state.pickerHexInput = hex.hasPrefix("#") ? hex : "#" + hex
        self.selectedHex = state.pickerHexInput
        onColorChanged?(self.selectedHex)
    }
}
