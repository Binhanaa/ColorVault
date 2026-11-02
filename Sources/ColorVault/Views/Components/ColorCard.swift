import SwiftUI
import AppKit

public struct ColorCard: View {
    public let color: ColorItem
    public let isCompact: Bool
    public var onSelectAsBase: ((ColorItem) -> Void)?
    public var onToast: ((String, String?) -> Void)?

    @State private var isHovered: Bool = false

    public init(
        color: ColorItem,
        isCompact: Bool = false,
        onSelectAsBase: ((ColorItem) -> Void)? = nil,
        onToast: ((String, String?) -> Void)? = nil
    ) {
        self.color = color
        self.isCompact = isCompact
        self.onSelectAsBase = onSelectAsBase
        self.onToast = onToast
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(color.swiftUIColor)
                    .frame(height: isCompact ? 44 : 64)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.primary.opacity(0.12), lineWidth: 1)
                    )
                    .shadow(color: color.swiftUIColor.opacity(0.25), radius: isHovered ? 6 : 2, x: 0, y: isHovered ? 3 : 1)

                if isHovered {
                    HStack(spacing: 4) {
                        Button(action: {
                            copyToClipboard(color.hex, label: "HEX")
                        }) {
                            Image(systemName: "doc.on.doc.fill")
                                .font(.system(size: 10))
                                .padding(4)
                                .background(Circle().fill(Color.black.opacity(0.6)))
                                .foregroundColor(.white)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .help("نسخ كود HEX")

                        if let onSelectAsBase = onSelectAsBase {
                            Button(action: {
                                onSelectAsBase(color)
                            }) {
                                Image(systemName: "arrow.triangle.2.circlepath")
                                    .font(.system(size: 10))
                                    .padding(4)
                                    .background(Circle().fill(Color.black.opacity(0.6)))
                                    .foregroundColor(.white)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .help("اجعله اللون الأساسي للهارموني")
                        }
                    }
                    .padding(4)
                    .transition(.opacity)
                }
            }

            VStack(alignment: .leading, spacing: 1) {
                Text(color.hex)
                    .font(.system(size: isCompact ? 10 : 12, weight: .bold, design: .monospaced))
                    .foregroundColor(.primary)

                if !isCompact {
                    Text(color.name)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
        }
        .contentShape(Rectangle())
        .onHover { hover in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hover
            }
        }
        .onTapGesture {
            copyToClipboard(color.hex, label: "HEX")
        }
        .contextMenu {
            Button("نسخ HEX (\(color.hex))") {
                copyToClipboard(color.hex, label: "HEX")
            }
            Button("نسخ RGB (\(color.rgb_code))") {
                copyToClipboard(color.rgb_code, label: "RGB")
            }
            Button("نسخ كود سويفت (\(color.swift_code))") {
                copyToClipboard(color.swift_code, label: "Swift")
            }
            Button("نسخ كود CSS (\(color.css_code))") {
                copyToClipboard(color.css_code, label: "CSS")
            }
            Divider()
            if let onSelectAsBase = onSelectAsBase {
                Button("جعله اللون الأساسي للهارموني") {
                    onSelectAsBase(color)
                }
            }
            Button("حفظ في المفضلة") {
                _ = RustBridge.shared.toggleFavorite(hex: color.hex)
                onToast?("تم تحديث المفضلة", color.hex)
            }
        }
    }

    private func copyToClipboard(_ text: String, label: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)

        NSSound.beep()
        onToast?("تم نسخ \(label): \(text)", color.hex)

        // Auto-persist usage in SQLite via Rust
        RustBridge.shared.recordColor(hex: color.hex, name: color.name, source: "copied_\(label.lowercased())")
    }
}
