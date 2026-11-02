import SwiftUI
import AppKit

public struct PopoverView: View {
    @Bindable var state: AppState = AppState.shared

    let tabsEn: [(id: Int, title: String, icon: String)] = [
        (0, "Harmonies", "slider.horizontal.3"),
        (1, "Contrast", "scale.3d"),
        (2, "Collections", "square.grid.2x2"),
        (3, "Vault", "archivebox.fill"),
        (4, "Settings", "gearshape.fill")
    ]

    let tabsAr: [(id: Int, title: String, icon: String)] = [
        (0, "التناسق", "slider.horizontal.3"),
        (1, "التوافق", "scale.3d"),
        (2, "المجموعات", "square.grid.2x2"),
        (3, "الخزنة", "archivebox.fill"),
        (4, "الإعدادات", "gearshape.fill")
    ]

    public init(state: AppState = AppState.shared) {
        self.state = state
    }

    var currentTabs: [(id: Int, title: String, icon: String)] {
        state.selectedLanguage == .arabic ? tabsAr : tabsEn
    }

    public var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                // Top App Bar
                appHeader

                // Main Tab Bar (Buttery Smooth, Instant Response)
                tabBar

                Divider()

                // Active Tab Content
                Group {
                    switch state.selectedTab {
                    case 0:
                        HarmonyGeneratorView()
                    case 1:
                        PairMatcherView()
                    case 2:
                        CuratedPalettesView()
                    case 3:
                        HistoryVaultView()
                    case 4:
                        SettingsView()
                    default:
                        EmptyView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }

            // Silent & Subtle Checkmark Toast
            if let toast = state.toastMessage {
                ToastView(message: toast)
                    .padding(.bottom, 14)
                    .zIndex(100)
            }
        }
        .frame(width: 490, height: 635)
        .background(VisualEffectBackground())
        .preferredColorScheme(state.selectedTheme.colorScheme)
        .environment(\.layoutDirection, state.selectedLanguage == .arabic ? .rightToLeft : .leftToRight)
        .focusEffectDisabled()
    }

    private var appHeader: some View {
        HStack(spacing: 9) {
            // Unified Fixed App Branding Logo
            ZStack {
                RoundedRectangle(cornerRadius: 7)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#6366F1"), Color(hex: "#EC4899"), Color(hex: "#F59E0B")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 26, height: 26)
                Image(systemName: "paintpalette.fill")
                    .font(.system(size: 12.5, weight: .bold))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 1) {
                HStack(spacing: 5) {
                    Text("ColorVault Pro")
                        .font(.system(size: 13, weight: .heavy, design: .rounded))
                        .foregroundColor(.primary)
                    Text("v1.2")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.accentColor)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 1)
                        .background(Capsule().fill(Color.accentColor.opacity(0.12)))
                }
                Text(state.selectedLanguage == .arabic ? "محرك تناسق الألوان السريع والمخزن الدائم" : "Professional Color Vault & Harmony Engine")
                    .font(.system(size: 8.5))
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Clean Eyedropper Button (Zero focus ring, zero blue outline)
            EyedropperButton(onColorPicked: { picked in
                state.setBaseHex(picked)
                state.selectedTab = 0
            })

            Button(action: {
                NSApplication.shared.terminate(nil)
            }) {
                Image(systemName: "power")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.secondary)
                    .padding(5)
                    .background(Circle().fill(Color.primary.opacity(0.06)))
                    .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
            .focusable(false)
            .help("Quit ColorVault")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(NSColor.windowBackgroundColor).opacity(0.75))
    }

    private var tabBar: some View {
        HStack(spacing: 3) {
            ForEach(currentTabs, id: \.id) { tab in
                Button(action: {
                    state.selectedTab = tab.id
                }) {
                    HStack(spacing: 3.5) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 9.5, weight: .medium))
                        Text(tab.title)
                            .font(.system(size: 10, weight: state.selectedTab == tab.id ? .bold : .medium))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 5.5)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(state.selectedTab == tab.id ? Color.accentColor : Color.clear)
                    )
                    .foregroundColor(state.selectedTab == tab.id ? .white : .primary.opacity(0.75))
                    .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
                .focusable(false)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
    }
}

// macOS Visual Effect background blur
struct VisualEffectBackground: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = .popover
        view.blendingMode = .behindWindow
        view.state = .active
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
}
