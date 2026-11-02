import SwiftUI
import AppKit

public struct EyedropperButton: View {
    public var onColorPicked: (String) -> Void
    public var onToast: ((String, String?) -> Void)?

    @State private var isSampling: Bool = false

    public init(onColorPicked: @escaping (String) -> Void, onToast: ((String, String?) -> Void)? = nil) {
        self.onColorPicked = onColorPicked
        self.onToast = onToast
    }

    public var body: some View {
        Button(action: pickScreenColor) {
            HStack(spacing: 6) {
                Image(systemName: "eyedropper.halffull")
                    .font(.system(size: 13, weight: .bold))
                Text("القطارة")
                    .font(.system(size: 12, weight: .medium))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.accentColor.opacity(0.15))
            )
            .foregroundColor(.accentColor)
        }
        .buttonStyle(PlainButtonStyle())
        .help("التقط أي لون من الشاشة مباشرة وحفظه تلقائياً")
    }

    private func pickScreenColor() {
        guard !isSampling else { return }
        isSampling = true

        let sampler = NSColorSampler()
        sampler.show { selectedColor in
            DispatchQueue.main.async {
                self.isSampling = false
                guard let color = selectedColor?.usingColorSpace(.sRGB) else { return }

                let r = Int(round(color.redComponent * 255))
                let g = Int(round(color.greenComponent * 255))
                let b = Int(round(color.blueComponent * 255))
                let hex = String(format: "#%02X%02X%02X", r, g, b)

                // Save automatically in Rust SQLite
                _ = RustBridge.shared.recordColor(hex: hex, source: "eyedropper")

                self.onColorPicked(hex)
                self.onToast?("تم التقاط وحفظ اللون \(hex)", hex)
            }
        }
    }
}
