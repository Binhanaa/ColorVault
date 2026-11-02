import SwiftUI
import AppKit

public struct ColorCard: View {
    public let color: ColorItem
    public let isCompact: Bool
    public var onSelectAsBase: ((ColorItem) -> Void)?

    public init(
        color: ColorItem,
        isCompact: Bool = false,
        onSelectAsBase: ((ColorItem) -> Void)? = nil
    ) {
        self.color = color
        self.isCompact = isCompact
        self.onSelectAsBase = onSelectAsBase
    }

    public var isJustCopied: Bool {
        AppState.shared.copiedHex == color.hex
    }

    public var isFav: Bool {
        AppState.shared.isFavorite(hex: color.hex)
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 7)
                    .fill(color.swiftUIColor)
                    .frame(height: isCompact ? 40 : 58)
                    .overlay(
                        RoundedRectangle(cornerRadius: 7)
                            .stroke(Color.primary.opacity(0.12), lineWidth: 0.8)
                    )
                    .shadow(color: color.swiftUIColor.opacity(0.18), radius: 2, x: 0, y: 1)

                // Copied Checkmark Overlay
                if isJustCopied {
                    ZStack {
                        RoundedRectangle(cornerRadius: 7)
                            .fill(Color.black.opacity(0.6))
                        Image(systemName: "checkmark")
                            .font(.system(size: isCompact ? 13 : 16, weight: .bold))
                            .foregroundColor(.green)
                    }
                    .transition(.opacity)
                }

                // Quick Action Buttons
                HStack(spacing: 2) {
                    // Star button
                    Button(action: {
                        AppState.shared.toggleFavorite(color: color)
                    }) {
                        Image(systemName: isFav ? "star.fill" : "star")
                            .font(.system(size: 7.5, weight: .bold))
                            .padding(3.5)
                            .background(Circle().fill(Color.black.opacity(0.65)))
                            .foregroundColor(isFav ? .yellow : .white.opacity(0.8))
                    }
                    .buttonStyle(PlainButtonStyle())
                    .focusable(false)
                    .help(isFav ? "Remove Favorite" : "Add to Favorites")

                    if let onSelectAsBase = onSelectAsBase {
                        Button(action: {
                            onSelectAsBase(color)
                        }) {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .font(.system(size: 7.5, weight: .bold))
                                .padding(3.5)
                                .background(Circle().fill(Color.black.opacity(0.65)))
                                .foregroundColor(.white)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .focusable(false)
                        .help("Set as Base Harmony Color")
                    }
                }
                .padding(2.5)
            }

            VStack(alignment: .leading, spacing: 0.5) {
                Text(color.hex)
                    .font(.system(size: isCompact ? 9.5 : 11, weight: .bold, design: .monospaced))
                    .foregroundColor(.primary)

                if !isCompact {
                    Text(color.name)
                        .font(.system(size: 8.5, weight: .medium))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            AppState.shared.copyColor(color)
        }
        .contextMenu {
            Button("Copy Default (\(AppState.shared.defaultCopyFormat.rawValue))") {
                AppState.shared.copyColor(color)
            }
            Divider()
            Button("Copy HEX (\(color.hex))") {
                AppState.shared.copyColor(color, format: .hex)
            }
            Button("Copy HEX without # (\(color.hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))))") {
                AppState.shared.copyColor(color, format: .hexNoHash)
            }
            Button("Copy RGB (\(color.rgb_code))") {
                AppState.shared.copyColor(color, format: .rgb)
            }
            Button("Copy HSL (\(color.hsl_code))") {
                AppState.shared.copyColor(color, format: .hsl)
            }
            Button("Copy SwiftUI: Color(...)") {
                AppState.shared.copyColor(color, format: .swiftUI)
            }
            Button("Copy UIKit: UIColor(...)") {
                AppState.shared.copyColor(color, format: .uiKit)
            }
            Button("Copy CSS Variable: --color-...") {
                AppState.shared.copyColor(color, format: .css)
            }
            Button("Copy Tailwind CSS Snippet") {
                AppState.shared.copyColor(color, format: .tailwind)
            }
            Button("Copy Jetpack Compose Color(...)") {
                AppState.shared.copyColor(color, format: .jetpackCompose)
            }
            Button("Copy Flutter Color(...)") {
                AppState.shared.copyColor(color, format: .flutter)
            }
            Divider()
            if let onSelectAsBase = onSelectAsBase {
                Button("Set as Base Color") {
                    onSelectAsBase(color)
                }
            }
            Button(isFav ? "Remove from Favorites ⭐" : "Add to Permanent Favorites ⭐") {
                AppState.shared.toggleFavorite(color: color)
            }
        }
    }
}
