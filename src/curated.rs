use serde::{Deserialize, Serialize};
use crate::color::{make_color_item, parse_hex, ColorItem};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CuratedPalette {
    pub id: String,
    pub title: String,
    pub title_ar: String,
    pub category: String, // "duo", "trio", "tetrad"
    pub tag: String,
    pub colors: Vec<ColorItem>,
}

pub fn get_all_curated() -> Vec<CuratedPalette> {
    let mut palettes = Vec::new();

    let build = |id: &str, title: &str, title_ar: &str, category: &str, tag: &str, hexes: &[(&str, &str)]| -> CuratedPalette {
        let colors = hexes
            .iter()
            .map(|(hex, name)| {
                let rgb = parse_hex(hex).unwrap();
                make_color_item(rgb, name)
            })
            .collect();

        CuratedPalette {
            id: id.to_string(),
            title: title.to_string(),
            title_ar: title_ar.to_string(),
            category: category.to_string(),
            tag: tag.to_string(),
            colors,
        }
    };

    // --- DUOS (2-Color Sets) ---
    palettes.push(build(
        "duo_sunset",
        "Sunset Glow",
        "شفق الغروب الساحر",
        "duo",
        "Vibrant",
        &[("#1E1B4B", "Deep Indigo"), ("#F97316", "Vivid Sunset")],
    ));

    palettes.push(build(
        "duo_cyber",
        "Cyberpunk Neon",
        "نيون سايبربانك",
        "duo",
        "Electric",
        &[("#06B6D4", "Electric Cyan"), ("#EC4899", "Hot Pink")],
    ));

    palettes.push(build(
        "duo_forest",
        "Forest & Sand",
        "الغابة والرمال الذهبية",
        "duo",
        "Nature",
        &[("#064E3B", "Deep Pine"), ("#FDE68A", "Warm Sand")],
    ));

    palettes.push(build(
        "duo_luxury",
        "Royal Obsidian & Gold",
        "الملكي الأسود والذهب",
        "duo",
        "Luxury",
        &[("#09090B", "Obsidian Black"), ("#F59E0B", "Imperial Gold")],
    ));

    palettes.push(build(
        "duo_marine",
        "Ocean & Mint",
        "المحيط والنعناع المنعش",
        "duo",
        "Fresh",
        &[("#1E40AF", "Deep Marine"), ("#34D399", "Aqua Mint")],
    ));

    // --- TRIOS (3-Color Sets) ---
    palettes.push(build(
        "trio_nordic",
        "Nordic Serenity",
        "الهدوء الإسكندنافي",
        "trio",
        "Minimal",
        &[("#334155", "Slate Shadow"), ("#38BDF8", "Frost Sky"), ("#F8FAFC", "Arctic White")],
    ));

    palettes.push(build(
        "trio_retro",
        "Retro Sunset 80s",
        "ريترو الثمانينات",
        "trio",
        "Vibrant",
        &[("#8B5CF6", "Retro Purple"), ("#FB7185", "Coral Rose"), ("#FBBF24", "Warm Amber")],
    ));

    palettes.push(build(
        "trio_matcha",
        "Matcha Latte",
        "ماتشا لاتيه",
        "trio",
        "Organic",
        &[("#4D7C0F", "Matcha Green"), ("#FEF08A", "Cream Foam"), ("#78350F", "Warm Taupe")],
    ));

    palettes.push(build(
        "trio_tech",
        "Modern Silicon",
        "التقنية الحديثة",
        "trio",
        "Tech",
        &[("#2563EB", "Silicon Blue"), ("#0D9488", "Deep Cyan"), ("#F1F5F9", "Platinum Gray")],
    ));

    palettes.push(build(
        "trio_autumn",
        "Autumn Harvest",
        "ألوان الخريف الدافئة",
        "trio",
        "Warm",
        &[("#C2410C", "Burnt Orange"), ("#D97706", "Harvest Ochre"), ("#451A03", "Chestnut Brown")],
    ));

    // --- TETRADS (4-Color Sets) ---
    palettes.push(build(
        "tetrad_apple",
        "Cupertino Pro",
        "كوبرتينو برو الاحترافي",
        "tetrad",
        "Design System",
        &[
            ("#007AFF", "System Blue"),
            ("#34C759", "System Mint"),
            ("#AF52DE", "System Purple"),
            ("#F2F2F7", "System Surface"),
        ],
    ));

    palettes.push(build(
        "tetrad_neon",
        "Neon Arcade",
        "أركيد النيون المستقبلي",
        "tetrad",
        "Electric",
        &[
            ("#18181B", "Void Black"),
            ("#22C55E", "Toxic Green"),
            ("#A855F7", "Electric Violet"),
            ("#F43F5E", "Neon Crimson"),
        ],
    ));

    palettes.push(build(
        "tetrad_desert",
        "Desert Oasis",
        "واحة الصحراء",
        "tetrad",
        "Earthy",
        &[
            ("#9A3412", "Terracotta Clay"),
            ("#FBBF24", "Sahara Gold"),
            ("#0D9488", "Oasis Teal"),
            ("#451A03", "Bedouin Espresso"),
        ],
    ));

    palettes.push(build(
        "tetrad_pastel",
        "Pastel Dreamscape",
        "حلم الباستيل الناعم",
        "tetrad",
        "Soft",
        &[
            ("#C4B5FD", "Soft Lavender"),
            ("#FBCFE8", "Blush Pink"),
            ("#FEF08A", "Buttercream"),
            ("#BAE6FD", "Morning Sky"),
        ],
    ));

    palettes.push(build(
        "tetrad_executive",
        "Executive Suite",
        "جناح الأعمال والشركات",
        "tetrad",
        "Corporate",
        &[
            ("#0F172A", "Midnight Navy"),
            ("#475569", "Executive Steel"),
            ("#0284C7", "Azure Focus"),
            ("#D97706", "Bronze Accent"),
        ],
    ));

    palettes
}
