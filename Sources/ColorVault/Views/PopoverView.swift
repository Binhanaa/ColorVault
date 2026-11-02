import SwiftUI
import AppKit

public struct PopoverView: View {
    @State private var selectedTab: Int = 0
    @State private var baseHex: String = "#4F46E5"
    @State private var toastMessage: ToastMessage?
    @State private var toastTimer: Timer?

    public var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                // Top App Bar
                appHeader

                // Main Tab Bar
                tabBar

                Divider()

                // Active Tab Content
                Group {
                    switch selectedTab {
                    case 0:
                        HarmonyGeneratorView(
                            baseHex: $baseHex,
                            onToast: showToast
                        )
                    case 1:
                        PairMatcherView(
                            onToast: showToast
                        )
                    case 2:
                        CuratedPalettesView(
                            onSelectAsBase: { item in
                                baseHex = item.hex
                                selectedTab = 0
                                showToast("تم تعيين \(item.hex) كأساس", item.hex)
                            },
                            onToast: showToast
                        )
                    case 3:
                        HistoryVaultView(
                            onSelectAsBase: { item in
                                baseHex = item.hex
                                selectedTab = 0
                                showToast("تم تعيين \(item.hex) كأساس", item.hex)
                            },
                            onToast: showToast
                        )
                    default:
                        EmptyView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }

            // Animated Toast Notification
            if let toast = toastMessage {
                ToastView(message: toast)
                    .padding(.bottom, 16)
                    .zIndex(100)
            }
        }
        .frame(width: 480, height: 620)
        .background(VisualEffectBackground())
    }

    private var appHeader: some View {
        HStack(spacing: 10) {
            // App Icon
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#6366F1"), Color(hex: "#EC4899"), Color(hex: "#F59E0B")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 28, height: 28)
                Image(systemName: "paintpalette.fill")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 1) {
                HStack(spacing: 6) {
                    Text("ColorVault")
                        .font(.system(size: 14, weight: .heavy, design: .rounded))
                        .foregroundColor(.primary)
                    Text("خزنة الألوان")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.secondary)
                }
                Text("محرك تناسق الألوان السريع والمخزن الدائم")
                    .font(.system(size: 9))
                    .foregroundColor(.secondary)
            }

            Spacer()

            EyedropperButton(onColorPicked: { picked in
                baseHex = picked
                selectedTab = 0
            }, onToast: showToast)

            Button(action: {
                NSApplication.shared.terminate(nil)
            }) {
                Image(systemName: "power")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.secondary)
                    .padding(6)
                    .background(Circle().fill(Color.primary.opacity(0.06)))
            }
            .buttonStyle(PlainButtonStyle())
            .help("إغلاق التطبيق")
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color(NSColor.windowBackgroundColor).opacity(0.7))
    }

    private var tabBar: some View {
        HStack(spacing: 6) {
            tabButton(title: "التناسق والهارموني", icon: "slider.horizontal.3", tag: 0)
            tabButton(title: "فاحص التوافق", icon: "scale.3d", tag: 1)
            tabButton(title: "المجموعات", icon: "square.grid.2x2", tag: 2)
            tabButton(title: "الخزنة والسجل", icon: "archivebox.fill", tag: 3)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(NSColor.controlBackgroundColor).opacity(0.4))
    }

    private func tabButton(title: String, icon: String, tag: Int) -> some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.15)) {
                selectedTab = tag
            }
        }) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 11))
                Text(title)
                    .font(.system(size: 11, weight: selectedTab == tag ? .bold : .medium))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(selectedTab == tag ? Color.accentColor.opacity(0.15) : Color.clear)
            )
            .foregroundColor(selectedTab == tag ? Color.accentColor : Color.primary.opacity(0.8))
        }
        .buttonStyle(PlainButtonStyle())
    }

    private func showToast(_ text: String, _ hex: String? = nil) {
        toastTimer?.invalidate()
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            toastMessage = ToastMessage(text: text, colorHex: hex)
        }
        toastTimer = Timer.scheduledTimer(withTimeInterval: 2.2, repeats: false) { _ in
            withAnimation(.easeOut(duration: 0.2)) {
                self.toastMessage = nil
            }
        }
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
