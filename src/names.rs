use crate::color::Rgb;

struct NamedColor {
    name: &'static str,
    r: u8,
    g: u8,
    b: u8,
}

const PALETTE_NAMES: &[NamedColor] = &[
    NamedColor { name: "Midnight Black", r: 15, g: 23, b: 42 },
    NamedColor { name: "Charcoal Slate", r: 30, g: 41, b: 59 },
    NamedColor { name: "Graphite Gray", r: 71, g: 85, b: 105 },
    NamedColor { name: "Silver Mist", r: 148, g: 163, b: 184 },
    NamedColor { name: "Pure Snow", r: 248, g: 250, b: 252 },
    NamedColor { name: "Crimson Red", r: 220, g: 38, b: 38 },
    NamedColor { name: "Ruby Flare", r: 239, g: 68, b: 68 },
    NamedColor { name: "Sunset Coral", r: 244, g: 63, b: 94 },
    NamedColor { name: "Electric Tangerine", r: 249, g: 115, b: 22 },
    NamedColor { name: "Warm Amber", r: 245, g: 158, b: 11 },
    NamedColor { name: "Canary Gold", r: 234, g: 179, b: 8 },
    NamedColor { name: "Lime Zing", r: 132, g: 204, b: 22 },
    NamedColor { name: "Emerald Forest", r: 16, g: 185, b: 129 },
    NamedColor { name: "Mint Breeze", r: 52, g: 211, b: 153 },
    NamedColor { name: "Teal Lagoon", r: 20, g: 184, b: 166 },
    NamedColor { name: "Cyan Spark", r: 6, g: 182, b: 212 },
    NamedColor { name: "Sky Azure", r: 14, g: 165, b: 233 },
    NamedColor { name: "Royal Sapphire", r: 59, g: 130, b: 246 },
    NamedColor { name: "Cobalt Night", r: 37, g: 99, b: 235 },
    NamedColor { name: "Indigo Velvet", r: 99, g: 102, b: 241 },
    NamedColor { name: "Violet Dream", r: 139, g: 92, b: 246 },
    NamedColor { name: "Purple Orchid", r: 168, g: 85, b: 247 },
    NamedColor { name: "Hot Fuchsia", r: 217, g: 70, b: 239 },
    NamedColor { name: "Blush Rose", r: 244, g: 114, b: 182 },
    NamedColor { name: "Almond Cream", r: 254, g: 243, b: 199 },
    NamedColor { name: "Caramel Bronze", r: 180, g: 83, b: 9 },
    NamedColor { name: "Espresso Brown", r: 69, g: 26, b: 3 },
    NamedColor { name: "Olive Moss", r: 101, g: 163, b: 13 },
    NamedColor { name: "Nordic Frost", r: 224, g: 242, b: 254 },
    NamedColor { name: "Cyberpunk Magenta", r: 255, g: 0, b: 128 },
    NamedColor { name: "Neon Cyber Blue", r: 0, g: 240, b: 255 },
    NamedColor { name: "Toxic Lime", r: 57, g: 255, b: 20 },
];

pub fn find_closest_name(rgb: &Rgb) -> String {
    let mut best_name = "Custom Color";
    let mut min_dist = f64::MAX;

    for item in PALETTE_NAMES {
        let dr = (rgb.r as f64) - (item.r as f64);
        let dg = (rgb.g as f64) - (item.g as f64);
        let db = (rgb.b as f64) - (item.b as f64);
        // Weighted Euclidean distance for human eye sensitivity
        let dist = 2.0 * dr * dr + 4.0 * dg * dg + 3.0 * db * db;
        if dist < min_dist {
            min_dist = dist;
            best_name = item.name;
        }
    }

    best_name.to_string()
}
