# ColorVault Pro 🎨

[![macOS](https://img.shields.io/badge/macOS-14.0%2B-blue.svg?logo=apple)](https://apple.com)
[![Rust](https://img.shields.io/badge/Rust-2021_Edition-orange.svg?logo=rust)](https://www.rust-lang.org)
[![Swift](https://img.shields.io/badge/Swift-5.10-red.svg?logo=swift)](https://swift.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Engine: SQLite](https://img.shields.io/badge/Database-SQLite_WAL-003B57.svg?logo=sqlite)](https://sqlite.org)

**ColorVault Pro** is a high-performance native macOS menu bar extra application engineered in **Rust** and **Swift/SwiftUI**. It serves as an all-in-one color storage vault, real-time harmony engine, contrast auditor, and palette workstation built specifically for UI/UX designers and modern frontend developers.

Built strictly according to Apple's Human Interface Guidelines (HIG) and Bama Tools Precision standards.

---

## ✨ Features

- **Menu Bar Extra (`LSUIElement = true`)**: Instant access from the macOS menu bar at zero cost to dock space or CPU footprint.
- **Permanent SQLite Storage (WAL Mode)**:
  - Every color sampled or copied is automatically logged.
  - Dedicated **Permanent Favorites** table that persists forever across app restarts and history clears.
  - Custom palette creator with custom naming, tags, and multi-color collections.
- **Custom In-App Color Picker**:
  - Direct HSL/RGB and HEX fine-tuning sliders.
  - Zero reliance on macOS `NSColorPanel` modal windows.
  - Seamless screen eyedropper with zero blue focus rings or outlines.
- **Smart Color Harmonies (2, 3, 4 Colors)**:
  - Real-time generation of complementary, analogous, triadic, split-complementary, and tetradic chords.
  - Mathematical color wheel calculations powered by zero-allocation Rust FFI.
- **Deep Contrast & Accessibility Auditor**:
  - Precise WCAG 2.1 contrast ratio calculations (`4.5:1` AA / `7.0:1` AAA).
  - Simulated real-world UI previews (Cards, Buttons, Text legibility).
  - **1-Click Auto-Fix Contrast Tool**: Automatically calculates the exact mathematical shade required to pass AA or AAA standards.
  - Complete Color Vision Deficiency (CVD) simulator: Protanopia, Deuteranopia, Tritanopia, and Achromatopsia.
- **Tailwind 50–950 UI Lightness Shades**: Instant generation of complete design system lightness steps for any base color.
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
- **Silent & Unobtrusive UX**:
  - Zero system beeps or audio interrupts on copy (sound effects can be enabled optionally in Settings).
  - Lightweight animated checkmark indicators and non-blocking toast notifications.
  - Fully bilingual interface: **English** (Primary/Default) and **Arabic** with full RTL layout support.
  - Dark Mode, Light Mode, and System Theme adaptation.

---

## 🏛 Architecture

ColorVault Pro utilizes a split-core native architecture:

```
┌──────────────────────────────────────────────────┐
│              macOS Menu Bar Popover              │
│       SwiftUI (Observation) + AppKit Core        │
└────────────────────────┬─────────────────────────┘
                         │ C FFI Bridge (RustBridge.swift)
┌────────────────────────▼─────────────────────────┐
│            Rust Engine (colorvault_core)         │
│  - HSL / RGB / OkLab Color Math                  │
│  - WCAG 2.1 Contrast Calculations                │
│  - Brettel-Viénot-Mollon Color Blindness Sim     │
│  - SQLite Engine (WAL Journaling via Rusqlite)   │
└──────────────────────────────────────────────────┘
```

---

## 🛠 Building from Source

### Prerequisites

- macOS 14.0 (Sonoma) or newer.
- Xcode Command Line Tools (`xcode-select --install`).
- Rust toolchain (`curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh`).

### Build Steps

1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/ColorVault.git
   cd ColorVault
   ```

2. Compile the Rust dynamic library and the native Swift App:
   ```bash
   chmod +x scripts/build.sh
   ./scripts/build.sh
   ```

3. Generate the distribution DMG installer:
   ```bash
   chmod +x scripts/create_dmg.sh
   ./scripts/create_dmg.sh
   ```
   The compiled `.dmg` will be placed on your Desktop as `ColorVault.dmg`.

---

## 📄 License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details. Free for both personal and commercial use.
