import SwiftUI
import AppKit

public struct PairMatcherView: View {
    public var onToast: (String, String?) -> Void

    @State private var hex1: String = "#2563EB" // Royal Blue
    @State private var hex2: String = "#F97316" // Tangerine
    @State private var colorPicker1: Color = Color(hex: "#2563EB")
    @State private var colorPicker2: Color = Color(hex: "#F97316")

    @State private var evaluation: MatchEvaluation?

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Dual Selectors Card
                HStack(spacing: 12) {
                    // Color 1
                    colorInputBox(
                        title: "اللون الأول (A)",
                        hex: $hex1,
                        picker: $colorPicker1,
                        onChanged: {
                            updateEvaluation()
                        }
                    )

                    // Swap Button
                    Button(action: swapColors) {
                        Image(systemName: "arrow.left.arrow.right")
                            .font(.system(size: 13, weight: .bold))
                            .padding(8)
                            .background(Circle().fill(Color.primary.opacity(0.08)))
                            .foregroundColor(.primary)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .help("تبديل اللونين")

                    // Color 2
                    colorInputBox(
                        title: "اللون الثاني (B)",
                        hex: $hex2,
                        picker: $colorPicker2,
                        onChanged: {
                            updateEvaluation()
                        }
                    )
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(NSColor.controlBackgroundColor))
                )

