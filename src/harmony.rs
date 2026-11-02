use serde::{Deserialize, Serialize};
use crate::color::{make_color_item, ColorItem, Rgb};
use crate::names::find_closest_name;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct HarmonyGroup {
    pub id: String,
    pub title: String,
    pub title_ar: String,
    pub count: usize, // 2, 3, 4
    pub description: String,
    pub colors: Vec<ColorItem>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct HarmonyResult {
    pub base_color: ColorItem,
    pub duos: Vec<HarmonyGroup>,
    pub trios: Vec<HarmonyGroup>,
    pub tetrads: Vec<HarmonyGroup>,
}

pub fn generate_harmonies(base_rgb: Rgb) -> HarmonyResult {
    let base_hsl = base_rgb.to_hsl();
    let base_name = find_closest_name(&base_rgb);
    let base_item = make_color_item(base_rgb, &base_name);

    // Helper to turn HSL into ColorItem
    let to_item = |h: f64, s: f64, l: f64| -> ColorItem {
        let hsl = crate::color::Hsl::new(h, s, l);
        let rgb = hsl.to_rgb();
        let name = find_closest_name(&rgb);
        make_color_item(rgb, &name)
    };

    // --- 2-COLOR DUOS (تناسق لونين) ---
    let mut duos = Vec::new();

    // 1. Complementary (المكمل المباشر)
    {
        let c2 = to_item(base_hsl.h + 180.0, base_hsl.s, base_hsl.l);
        duos.push(HarmonyGroup {
            id: "duo_complementary".into(),
            title: "Complementary Duo".into(),
            title_ar: "مكمل مباشر (تناغم متضاد)".into(),
            count: 2,
            description: "180° opposite on color wheel — maximum visual punch".into(),
            colors: vec![base_item.clone(), c2],
        });
    }

    // 2. High Contrast UI Pair (ثنائي تباين احترافي للواجهات)
    {
        let dark_bg = base_hsl.l < 0.5;
        let c2 = if dark_bg {
            to_item(base_hsl.h, 0.15, 0.95) // Light text / accent
        } else {
            to_item(base_hsl.h, 0.35, 0.12) // Dark text / accent
        };
        duos.push(HarmonyGroup {
            id: "duo_contrast".into(),
            title: "UI Contrast Pair".into(),
            title_ar: "ثنائي تباين عالي للواجهات".into(),
            count: 2,
            description: "High WCAG contrast ratio for perfect legibility".into(),
            colors: vec![base_item.clone(), c2],
        });
    }

    // 3. Warm-Cool Balance (توازن دافئ وبارد)
    {
        let c2 = to_item(base_hsl.h + 140.0, base_hsl.s.min(0.85), base_hsl.l.max(0.4));
        duos.push(HarmonyGroup {
            id: "duo_warm_cool".into(),
            title: "Warm & Cool Balance".into(),
            title_ar: "توازن الدفء والبرودة".into(),
            count: 2,
            description: "Harmonious contrast between warm and cool spectrums".into(),
            colors: vec![base_item.clone(), c2],
        });
    }

    // 4. Soft Analogous Duo (ثنائي متجاور ناعم)
    {
        let c2 = to_item(base_hsl.h + 35.0, (base_hsl.s * 0.9).max(0.2), base_hsl.l);
        duos.push(HarmonyGroup {
            id: "duo_analogous".into(),
            title: "Soft Analogous Duo".into(),
            title_ar: "ثنائي متجاور ناعم ومريح".into(),
            count: 2,
            description: "35° shift for tranquil, cohesive design".into(),
            colors: vec![base_item.clone(), c2],
        });
    }

    // --- 3-COLOR TRIOS (تناسق ثلاثة ألوان) ---
    let mut trios = Vec::new();

    // 1. Triadic (ثلاثي متساوي الأبعاد)
    {
        let c2 = to_item(base_hsl.h + 120.0, base_hsl.s, base_hsl.l);
        let c3 = to_item(base_hsl.h + 240.0, base_hsl.s, base_hsl.l);
        trios.push(HarmonyGroup {
            id: "trio_triadic".into(),
            title: "Triadic Harmony".into(),
            title_ar: "تناغم ثلاثي متوازن (120°)".into(),
            count: 3,
            description: "Equidistant 120° harmony providing rich, balanced energy".into(),
            colors: vec![base_item.clone(), c2, c3],
        });
    }

    // 2. Split-Complementary (منقسم مكمل)
    {
        let c2 = to_item(base_hsl.h + 150.0, base_hsl.s, base_hsl.l);
        let c3 = to_item(base_hsl.h + 210.0, base_hsl.s, base_hsl.l);
        trios.push(HarmonyGroup {
            id: "trio_split".into(),
            title: "Split-Complementary".into(),
            title_ar: "ثلاثي منقسم مكمل (دقيق وراقي)".into(),
            count: 3,
            description: "Base color paired with adjacent colors of its complement".into(),
            colors: vec![base_item.clone(), c2, c3],
        });
    }

    // 3. Analogous Trio (ثلاثي متجاور طبيعي)
    {
        let c2 = to_item(base_hsl.h - 30.0, base_hsl.s, base_hsl.l);
        let c3 = to_item(base_hsl.h + 30.0, base_hsl.s, base_hsl.l);
        trios.push(HarmonyGroup {
            id: "trio_analogous".into(),
            title: "Analogous Trio".into(),
            title_ar: "ثلاثي متجاور طبيعي ومريح".into(),
            count: 3,
            description: "Colors adjacent on the color wheel, serene and organic".into(),
            colors: vec![c2, base_item.clone(), c3],
        });
    }

    // 4. Modern Accent Trio (ثنائي أساسي + لمسة حيادية)
    {
        let c2 = to_item(base_hsl.h + 180.0, base_hsl.s, (base_hsl.l + 0.15).min(0.9));
        let c3 = to_item(base_hsl.h + 40.0, 0.15, 0.92); // Clean light neutral tint
        trios.push(HarmonyGroup {
            id: "trio_accent_neutral".into(),
            title: "Hero & Neutral Trio".into(),
            title_ar: "لون رئيسي ومكمل مع لمسة حيادية".into(),
            count: 3,
            description: "Primary, vivid secondary and soft ambient background".into(),
            colors: vec![base_item.clone(), c2, c3],
        });
    }

    // --- 4-COLOR TETRADS (تناسق أربعة ألوان) ---
    let mut tetrads = Vec::new();

    // 1. Tetradic Rectangle (رباعي مستطيل - زوجان متكاملان)
    {
        let c2 = to_item(base_hsl.h + 60.0, base_hsl.s, base_hsl.l);
        let c3 = to_item(base_hsl.h + 180.0, base_hsl.s, base_hsl.l);
        let c4 = to_item(base_hsl.h + 240.0, base_hsl.s, base_hsl.l);
        tetrads.push(HarmonyGroup {
            id: "tetrad_rectangle".into(),
            title: "Tetradic Rectangle".into(),
            title_ar: "رباعي مستطيل (زوجان متكاملان)".into(),
            count: 4,
            description: "Two complementary color pairs forming a rich palette".into(),
            colors: vec![base_item.clone(), c2, c3, c4],
        });
    }

    // 2. Square Harmony (رباعي متساوي 90°)
    {
        let c2 = to_item(base_hsl.h + 90.0, base_hsl.s, base_hsl.l);
        let c3 = to_item(base_hsl.h + 180.0, base_hsl.s, base_hsl.l);
        let c4 = to_item(base_hsl.h + 270.0, base_hsl.s, base_hsl.l);
        tetrads.push(HarmonyGroup {
            id: "tetrad_square".into(),
            title: "Square Harmony (90°)".into(),
            title_ar: "رباعي مربع متساوي الزوايا".into(),
            count: 4,
            description: "Evenly spaced 90° intervals creating vivid dynamic energy".into(),
            colors: vec![base_item.clone(), c2, c3, c4],
        });
    }

    // 3. Analogous with Accent Pop (متجاور ثلاثي مع لون بارز)
    {
        let c2 = to_item(base_hsl.h - 30.0, base_hsl.s, base_hsl.l);
        let c3 = to_item(base_hsl.h + 30.0, base_hsl.s, base_hsl.l);
        let c4 = to_item(base_hsl.h + 180.0, (base_hsl.s + 0.1).min(1.0), (base_hsl.l + 0.05).min(0.9));
        tetrads.push(HarmonyGroup {
            id: "tetrad_accent".into(),
            title: "Analogous + Pop Accent".into(),
            title_ar: "ثلاثي متجاور مع لون تمييز بارز".into(),
            count: 4,
            description: "3 harmonious flow colors plus 1 high-impact focal accent".into(),
            colors: vec![c2, base_item.clone(), c3, c4],
        });
    }

    // 4. UI Design System Palette (نظام ألوان متكامل لواجهة مستخدم)
    {
        let brand = base_item.clone();
        let surface = to_item(base_hsl.h, 0.10, if base_hsl.l < 0.5 { 0.15 } else { 0.97 });
        let accent = to_item(base_hsl.h + 150.0, 0.85, 0.55);
        let text = to_item(base_hsl.h, 0.15, if base_hsl.l < 0.5 { 0.95 } else { 0.10 });
        tetrads.push(HarmonyGroup {
            id: "tetrad_ui_system".into(),
            title: "UI Design System".into(),
            title_ar: "نظام ألوان واجهة وتطبيقات كامل".into(),
            count: 4,
            description: "Brand, Surface, Accent, and High-Contrast Text".into(),
            colors: vec![brand, surface, accent, text],
        });
    }

    HarmonyResult {
        base_color: base_item,
        duos,
        trios,
        tetrads,
    }
}
