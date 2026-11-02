import SwiftUI
import AppKit

public struct PaletteRow: View {
    public let title: String
    public let subtitle: String
    public let colors: [ColorItem]
    public var onSelectAsBase: ((ColorItem) -> Void)?
    public var onToast: ((String, String?) -> Void)?

    public init(
        title: String,
        subtitle: String,
        colors: [ColorItem],
        onSelectAsBase: ((ColorItem) -> Void)? = nil,
        onToast: ((String, String?) -> Void)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.colors = colors
        self.onSelectAsBase = onSelectAsBase
        self.onToast = onToast
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header with titles and quick copy-all
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.primary)
                    Text(subtitle)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }

                Spacer()

                HStack(spacing: 8) {
                    Button(action: savePalette) {
                        Image(systemName: "bookmark.fill")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                            .padding(4)
                            .background(Circle().fill(Color.primary.opacity(0.06)))
                    }
                    .buttonStyle(PlainButtonStyle())
                    .help("حفظ هذه المجموعة في الخزنة")

                    Button(action: copyAllHexes) {
                        HStack(spacing: 4) {
                            Image(systemName: "square.on.square")
                                .font(.system(size: 10))
                            Text("نسخ الكل")
                                .font(.system(size: 11, weight: .semibold))
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule().fill(Color.primary.opacity(0.08))
                        )
                        .foregroundColor(.primary)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .help("نسخ جميع أكواد الألوان مفصولة بفواصل")
                }
            }

            // Continuous Visual Stripe Preview
            GeometryReader { geo in
                HStack(spacing: 0) {
                    ForEach(colors) { c in
                        Rectangle()
                            .fill(c.swiftUIColor)
                            .frame(width: geo.size.width / CGFloat(max(1, colors.count)))
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.primary.opacity(0.1), lineWidth: 1)
                )
            }
            .frame(height: 24)

            // Individual Swatches Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: min(colors.count, 4)), spacing: 8) {
                ForEach(colors) { c in
                    ColorCard(
                        color: c,
                        isCompact: true,
                        onSelectAsBase: onSelectAsBase,
                        onToast: onToast
                    )
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.controlBackgroundColor).opacity(0.6))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.primary.opacity(0.08), lineWidth: 1)
        )
    }

    private func copyAllHexes() {
        let hexString = colors.map { $0.hex }.joined(separator: ", ")
        let pb = NSPasteboard.general
        pb.clearContents()
        pb.setString(hexString, forType: .string)
        NSSound.beep()
        onToast?("تم نسخ جميع الألوان: \(hexString)", colors.first?.hex)
    }

    private func savePalette() {
        let cat = "\(colors.count)-colors"
        _ = RustBridge.shared.savePalette(title: title, category: cat, colors: colors)
        onToast?("تم حفظ المجموعة بنجاح في قاعدة البيانات", colors.first?.hex)
    }
}