                if let eval = evaluation {
                    // Harmony Score & Verdict Card
                    verdictCard(eval: eval)

                    // Side-by-side Contrast Preview
                    contrastPreviewSection(eval: eval)

                    // Suggestions to Expand: Trio (3) & Tetrad (4)
                    expansionSuggestions(eval: eval)
                }
            }
            .padding(14)
        }
        .onAppear {
            updateEvaluation()
        }
    }

    private func colorInputBox(
        title: String,
        hex: Binding<String>,
        picker: Binding<Color>,
        onChanged: @escaping () -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.secondary)

            HStack(spacing: 8) {
                ColorPicker("", selection: picker, supportsOpacity: false)
                    .labelsHidden()
                    .onChange(of: picker.wrappedValue) { newColor in
                        let ns = NSColor(newColor).usingColorSpace(.sRGB) ?? NSColor.blue
                        let r = Int(round(ns.redComponent * 255))
                        let g = Int(round(ns.greenComponent * 255))
                        let b = Int(round(ns.blueComponent * 255))
                        hex.wrappedValue = String(format: "#%02X%02X%02X", r, g, b)
                        onChanged()
                    }

                Text(hex.wrappedValue)
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .foregroundColor(.primary)
            }
            .padding(8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(NSColor.textBackgroundColor))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.primary.opacity(0.1), lineWidth: 1)
            )
        }
    }

    private func verdictCard(eval: MatchEvaluation) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(eval.relationship_ar)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.primary)
                    Text(eval.relationship)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }

                Spacer()

                // Score Badge
                HStack(spacing: 4) {
                    Text("\(eval.score_pct)%")
                        .font(.system(size: 18, weight: .heavy, design: .rounded))
                        .foregroundColor(scoreColor(eval.score_pct))
                    Text("توافق")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(scoreColor(eval.score_pct).opacity(0.12))
                )
            }

            Divider()

            // Advice & Contrast Meta
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("نسبة التباين (Contrast)")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                    Text("\(String(format: "%.2f", eval.contrast_ratio)):1")
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundColor(.primary)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("معيار WCAG")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                    Text(eval.wcag_rating)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(eval.contrast_ratio >= 4.5 ? .green : .orange)
                }
            }

            Text(eval.advice_ar)
                .font(.system(size: 12))
                .foregroundColor(.primary.opacity(0.9))
                .lineSpacing(2)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.controlBackgroundColor).opacity(0.8))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.primary.opacity(0.08), lineWidth: 1)
        )
    }

    private func contrastPreviewSection(eval: MatchEvaluation) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("معاينة التباين والنصوص المتبادلة:")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.secondary)

            HStack(spacing: 10) {
                // Preview 1: Color 1 text on Color 2 bg
                VStack(spacing: 4) {
                    Text("Aa")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(eval.color1.swiftUIColor)
                    Text("نص A على خلفية B")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(eval.color1.swiftUIColor)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 70)
                .background(eval.color2.swiftUIColor)
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.primary.opacity(0.1), lineWidth: 1))

                // Preview 2: Color 2 text on Color 1 bg
                VStack(spacing: 4) {
                    Text("Aa")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(eval.color2.swiftUIColor)
                    Text("نص B على خلفية A")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(eval.color2.swiftUIColor)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 70)
                .background(eval.color1.swiftUIColor)
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.primary.opacity(0.1), lineWidth: 1))
            }
        }
    }

    private func expansionSuggestions(eval: MatchEvaluation) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("إكمال التناغم بمقترحات ذكية:")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.secondary)

            // Suggestion 1: Make it a Trio
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("إكمال إلى ثلاثية (Trio Harmony):")
                        .font(.system(size: 11, weight: .semibold))
                    Spacer()
                    Button("نسخ الثلاثية") {
                        let trioStr = "\(eval.color1.hex), \(eval.color2.hex), \(eval.suggested_trio_color.hex)"
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(trioStr, forType: .string)
                        onToast("تم نسخ ألوان الثلاثية: \(trioStr)", eval.suggested_trio_color.hex)
                    }
                    .font(.system(size: 10))
                }

                HStack(spacing: 8) {
                    ColorCard(color: eval.color1, isCompact: true, onToast: onToast)
                    ColorCard(color: eval.color2, isCompact: true, onToast: onToast)
                    ColorCard(color: eval.suggested_trio_color, isCompact: true, onToast: onToast)
                }
            }
            .padding(10)
            .background(RoundedRectangle(cornerRadius: 10).fill(Color.primary.opacity(0.04)))

            // Suggestion 2: Make it a Tetrad
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("إكمال إلى رباعية (Tetrad Harmony):")
                        .font(.system(size: 11, weight: .semibold))
                    Spacer()
                    Button("نسخ الرباعية") {
                        let tetradStr = "\(eval.color1.hex), \(eval.color2.hex), \(eval.suggested_trio_color.hex), \(eval.suggested_tetrad_color.hex)"
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(tetradStr, forType: .string)
                        onToast("تم نسخ ألوان الرباعية: \(tetradStr)", eval.suggested_tetrad_color.hex)
                    }
                    .font(.system(size: 10))
                }

                HStack(spacing: 8) {
                    ColorCard(color: eval.color1, isCompact: true, onToast: onToast)
                    ColorCard(color: eval.color2, isCompact: true, onToast: onToast)
                    ColorCard(color: eval.suggested_trio_color, isCompact: true, onToast: onToast)
                    ColorCard(color: eval.suggested_tetrad_color, isCompact: true, onToast: onToast)
                }
            }
            .padding(10)
            .background(RoundedRectangle(cornerRadius: 10).fill(Color.primary.opacity(0.04)))
        }
    }

    private func swapColors() {
        let tempHex = hex1
        hex1 = hex2
        hex2 = tempHex

        let tempPicker = colorPicker1
        colorPicker1 = colorPicker2
        colorPicker2 = tempPicker

        updateEvaluation()
    }

    private func updateEvaluation() {
        if let res = RustBridge.shared.evaluatePair(hex1: hex1, hex2: hex2) {
            evaluation = res
            // Record usage in SQLite via Rust
            _ = RustBridge.shared.recordColor(hex: hex1, source: "pair_matcher")
            _ = RustBridge.shared.recordColor(hex: hex2, source: "pair_matcher")
        }
    }

    private func scoreColor(_ score: Int) -> Color {
        if score >= 90 { return .green }
        if score >= 75 { return .blue }
        if score >= 60 { return .orange }
        return .red
    }
}
