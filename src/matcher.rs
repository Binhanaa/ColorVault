use serde::{Deserialize, Serialize};
use crate::color::{auto_fix_contrast, make_color_item, ColorItem, Rgb};
use crate::names::find_closest_name;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct MatchEvaluation {
    pub color1: ColorItem,
    pub color2: ColorItem,
    pub score_pct: u32,
    pub relationship: String,
    pub relationship_ar: String,
    pub contrast_ratio: f64,
    pub wcag_rating: String,
    pub advice_ar: String,
    pub advice_en: String,
    pub suggested_trio_color: ColorItem,
    pub suggested_tetrad_color: ColorItem,
    pub auto_fixed_color2_aa: ColorItem,
    pub auto_fixed_color2_aaa: ColorItem,
}

pub fn evaluate_pair(rgb1: Rgb, rgb2: Rgb) -> MatchEvaluation {
    let name1 = find_closest_name(&rgb1);
    let name2 = find_closest_name(&rgb2);
    let c1 = make_color_item(rgb1, &name1);
    let c2 = make_color_item(rgb2, &name2);

    let hsl1 = rgb1.to_hsl();
    let hsl2 = rgb2.to_hsl();

    // Hue angle difference (0 to 180)
    let raw_diff = (hsl1.h - hsl2.h).abs();
    let hue_diff = if raw_diff > 180.0 {
        360.0 - raw_diff
    } else {
        raw_diff
    };

    let contrast = rgb1.contrast_ratio(&rgb2);
    let contrast_rounded = (contrast * 100.0).round() / 100.0;

    let wcag_rating = if contrast >= 7.0 {
        "AAA (استثنائي)".to_string()
    } else if contrast >= 4.5 {
        "AA (ممتاز للنصوص)".to_string()
    } else if contrast >= 3.0 {
        "AA Large (مناسب للعناوين والأيقونات)".to_string()
    } else {
        "منخفض (يفضل للأشكال أو التدرجات)".to_string()
    };

    // Calculate score based on classical color theory
    let (score, rel, rel_ar, adv_ar, adv_en) = if hue_diff <= 15.0 {
        // Monochromatic / Subtle
        let _sat_diff = (hsl1.s - hsl2.s).abs();
        let light_diff = (hsl1.l - hsl2.l).abs();
        let s = if light_diff > 0.35 { 95 } else if light_diff > 0.2 { 85 } else { 70 };
        (
            s,
            "Monochromatic Pair".to_string(),
            "تناغم أحادي ناعم (درجات نفس اللون)".to_string(),
            "ممتاز جداً لإنشاء واجهة هادئة وأنيقة، تباين الإضاءة مريح جداً للعين.".to_string(),
            "Subtle monochromatic harmony, very cohesive and elegant.".to_string(),
        )
    } else if (hue_diff - 30.0).abs() <= 15.0 {
        // Analogous
        (
            92,
            "Analogous Harmony".to_string(),
            "ألوان متجاورة طبيعية".to_string(),
            "هذان اللونان يتماشيان معاً بشكل رائع ويعطيان طابعاً طبيعياً مريحاً.".to_string(),
            "Naturally harmonious neighboring hues, smooth and pleasing transition.".to_string(),
        )
    } else if (hue_diff - 120.0).abs() <= 15.0 {
        // Triadic relationship
        (
            88,
            "Triadic Dynamic Pair".to_string(),
            "علاقة ثلاثية حيوية".to_string(),
            "لونان يمثلان ثلثي التناغم الثلاثي، يجذبان الانتباه بتوازن ممتع.".to_string(),
            "Two corners of a triadic chord, vibrant and visually stimulating.".to_string(),
        )
    } else if (hue_diff - 180.0).abs() <= 20.0 {
        // Complementary
        (
            98,
            "Complementary Contrast".to_string(),
            "تناغم مكمل مباشر (قمة التباين)".to_string(),
            "أقصى درجات التناسق الجذاب! ممتاز للتمييز ولفت انتباه المستخدم للأزرار والعناصر المهمة.".to_string(),
            "Maximum complementary contrast, perfect for call-to-actions and hero branding.".to_string(),
        )
    } else if (hue_diff - 150.0).abs() <= 15.0 {
        // Split-Complementary
        (
            90,
            "Split-Complementary Pair".to_string(),
            "منقسم مكمل راقي".to_string(),
            "تناغم مكمل منقسم يقدم تبايناً جذاباً وأقل حدة من التناغم المكمل المباشر.".to_string(),
            "Split-complementary provides nuanced contrast without clashing.".to_string(),
        )
    } else {
        // General pair
        let score = if contrast >= 4.5 { 80 } else { 65 };
        (
            score,
            "Custom Duo".to_string(),
            "مزيج لوني مخصص".to_string(),
            "مزيج عصري غير تقليدي، يمكنك تعزيز التناغم بتعديل تشبع أو إضاءة أحد اللونين.".to_string(),
            "Creative modern mix. Balance lightness to enhance harmony.".to_string(),
        )
    };

    // Calculate third color suggestion (to complete a trio!)
    let third_hue = (hsl1.h + 120.0) % 360.0;
    let third_hsl = crate::color::Hsl::new(third_hue, hsl1.s, (hsl1.l + hsl2.l) / 2.0);
    let third_rgb = third_hsl.to_rgb();
    let third_name = find_closest_name(&third_rgb);
    let suggested_trio = make_color_item(third_rgb, &third_name);

    // Calculate fourth color suggestion (to complete a tetrad!)
    let fourth_hue = (hsl2.h + 180.0) % 360.0;
    let fourth_hsl = crate::color::Hsl::new(fourth_hue, (hsl2.s * 0.9).max(0.3), (1.0 - hsl2.l).clamp(0.2, 0.85));
    let fourth_rgb = fourth_hsl.to_rgb();
    let fourth_name = find_closest_name(&fourth_rgb);
    let suggested_tetrad = make_color_item(fourth_rgb, &fourth_name);

    // Auto-fix contrast for AA (4.5) and AAA (7.0)
    let auto_aa = auto_fix_contrast(rgb1, rgb2, 4.5);
    let auto_aaa = auto_fix_contrast(rgb1, rgb2, 7.0);

    MatchEvaluation {
        color1: c1,
        color2: c2,
        score_pct: score,
        relationship: rel,
        relationship_ar: rel_ar,
        contrast_ratio: contrast_rounded,
        wcag_rating,
        advice_ar: adv_ar,
        advice_en: adv_en,
        suggested_trio_color: suggested_trio,
        suggested_tetrad_color: suggested_tetrad,
        auto_fixed_color2_aa: auto_aa,
        auto_fixed_color2_aaa: auto_aaa,
    }
}
