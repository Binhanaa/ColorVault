import SwiftUI
import AppKit

public struct PaletteRow: View {
    public let title: String
    public let subtitle: String
    public let colors: [ColorItem]
    public var onSelectAsBase: ((ColorItem) -> Void)?

    public init(
        title: String,
        subtitle: String,
        colors: [ColorItem],
        onSelectAsBase: ((ColorItem) -> Void)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.colors = colors
        self.onSelectAsBase = onSelectAsBase
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            // Header with titles and quick copy-all
            HStack {
                VStack(alignment: .leading, spacing: 1) {
                    Text(title)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.primary)
                    Text(subtitle)
                        .font(.system(size: 9.5))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                HStack(spacing: 5) {
                    Button(action: savePalette) {
                        Image(systemName: "bookmark.fill")
                            .font(.system(size: 9.5))
                            .foregroundColor(.secondary)
                            .padding(4.5)
                            .background(Circle().fill(Color.primary.opacity(0.06)))
                    }
                    .buttonStyle(PlainButtonStyle())
                    .focusable(false)
                    .help("Save to Vault")

                    Button(action: copyAllHexes) {
                        HStack(spacing: 3) {
                            Image(systemName: "square.on.square")
                                .font(.system(size: 8.5))
                            Text("Copy All")
                                .font(.system(size: 9.5, weight: .semibold))
                        }
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3.5)
                        .background(
                            Capsule().fill(Color.primary.opacity(0.08))
                        )
                        .foregroundColor(.primary)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                    .focusable(false)
                    .help("Copy all hex values separated by comma")
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
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.primary.opacity(0.1), lineWidth: 0.8)
                )
            }
            .frame(height: 20)

            // Individual Swatches Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 7), count: min(colors.count, 4)), spacing: 7) {
                ForEach(colors) { c in
                    ColorCard(
                        color: c,
                        isCompact: true,
                        onSelectAsBase: onSelectAsBase
                    )
                }
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(NSColor.controlBackgroundColor).opacity(0.65))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.primary.opacity(0.08), lineWidth: 0.8)
        )
    }

    private func copyAllHexes() {
        let hexString = colors.map { $0.hex }.joined(separator: ", ")
        let pb = NSPasteboard.general
        pb.clearContents()
        pb.setString(hexString, forType: .string)

        if AppState.shared.enableSound {
            NSSound.beep()
        }
        AppState.shared.showCheckmarkToast(text: "Copied palette: \(hexString)", hex: colors.first?.hex)
    }

    private func savePalette() {
        let cat = "\(colors.count)-colors"
        _ = RustBridge.shared.savePalette(title: title, category: cat, colors: colors)
        AppState.shared.refreshVault()
        AppState.shared.showCheckmarkToast(text: "Saved palette to Vault: \(title)", hex: colors.first?.hex)
    }
}
