import SwiftUI
import AppKit

public struct EyedropperButton: View {
    @Bindable var state: AppState = AppState.shared
    public var onColorPicked: ((String) -> Void)?

    public init(state: AppState = AppState.shared, onColorPicked: ((String) -> Void)? = nil) {
        self.state = state
        self.onColorPicked = onColorPicked
    }

    public var body: some View {
        Button(action: pickScreenColor) {
            HStack(spacing: 4.5) {
                Image(systemName: "eyedropper.halffull")
                    .font(.system(size: 10, weight: .semibold))
                Text(state.selectedLanguage == .arabic ? "القطارة" : "Pick Color")
                    .font(.system(size: 10.5, weight: .medium))
            }
            .padding(.horizontal, 9)
            .padding(.vertical, 4.5)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.primary.opacity(0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.primary.opacity(0.12), lineWidth: 0.8)
            )
            .foregroundColor(.primary)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .focusable(false)
        .focusEffectDisabled()
        .help(state.selectedLanguage == .arabic ? "سحب لون من أي مكان على الشاشة" : "Sample color from any screen pixel")
    }

    private func pickScreenColor() {
        let sampler = NSColorSampler()
        sampler.show { selectedColor in
            DispatchQueue.main.async {
                guard let color = selectedColor?.usingColorSpace(.sRGB) else { return }

                let r = Int(round(color.redComponent * 255))
                let g = Int(round(color.greenComponent * 255))
                let b = Int(round(color.blueComponent * 255))
                let hex = String(format: "#%02X%02X%02X", r, g, b)

                AppState.shared.setBaseHex(hex)
                self.onColorPicked?(hex)
                AppState.shared.showCheckmarkToast(text: "Sampled color: \(hex)", hex: hex)
            }
        }
    }
}
