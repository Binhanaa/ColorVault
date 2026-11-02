import SwiftUI
import AppKit

public struct PairMatcherView: View {
    @Bindable var state: AppState = AppState.shared

    public init(state: AppState = AppState.shared) {
        self.state = state
    }

    private var isAr: Bool {
        state.selectedLanguage == .arabic
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                // Symmetrical Dual Selectors Card
                HStack(spacing: 10) {
                    // Color A
                    colorInputBox(
                        title: isAr ? "اللون أ (المقدمة/النص)" : "Color A (Foreground)",
                        hex: state.pairHex1,
                        isSelected: state.activePairPicker == 1,
                        onTap: {
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                                state.activePairPicker = (state.activePairPicker == 1) ? 0 : 1
                            }
                        }
                    )

                    // Swap Button
                    Button(action: {
                        state.swapPair()
                    }) {
                        Image(systemName: "arrow.left.arrow.right")
                            .font(.system(size: 10.5, weight: .bold))
                            .padding(6.5)
                            .background(Circle().fill(Color.primary.opacity(0.08)))
                            .foregroundColor(.primary)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                    .focusable(false)
                    .help(isAr ? "تبديل اللونين" : "Swap Colors")

                    // Color B
                    colorInputBox(
                        title: isAr ? "اللون ب (الخلفية)" : "Color B (Background)",
                        hex: state.pairHex2,
                        isSelected: state.activePairPicker == 2,
                        onTap: {
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                                state.activePairPicker = (state.activePairPicker == 2) ? 0 : 2
                            }
                        }
                    )
                }
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(NSColor.controlBackgroundColor).opacity(0.75))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.primary.opacity(0.08), lineWidth: 0.8)
                )

                // Inline In-App Color Adjuster (No NSColorPanel popup!)
                if state.activePairPicker == 1 {
                    CustomColorPickerView(selectedHex: $state.pairHex1) { newHex in
                        state.updatePair1(newHex)
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                } else if state.activePairPicker == 2 {
                    CustomColorPickerView(selectedHex: $state.pairHex2) { newHex in
                        state.updatePair2(newHex)
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                }

                if let eval = state.pairEvaluation {
                    // Harmony Score & Verdict Card
                    verdictCard(eval: eval)

                    // Side-by-side Contrast Preview
                    contrastPreviewSection(eval: eval)

                    // 1-Click Auto-Fix Contrast Tool
                    if eval.contrast_ratio < 7.0 {
                        autoFixContrastSection(eval: eval)
                    }

                    // Suggestions to Expand: Trio (3) & Tetrad (4)
                    expansionSuggestions(eval: eval)
                }
            }
            .padding(13)
        }
        .onAppear {
            state.refreshPairMatch()
        }
    }

    private func colorInputBox(
        title: String,
        hex: String,
        isSelected: Bool,
        onTap: @escaping () -> Void
    ) -> some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 9.5, weight: .semibold))
                    .foregroundColor(.secondary)

                HStack(spacing: 6) {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color(hex: hex))
                        .frame(width: 22, height: 22)
                        .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.primary.opacity(0.15), lineWidth: 0.8))

                    Text(hex)
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(.primary)

                    Spacer()

                    Image(systemName: isSelected ? "chevron.up" : "chevron.down")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.secondary)
                }
                .padding(5)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(NSColor.textBackgroundColor))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(isSelected ? Color.accentColor : Color.primary.opacity(0.1), lineWidth: 1)
                )
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .focusable(false)
    }

    private func verdictCard(eval: MatchEvaluation) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(isAr ? eval.relationship_ar : eval.relationship)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.primary)
                    Text(isAr ? eval.relationship : eval.relationship_ar)
                        .font(.system(size: 9.5))
                        .foregroundColor(.secondary)
                }

                Spacer()

                // Score Badge
                HStack(spacing: 3) {
                    Text("\(eval.score_pct)%")
                        .font(.system(size: 15, weight: .heavy, design: .rounded))
                        .foregroundColor(scoreColor(eval.score_pct))
                    Text(isAr ? "التقييم" : "Score")
                        .font(.system(size: 9.5, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(scoreColor(eval.score_pct).opacity(0.12))
                )
            }

            Divider()

            // Advice & Contrast Meta
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 1) {
                    Text(isAr ? "نسبة التباين (WCAG)" : "Contrast Ratio (WCAG)")
                        .font(.system(size: 8.5))
                        .foregroundColor(.secondary)
                    Text("\(String(format: "%.2f", eval.contrast_ratio)):1")
                        .font(.system(size: 11.5, weight: .bold, design: .monospaced))
                        .foregroundColor(.primary)
                }

                VStack(alignment: .leading, spacing: 1) {
                    Text(isAr ? "تقييم WCAG" : "WCAG Rating")
                        .font(.system(size: 8.5))
                        .foregroundColor(.secondary)
                    Text(eval.contrast_ratio >= 7.0 ? "AAA (Pass)" : (eval.contrast_ratio >= 4.5 ? "AA (Pass)" : (isAr ? "راسب (< 4.5:1)" : "Fail (< 4.5:1)")))
                        .font(.system(size: 10.5, weight: .semibold))
                        .foregroundColor(eval.contrast_ratio >= 4.5 ? .green : .orange)
                }
            }

            Text(isAr ? eval.advice_ar : eval.advice_en)
                .font(.system(size: 10.5))
                .foregroundColor(.primary.opacity(0.9))
                .lineSpacing(2)
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(NSColor.controlBackgroundColor).opacity(0.7))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.primary.opacity(0.08), lineWidth: 0.8)
        )
    }

    private func contrastPreviewSection(eval: MatchEvaluation) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(isAr ? "معاينة واجهات حقيقية:" : "Simulated UI Previews:")
                .font(.system(size: 10.5, weight: .bold))
                .foregroundColor(.secondary)

            HStack(spacing: 8) {
                // Preview 1: Color 1 text on Color 2 bg
                VStack(spacing: 2) {
                    Text("Aa Preview")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(eval.color1.swiftUIColor)
                    Text(isAr ? "اللون أ على اللون ب" : "Color A on Color B")
                        .font(.system(size: 8.5, weight: .medium))
                        .foregroundColor(eval.color1.swiftUIColor.opacity(0.85))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(eval.color2.swiftUIColor)
                .cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.primary.opacity(0.1), lineWidth: 0.8))

                // Preview 2: Color 2 text on Color 1 bg
                VStack(spacing: 2) {
                    Text("Aa Preview")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(eval.color2.swiftUIColor)
                    Text(isAr ? "اللون ب على اللون أ" : "Color B on Color A")
                        .font(.system(size: 8.5, weight: .medium))
                        .foregroundColor(eval.color2.swiftUIColor.opacity(0.85))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(eval.color1.swiftUIColor)
                .cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.primary.opacity(0.1), lineWidth: 0.8))
            }
        }
    }

    private func autoFixContrastSection(eval: MatchEvaluation) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(isAr ? "إصلاح التباين الذكي بنقرة واحدة:" : "1-Click Smart Contrast Auto-Fixer:")
                .font(.system(size: 9.5, weight: .bold))
                .foregroundColor(.secondary)

            HStack(spacing: 6) {
                Button(action: {
                    state.updatePair2(eval.auto_fixed_color2_aa.hex)
                    state.showCheckmarkToast(text: "Applied AA Fix: \(eval.auto_fixed_color2_aa.hex)", hex: eval.auto_fixed_color2_aa.hex)
                }) {
                    HStack(spacing: 4) {
                        Circle().fill(eval.auto_fixed_color2_aa.swiftUIColor).frame(width: 8.5, height: 8.5)
                        Text(isAr ? "إصلاح لمعيار AA: \(eval.auto_fixed_color2_aa.hex)" : "Fix for AA (4.5:1): \(eval.auto_fixed_color2_aa.hex)")
                            .font(.system(size: 9.5, weight: .medium))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 4.5)
                    .background(RoundedRectangle(cornerRadius: 5).fill(Color.accentColor.opacity(0.12)))
                    .foregroundColor(.accentColor)
                }
                .buttonStyle(PlainButtonStyle())
                .focusable(false)

                Button(action: {
                    state.updatePair2(eval.auto_fixed_color2_aaa.hex)
                    state.showCheckmarkToast(text: "Applied AAA Fix: \(eval.auto_fixed_color2_aaa.hex)", hex: eval.auto_fixed_color2_aaa.hex)
                }) {
                    HStack(spacing: 4) {
                        Circle().fill(eval.auto_fixed_color2_aaa.swiftUIColor).frame(width: 8.5, height: 8.5)
                        Text(isAr ? "إصلاح لمعيار AAA: \(eval.auto_fixed_color2_aaa.hex)" : "Fix for AAA (7:1): \(eval.auto_fixed_color2_aaa.hex)")
                            .font(.system(size: 9.5, weight: .medium))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 4.5)
                    .background(RoundedRectangle(cornerRadius: 5).fill(Color.green.opacity(0.12)))
                    .foregroundColor(.green)
                }
                .buttonStyle(PlainButtonStyle())
                .focusable(false)
            }
        }
        .padding(8)
        .background(RoundedRectangle(cornerRadius: 8).fill(Color.primary.opacity(0.04)))
    }

    private func expansionSuggestions(eval: MatchEvaluation) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(isAr ? "ألوان مقترحة لإكمال التناغم الثلاثي والرباعي:" : "Suggested Chords to Complete Trio & Tetrad:")
                .font(.system(size: 10.5, weight: .bold))
                .foregroundColor(.secondary)

            // Suggestion 1: Make it a Trio
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(isAr ? "تناغم ثلاثي مكتمل:" : "Expanded Trio Harmony:")
                        .font(.system(size: 9.5, weight: .semibold))
                    Spacer()
                    Button(isAr ? "نسخ الثلاثي" : "Copy Trio") {
                        let trioStr = "\(eval.color1.hex), \(eval.color2.hex), \(eval.suggested_trio_color.hex)"
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(trioStr, forType: .string)
                        state.showCheckmarkToast(text: "Copied Trio: \(trioStr)", hex: eval.suggested_trio_color.hex)
                    }
                    .font(.system(size: 8.5))
                    .buttonStyle(PlainButtonStyle())
                    .focusable(false)
                }

                HStack(spacing: 6) {
                    ColorCard(color: eval.color1, isCompact: true)
                    ColorCard(color: eval.color2, isCompact: true)
                    ColorCard(color: eval.suggested_trio_color, isCompact: true)
                }
            }
            .padding(8)
            .background(RoundedRectangle(cornerRadius: 8).fill(Color.primary.opacity(0.04)))

            // Suggestion 2: Make it a Tetrad
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(isAr ? "تناغم رباعي مكتمل:" : "Expanded Tetrad Harmony:")
                        .font(.system(size: 9.5, weight: .semibold))
                    Spacer()
                    Button(isAr ? "نسخ الرباعي" : "Copy Tetrad") {
                        let tetradStr = "\(eval.color1.hex), \(eval.color2.hex), \(eval.suggested_trio_color.hex), \(eval.suggested_tetrad_color.hex)"
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(tetradStr, forType: .string)
                        state.showCheckmarkToast(text: "Copied Tetrad: \(tetradStr)", hex: eval.suggested_tetrad_color.hex)
                    }
                    .font(.system(size: 8.5))
                    .buttonStyle(PlainButtonStyle())
                    .focusable(false)
                }

                HStack(spacing: 6) {
                    ColorCard(color: eval.color1, isCompact: true)
                    ColorCard(color: eval.color2, isCompact: true)
                    ColorCard(color: eval.suggested_trio_color, isCompact: true)
                    ColorCard(color: eval.suggested_tetrad_color, isCompact: true)
                }
            }
            .padding(8)
            .background(RoundedRectangle(cornerRadius: 8).fill(Color.primary.opacity(0.04)))
        }
    }

    private func scoreColor(_ score: Int) -> Color {
        if score >= 90 { return .green }
        if score >= 75 { return .blue }
        if score >= 60 { return .orange }
        return .red
    }
}
