# ColorVault Pro 🎨

[![macOS](https://img.shields.io/badge/macOS-14.0%2B-blue.svg?logo=apple)](https://apple.com)
[![Rust](https://img.shields.io/badge/Rust-2021_Edition-orange.svg?logo=rust)](https://www.rust-lang.org)
[![Swift](https://img.shields.io/badge/Swift-5.10-red.svg?logo=swift)](https://swift.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Engine: SQLite](https://img.shields.io/badge/Database-SQLite_WAL-003B57.svg?logo=sqlite)](https://sqlite.org)

**ColorVault Pro** is a native macOS menu bar app for people who pick, store, and ship colors. It keeps a library of colors and palettes, builds harmonies, checks contrast, and copies values for Swift, CSS, Tailwind, Flutter, and Android. The interface is SwiftUI. Color math and the database run in Rust.

Colors, favorites, and palettes stay in a SQLite file on this Mac. Contrast uses the WCAG 2.1 ratios, 4.5:1 for AA and 7:1 for AAA. There is no account, and the library is not uploaded.

## Install

macOS 14 or later.

1. Download [ColorVault.dmg](https://github.com/Binhanaa/ColorVault/releases/latest/download/ColorVault.dmg) from [Releases](https://github.com/Binhanaa/ColorVault/releases).
2. Open the disk image and drag **ColorVault** to **Applications**.
3. Open ColorVault. It lives in the menu bar.

---

## ✨ Key Features

- **Native Menu Bar Extra (`LSUIElement = true`)**:
  - Opens from the menu bar. The app does not take a Dock icon.
  - Translucent frosted-glass backdrop (`NSVisualEffectView`) blending seamlessly into macOS Sonoma & Sequoia.
- **Interactive Chromatic Color Wheel**:
  - Direct 360° circular hue & saturation wheel with live real-time drag-and-pick response.
  - Eliminates clunky multi-slider controls for an intuitive, visual, and fast design workflow.
  - Integrated with native eyedropper, hex input, and curated designer swatches.
  - Zero reliance on external macOS `NSColorPanel` popups.
- **Permanent SQLite Storage (WAL Mode)**:
  - Every sampled or tested color is instantly persisted with auto-incremented usage metrics.
  - Dedicated **Permanent Favorites** table that persists forever across app restarts and history clears.
  - Custom palette studio with custom collection naming, tags, and multi-color builds.
- **Smart Color Harmonies (Duos, Trios, Tetrads)**:
  - Real-time mathematical generation of complementary, analogous, triadic, split-complementary, and tetradic chords.
  - Harmony math runs in the Rust library and is called from Swift.
- **Deep Contrast & Accessibility Auditor**:
  - Exact WCAG 2.1 contrast ratio calculations (`4.5:1` AA / `7.0:1` AAA ratings).
  - Live side-by-side simulated UI previews (Buttons, Cards, Text Legibility).
  - **1-Click Auto-Fix Contrast Tool**: Algorithmic shade calculation that automatically adjusts any color pair to pass AA or AAA contrast standards.
  - Complete Color Vision Deficiency (CVD) simulator: Protanopia, Deuteranopia, Tritanopia, and Achromatopsia.
- **Tailwind UI 50–950 Lightness Scale**:
  - Instant generation of complete design system lightness steps for any base color.
  - Direction-aware layout: intuitive 50–950 progression in both English (LTR) and Arabic (RTL).
- **1-Click Developer Code Export**:
  - `HEX (#4F46E5)` & `HEX Raw (4F46E5)`
  - `RGB rgb(79, 70, 229)` & `HSL hsl(243, 75%, 60%)`
  - `SwiftUI Color(red: ..., green: ..., blue: ...)`
  - `UIKit UIColor(red: ..., green: ..., blue: ..., alpha: 1.0)`
  - `CSS Variable (--color-primary: ...)`
  - `Tailwind CSS ('brand': '#4F46E5')`
  - `Jetpack Compose Color(0xFF4F46E5)`
  - `Flutter Color(0xFF4F46E5)`
  - `Android XML <color name="...">#4F46E5</color>`
- **Silent & Ergonomic UX**:
  - Silent by default with unobtrusive floating checkmarks (optional audio cues configurable in Settings).
  - Complete bilingual support: **English** (Default) and **Arabic** with full native RTL mirror layout.
  - Dark Mode, Light Mode, and System Theme adaptation.

---

## 🏛 Systems Architecture

```
┌────────────────────────────────────────────────────────┐
│           macOS Menu Bar Popover (Frosted HUD)         │
│     SwiftUI (Observation Engine) + Native AppKit       │
└───────────────────────────┬────────────────────────────┘
                            │ C FFI Bridge (RustBridge.swift)
┌───────────────────────────▼────────────────────────────┐
│            Rust Engine (colorvault_core)               │
│  - HSL / RGB / OkLab / Delta-E Color Math              │
│  - WCAG 2.1 Contrast & 1-Click Auto-Fix Algorithms     │
│  - Brettel-Viénot-Mollon CVD Vision Simulator          │
│  - SQLite 3 (WAL Journaling via Rusqlite)              │
└────────────────────────────────────────────────────────┘
```

---

## 🛠 Building from Source

### Prerequisites

- macOS 14.0 (Sonoma) or newer.
- Xcode Command Line Tools (`xcode-select --install`).
- Rust toolchain (`curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh`).

### Build Instructions

1. Clone the repository:
   ```bash
   git clone https://github.com/Binhanaa/ColorVault.git
   cd ColorVault
   ```

2. Compile the Rust dynamic library and native Swift application:
   ```bash
   chmod +x scripts/build.sh
   ./scripts/build.sh
   ```

3. Package into a distributable DMG:
   ```bash
   chmod +x scripts/create_dmg.sh
   ./scripts/create_dmg.sh
   ```
   The finished installer will be output directly to `build/ColorVault.dmg` and your Desktop as `ColorVault.dmg`.

---

## 🤝 Contributing

Contributions, issues, and feature requests are welcome. Please use the [issues page](https://github.com/Binhanaa/ColorVault/issues).

1. Fork the Project.
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`).
3. Commit your Changes (`git commit -m 'feat: Add some AmazingFeature'`).
4. Push to the Branch (`git push origin feature/AmazingFeature`).
5. Open a Pull Request.

---

## 📄 License

Distributed under the **MIT License**. See [LICENSE](LICENSE) for more information. Free for personal, commercial, and open-source use.
