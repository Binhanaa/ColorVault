use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Copy, PartialEq, Serialize, Deserialize)]
pub struct Rgb {
    pub r: u8,
    pub g: u8,
    pub b: u8,
}

#[derive(Debug, Clone, Copy, PartialEq, Serialize, Deserialize)]
pub struct Hsl {
    pub h: f64, // 0.0 .. 360.0
    pub s: f64, // 0.0 .. 1.0
    pub l: f64, // 0.0 .. 1.0
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ColorItem {
    pub hex: String,
    pub r: u8,
    pub g: u8,
    pub b: u8,
    pub h: f64,
    pub s: f64,
    pub l: f64,
    pub name: String,
    // Developer export codes
    pub swift_code: String,
    pub uikit_code: String,
    pub css_code: String,
    pub rgb_code: String,
    pub hsl_code: String,
    pub tailwind_code: String,
    pub compose_code: String,
    pub flutter_code: String,
    pub android_xml: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ShadeItem {
    pub weight: u16, // 50, 100, 200, ..., 900
    pub color: ColorItem,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ColorBlindSimulation {
    pub normal: String,
    pub protanopia: String,
    pub deuteranopia: String,
    pub tritanopia: String,
    pub achromatopsia: String,
}

impl Rgb {
    pub fn new(r: u8, g: u8, b: u8) -> Self {
        Self { r, g, b }
    }

    pub fn to_hex(&self) -> String {
        format!("#{:02X}{:02X}{:02X}", self.r, self.g, self.b)
    }

    pub fn to_hex_no_hash(&self) -> String {
        format!("{:02X}{:02X}{:02X}", self.r, self.g, self.b)
    }

    pub fn to_hsl(&self) -> Hsl {
        let r = self.r as f64 / 255.0;
        let g = self.g as f64 / 255.0;
        let b = self.b as f64 / 255.0;

        let max = r.max(g.max(b));
        let min = r.min(g.min(b));
        let delta = max - min;

        let l = (max + min) / 2.0;

        let (h, s) = if delta == 0.0 {
            (0.0, 0.0)
        } else {
            let s = if l > 0.5 {
                delta / (2.0 - max - min)
            } else {
                delta / (max + min)
            };

            let h = if max == r {
                let segment = (g - b) / delta;
                let shift = if g < b { 6.0 } else { 0.0 };
                (segment + shift) * 60.0
            } else if max == g {
                let segment = (b - r) / delta;
                (segment + 2.0) * 60.0
            } else {
                let segment = (r - g) / delta;
                (segment + 4.0) * 60.0
            };

            (h, s)
        };

        Hsl {
            h: (h + 360.0) % 360.0,
            s: s.clamp(0.0, 1.0),
            l: l.clamp(0.0, 1.0),
        }
    }

    /// WCAG relative luminance
    pub fn relative_luminance(&self) -> f64 {
        let to_linear = |val: u8| -> f64 {
            let c = val as f64 / 255.0;
            if c <= 0.03928 {
                c / 12.92
            } else {
                ((c + 0.055) / 1.055).powf(2.4)
            }
        };

        let r = to_linear(self.r);
        let g = to_linear(self.g);
        let b = to_linear(self.b);

        0.2126 * r + 0.7152 * g + 0.0722 * b
    }

    /// Calculate WCAG contrast ratio against another color (1.0 .. 21.0)
    pub fn contrast_ratio(&self, other: &Rgb) -> f64 {
        let l1 = self.relative_luminance();
        let l2 = other.relative_luminance();
        let (bright, dark) = if l1 > l2 { (l1, l2) } else { (l2, l1) };
        (bright + 0.05) / (dark + 0.05)
    }

    /// Simulate color blindness with standard transformation matrices
    pub fn simulate_deficiency(&self, mode: &str) -> Rgb {
        let r = self.r as f64 / 255.0;
        let g = self.g as f64 / 255.0;
        let b = self.b as f64 / 255.0;

        let (nr, ng, nb) = match mode {
            "protanopia" => (
                0.56667 * r + 0.43333 * g,
                0.55833 * r + 0.44167 * g,
                0.24167 * g + 0.75833 * b,
            ),
            "deuteranopia" => (
                0.625 * r + 0.375 * g,
                0.70 * r + 0.30 * g,
                0.30 * g + 0.70 * b,
            ),
            "tritanopia" => (
                0.95 * r + 0.05 * g,
                0.43333 * g + 0.56667 * b,
                0.475 * g + 0.525 * b,
            ),
            "achromatopsia" => {
                let gray = 0.299 * r + 0.587 * g + 0.114 * b;
                (gray, gray, gray)
            }
            _ => (r, g, b),
        };

        Rgb::new(
            (nr.clamp(0.0, 1.0) * 255.0).round() as u8,
            (ng.clamp(0.0, 1.0) * 255.0).round() as u8,
            (nb.clamp(0.0, 1.0) * 255.0).round() as u8,
        )
    }
}

impl Hsl {
    pub fn new(h: f64, s: f64, l: f64) -> Self {
        Self {
            h: (h % 360.0 + 360.0) % 360.0,
            s: s.clamp(0.0, 1.0),
            l: l.clamp(0.0, 1.0),
        }
    }

    pub fn to_rgb(&self) -> Rgb {
        if self.s == 0.0 {
            let gray = (self.l * 255.0).round() as u8;
            return Rgb::new(gray, gray, gray);
        }

        let q = if self.l < 0.5 {
            self.l * (1.0 + self.s)
        } else {
            self.l + self.s - (self.l * self.s)
        };
        let p = 2.0 * self.l - q;

        let hk = self.h / 360.0;
        let tr = (hk + 1.0 / 3.0).fract();
        let tg = hk;
        let tb = (hk - 1.0 / 3.0 + 1.0).fract();

        let color_calc = |tc: f64| -> f64 {
            let tc = (tc % 1.0 + 1.0) % 1.0;
            if tc < 1.0 / 6.0 {
                p + ((q - p) * 6.0 * tc)
            } else if tc < 1.0 / 2.0 {
                q
            } else if tc < 2.0 / 3.0 {
                p + ((q - p) * 6.0 * (2.0 / 3.0 - tc))
            } else {
                p
            }
        };

        Rgb::new(
            (color_calc(tr) * 255.0).round().clamp(0.0, 255.0) as u8,
            (color_calc(tg) * 255.0).round().clamp(0.0, 255.0) as u8,
            (color_calc(tb) * 255.0).round().clamp(0.0, 255.0) as u8,
        )
    }

    pub fn rotate_hue(&self, degrees: f64) -> Self {
        Self::new(self.h + degrees, self.s, self.l)
    }

    pub fn with_lightness(&self, l: f64) -> Self {
        Self::new(self.h, self.s, l.clamp(0.02, 0.98))
    }
}

pub fn parse_hex(hex_str: &str) -> Option<Rgb> {
    let clean = hex_str.trim().trim_start_matches('#');
    if clean.len() == 6 {
        let r = u8::from_str_radix(&clean[0..2], 16).ok()?;
        let g = u8::from_str_radix(&clean[2..4], 16).ok()?;
        let b = u8::from_str_radix(&clean[4..6], 16).ok()?;
        Some(Rgb::new(r, g, b))
    } else if clean.len() == 3 {
        let r = u8::from_str_radix(&clean[0..1].repeat(2), 16).ok()?;
        let g = u8::from_str_radix(&clean[1..2].repeat(2), 16).ok()?;
        let b = u8::from_str_radix(&clean[2..3].repeat(2), 16).ok()?;
        Some(Rgb::new(r, g, b))
    } else {
        None
    }
}

pub fn make_color_item(rgb: Rgb, name: &str) -> ColorItem {
    let hex = rgb.to_hex();
    let hex_no_hash = rgb.to_hex_no_hash();
    let hsl = rgb.to_hsl();

    let r_norm = rgb.r as f64 / 255.0;
    let g_norm = rgb.g as f64 / 255.0;
    let b_norm = rgb.b as f64 / 255.0;

    let swift_code = format!(
        "Color(red: {:.3}, green: {:.3}, blue: {:.3})",
        r_norm, g_norm, b_norm
    );

    let uikit_code = format!(
        "UIColor(red: {:.3}, green: {:.3}, blue: {:.3}, alpha: 1.0)",
        r_norm, g_norm, b_norm
    );

    let css_code = format!("--color-primary: {};", hex);
    let rgb_code = format!("rgb({}, {}, {})", rgb.r, rgb.g, rgb.b);
    let hsl_code = format!(
        "hsl({:.0}, {:.0}%, {:.0}%)",
        hsl.h,
        hsl.s * 100.0,
        hsl.l * 100.0
    );
    let tailwind_code = format!("'brand': '{}',", hex);
    let compose_code = format!("Color(0xFF{})", hex_no_hash);
    let flutter_code = format!("const Color(0xFF{})", hex_no_hash);
    let android_xml = format!("<color name=\"color_brand\">{}</color>", hex);

    ColorItem {
        hex,
        r: rgb.r,
        g: rgb.g,
        b: rgb.b,
        h: (hsl.h * 10.0).round() / 10.0,
        s: (hsl.s * 100.0).round() / 100.0,
        l: (hsl.l * 100.0).round() / 100.0,
        name: name.to_string(),
        swift_code,
        uikit_code,
        css_code,
        rgb_code,
        hsl_code,
        tailwind_code,
        compose_code,
        flutter_code,
        android_xml,
    }
}

/// Generates a Tailwind-style 50 .. 900 lightness shade scale for UI design systems
pub fn generate_shades(base_rgb: Rgb) -> Vec<ShadeItem> {
    let base_hsl = base_rgb.to_hsl();

    let scales: &[(u16, f64, f64)] = &[
        (50, 0.96, 0.60),
        (100, 0.91, 0.75),
        (200, 0.82, 0.85),
        (300, 0.70, 0.90),
        (400, 0.58, 0.95),
        (500, base_hsl.l, base_hsl.s), // Original
        (600, 0.44, 0.95),
        (700, 0.35, 0.90),
        (800, 0.25, 0.85),
        (900, 0.16, 0.80),
        (950, 0.09, 0.75),
    ];

    scales
        .iter()
        .map(|&(weight, target_l, target_s)| {
            let s = (base_hsl.s * target_s).clamp(0.1, 1.0);
            let hsl = Hsl::new(base_hsl.h, s, target_l);
            let rgb = hsl.to_rgb();
            let name = format!("{}-{}", base_rgb.to_hex(), weight);
            let item = make_color_item(rgb, &name);
            ShadeItem {
                weight,
                color: item,
            }
        })
        .collect()
}

/// Simulate all 4 color vision deficiencies
pub fn simulate_all(base_rgb: Rgb) -> ColorBlindSimulation {
    ColorBlindSimulation {
        normal: base_rgb.to_hex(),
        protanopia: base_rgb.simulate_deficiency("protanopia").to_hex(),
        deuteranopia: base_rgb.simulate_deficiency("deuteranopia").to_hex(),
        tritanopia: base_rgb.simulate_deficiency("tritanopia").to_hex(),
        achromatopsia: base_rgb.simulate_deficiency("achromatopsia").to_hex(),
    }
}

/// Adjusts foreground color lightness automatically to guarantee WCAG compliance (e.g. 4.5:1 or 7.0:1)
pub fn auto_fix_contrast(bg_rgb: Rgb, fg_rgb: Rgb, target_ratio: f64) -> ColorItem {
    let bg_lum = bg_rgb.relative_luminance();
    let fg_hsl = fg_rgb.to_hsl();

    // Decide if FG should be lighter or darker
    let make_lighter = bg_lum < 0.3; // If bg is dark, make fg light, otherwise dark

    let mut best_l = fg_hsl.l;
    let step = 0.02;

    for _ in 0..50 {
        let test_hsl = Hsl::new(fg_hsl.h, fg_hsl.s, best_l);
        let test_rgb = test_hsl.to_rgb();
        let cr = bg_rgb.contrast_ratio(&test_rgb);
        if cr >= target_ratio {
            return make_color_item(test_rgb, "Auto-Fixed Contrast");
        }
        if make_lighter {
            best_l = (best_l + step).min(0.98);
        } else {
            best_l = (best_l - step).max(0.04);
        }
    }

    let final_hsl = Hsl::new(fg_hsl.h, fg_hsl.s, best_l);
    make_color_item(final_hsl.to_rgb(), "Auto-Fixed Contrast")
}
