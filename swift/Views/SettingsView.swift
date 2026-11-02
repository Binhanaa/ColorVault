import SwiftUI
import AppKit

public struct SettingsView: View {
    @Bindable var state: AppState = AppState.shared

    public init(state: AppState = AppState.shared) {
        self.state = state
    }

    private var isAr: Bool {
        state.selectedLanguage == .arabic
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                // Section 1: Appearance & Theme
                sectionBox(title: isAr ? "المظهر والسمة" : "Appearance & Theme", icon: "circle.righthalf.filled") {
                    VStack(spacing: 10) {
                        HStack {
                            Text(isAr ? "نمط السمة:" : "Theme Mode:")
                                .font(.system(size: 11, weight: .semibold))
                            Spacer()
                            Picker("", selection: $state.selectedTheme) {
                                ForEach(AppTheme.allCases) { theme in
                                    Text(themeLabel(theme)).tag(theme)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .frame(width: 210)
                        }

                        Divider()

                        HStack {
                            Text(isAr ? "لغة التطبيق:" : "App Language:")
                                .font(.system(size: 11, weight: .semibold))
                            Spacer()
                            Picker("", selection: $state.selectedLanguage) {
                                ForEach(AppLanguage.allCases) { lang in
                                    Text(lang.rawValue).tag(lang)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .frame(width: 170)
                        }
                    }
                }

                // Section 2: Developer Default Copy Format
                sectionBox(title: isAr ? "صيغة النسخ الافتراضية بنقرة واحدة" : "Default 1-Click Copy Format", icon: "curlybraces") {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(isAr ? "اختر صيغة الكود التي تُنسخ تلقائيًا إلى الحافظة عند النقر المباشر على أي لون:" : "Choose the code format copied to clipboard when clicking any swatch:")
                            .font(.system(size: 10.5))
                            .foregroundColor(.secondary)

                        Picker("", selection: $state.defaultCopyFormat) {
                            ForEach(CopyFormat.allCases) { format in
                                Text(format.rawValue).tag(format)
                            }
                        }
                        .labelsHidden()
                        .pickerStyle(MenuPickerStyle())
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }

                // Section 3: Behavior & UI Modules
                sectionBox(title: isAr ? "السلوك والخصائص" : "Behavior & Features", icon: "slider.horizontal.2.square") {
                    VStack(spacing: 9) {
                        HStack {
                            VStack(alignment: .leading, spacing: 1.5) {
                                Text(isAr ? "المؤثرات الصوتية عند النسخ" : "Sound Effects on Copy")
                                    .font(.system(size: 11, weight: .semibold))
                                Text(isAr ? "تشغيل صوت تنبيه عند نسخ الألوان (معطل افتراضيًا)" : "Play sound when copying color (Disabled by default)")
                                    .font(.system(size: 9.5))
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Toggle("", isOn: $state.enableSound)
                                .labelsHidden()
                                .focusable(false)
                        }

                        Divider()

                        HStack {
                            VStack(alignment: .leading, spacing: 1.5) {
                                Text(isAr ? "تدرجات الواجهات (50-950 Tailwind)" : "Tailwind UI Lightness Scale (50-950)")
                                    .font(.system(size: 11, weight: .semibold))
                                Text(isAr ? "عرض شريط درجات Tailwind للون الأساسي في تبويب التناسق" : "Display 50-950 lightness shades in Harmonies tab")
                                    .font(.system(size: 9.5))
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Toggle("", isOn: $state.showShadesSection)
                                .labelsHidden()
                                .focusable(false)
                        }
                    }
                }

                // Section 4: Database & SQLite Storage
                sectionBox(title: isAr ? "قاعدة بيانات التطبيق والتخزين الدائم (SQLite)" : "Local Database & Storage (SQLite)", icon: "cylinder.split.1x2") {
                    VStack(alignment: .leading, spacing: 9) {
                        HStack(spacing: 14) {
                            statBadge(title: isAr ? "المفضلة الدائمة" : "Favorites", value: "\(state.permanentFavorites.count)")
                            statBadge(title: isAr ? "المجموعات" : "Palettes", value: "\(state.customSavedPalettes.count)")
                            statBadge(title: isAr ? "سجل الألوان" : "History Log", value: "\(state.historyRecords.count)")
                            statBadge(title: isAr ? "محرك التخزين" : "Engine", value: "Rust SQLite")
                        }

                        Divider()

                        HStack(spacing: 8) {
                            Button(action: {
                                state.clearHistory()
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "trash")
                                    Text(isAr ? "مسح السجل المؤقت" : "Clear History Log")
                                }
                                .font(.system(size: 10.5, weight: .medium))
                                .foregroundColor(.red)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4.5)
                                .background(RoundedRectangle(cornerRadius: 6).fill(Color.red.opacity(0.1)))
                            }
                            .buttonStyle(PlainButtonStyle())
                            .focusable(false)

                            Spacer()

                            Button(action: exportDatabaseJson) {
                                HStack(spacing: 4) {
                                    Image(systemName: "square.and.arrow.up")
                                    Text(isAr ? "تصدير السجل كـ JSON" : "Export JSON")
                                }
                                .font(.system(size: 10.5, weight: .medium))
                                .foregroundColor(.accentColor)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4.5)
                                .background(RoundedRectangle(cornerRadius: 6).fill(Color.accentColor.opacity(0.1)))
                            }
                            .buttonStyle(PlainButtonStyle())
                            .focusable(false)
                        }
                    }
                }

                // Section 5: Open Source & About
                sectionBox(title: isAr ? "حول ColorVault Pro" : "About ColorVault Pro", icon: "info.circle") {
                    VStack(alignment: .leading, spacing: 5) {
                        infoRow(label: isAr ? "الإصدار:" : "Version:", value: "1.2.0 (Bama Tools Pro)")
                        infoRow(label: isAr ? "الترخيص:" : "License:", value: "MIT (Open Source & Free)")
                        infoRow(label: isAr ? "محرك الحسابات:" : "Engine:", value: "Rust Core v1.0.0 (Zero-Allocation FFI)")
                        infoRow(label: isAr ? "واجهة المستخدم:" : "UI Framework:", value: "Native AppKit & SwiftUI (Observation)")
                        infoRow(label: isAr ? "المنصة المستهدفة:" : "Target:", value: "macOS 14+ (Apple Silicon & Intel)")
                    }
                }
            }
            .padding(13)
        }
    }

    private func themeLabel(_ theme: AppTheme) -> String {
        guard isAr else { return theme.rawValue }
        switch theme {
        case .system: return "تلقائي"
        case .dark: return "داكن"
        case .light: return "فاتح"
        }
    }

    private func sectionBox<Content: View>(title: String, icon: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.accentColor)
                Text(title)
                    .font(.system(size: 11.5, weight: .bold))
                    .foregroundColor(.primary)
            }

            content()
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(NSColor.controlBackgroundColor).opacity(0.6))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.primary.opacity(0.08), lineWidth: 0.8)
        )
    }

    private func statBadge(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(title)
                .font(.system(size: 9))
                .foregroundColor(.secondary)
            Text(value)
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(.primary)
        }
    }

    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 10.5, weight: .semibold))
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.system(size: 10.5, design: .monospaced))
                .foregroundColor(.primary)
        }
    }

    private func exportDatabaseJson() {
        struct ExportBundle: Codable {
            let favorites: [FavoriteRecord]
            let palettes: [SavedPaletteRecord]
            let history: [HistoryRecord]
        }
        let bundle = ExportBundle(
            favorites: state.permanentFavorites,
            palettes: state.customSavedPalettes,
            history: state.historyRecords
        )
        guard let data = try? JSONEncoder().encode(bundle),
              let json = String(data: data, encoding: .utf8) else { return }
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(json, forType: .string)
        state.showCheckmarkToast(text: "Database exported to clipboard as JSON")
    }
}
