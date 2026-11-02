pub mod color;
pub mod curated;
pub mod db;
pub mod harmony;
pub mod matcher;
pub mod names;

use std::ffi::{CStr, CString};
use std::os::raw::c_char;

// Helper to convert C string to &str safely
unsafe fn c_to_str<'a>(ptr: *const c_char) -> &'a str {
    if ptr.is_null() {
        ""
    } else {
        CStr::from_ptr(ptr).to_str().unwrap_or("")
    }
}

// Helper to return Rust String to C caller
fn string_to_c(s: String) -> *mut c_char {
    CString::new(s).unwrap_or_default().into_raw()
}

#[no_mangle]
pub extern "C" fn cv_init_db() -> i32 {
    match db::open_db() {
        Ok(_) => 1,
        Err(_) => 0,
    }
}

#[no_mangle]
pub unsafe extern "C" fn cv_record_color(
    hex: *const c_char,
    name: *const c_char,
    source: *const c_char,
) -> *mut c_char {
    let hex_str = c_to_str(hex);
    let name_str = c_to_str(name);
    let source_str = c_to_str(source);

    let resolved_name = if name_str.is_empty() {
        if let Some(rgb) = color::parse_hex(hex_str) {
            names::find_closest_name(&rgb)
        } else {
            "Custom Color".to_string()
        }
    } else {
        name_str.to_string()
    };

    let item = db::record_color_usage(hex_str, &resolved_name, source_str)
        .unwrap_or_else(|_| {
            let rgb = color::parse_hex(hex_str).unwrap_or(color::Rgb::new(0, 0, 0));
            color::make_color_item(rgb, &resolved_name)
        });

    let json = serde_json::to_string(&item).unwrap_or_default();
    string_to_c(json)
}

#[no_mangle]
pub unsafe extern "C" fn cv_generate_harmonies(hex: *const c_char) -> *mut c_char {
    let hex_str = c_to_str(hex);
    let rgb = color::parse_hex(hex_str).unwrap_or(color::Rgb::new(79, 70, 229)); // Default Indigo
    let result = harmony::generate_harmonies(rgb);
    let json = serde_json::to_string(&result).unwrap_or_default();
    string_to_c(json)
}

#[no_mangle]
pub unsafe extern "C" fn cv_evaluate_pair(
    hex1: *const c_char,
    hex2: *const c_char,
) -> *mut c_char {
    let rgb1 = color::parse_hex(c_to_str(hex1)).unwrap_or(color::Rgb::new(37, 99, 235));
    let rgb2 = color::parse_hex(c_to_str(hex2)).unwrap_or(color::Rgb::new(249, 115, 22));

    let eval = matcher::evaluate_pair(rgb1, rgb2);
    let json = serde_json::to_string(&eval).unwrap_or_default();
    string_to_c(json)
}

#[no_mangle]
pub unsafe extern "C" fn cv_get_shades(hex: *const c_char) -> *mut c_char {
    let rgb = color::parse_hex(c_to_str(hex)).unwrap_or(color::Rgb::new(79, 70, 229));
    let shades = color::generate_shades(rgb);
    let json = serde_json::to_string(&shades).unwrap_or_default();
    string_to_c(json)
}

#[no_mangle]
pub unsafe extern "C" fn cv_simulate_colorblind(hex: *const c_char) -> *mut c_char {
    let rgb = color::parse_hex(c_to_str(hex)).unwrap_or(color::Rgb::new(79, 70, 229));
    let sim = color::simulate_all(rgb);
    let json = serde_json::to_string(&sim).unwrap_or_default();
    string_to_c(json)
}

#[no_mangle]
pub extern "C" fn cv_get_curated_palettes() -> *mut c_char {
    let list = curated::get_all_curated();
    let json = serde_json::to_string(&list).unwrap_or_default();
    string_to_c(json)
}

#[no_mangle]
pub extern "C" fn cv_get_history(limit: i32) -> *mut c_char {
    let max = if limit <= 0 { 100 } else { limit as usize };
    let list = db::get_recent_history(max).unwrap_or_default();
    let json = serde_json::to_string(&list).unwrap_or_default();
    string_to_c(json)
}

#[no_mangle]
pub unsafe extern "C" fn cv_toggle_favorite(hex: *const c_char, name: *const c_char) -> i32 {
    let hex_str = c_to_str(hex);
    let name_str = c_to_str(name);
    match db::toggle_color_favorite(hex_str, name_str) {
        Ok(fav) => if fav { 1 } else { 0 },
        Err(_) => -1,
    }
}

#[no_mangle]
pub extern "C" fn cv_get_favorites() -> *mut c_char {
    let list = db::get_all_favorites().unwrap_or_default();
    let json = serde_json::to_string(&list).unwrap_or_default();
    string_to_c(json)
}

#[no_mangle]
pub unsafe extern "C" fn cv_save_palette(
    title: *const c_char,
    category: *const c_char,
    colors_json: *const c_char,
) -> i64 {
    let title_str = c_to_str(title);
    let cat_str = c_to_str(category);
    let colors_str = c_to_str(colors_json);

    let colors: Vec<color::ColorItem> = serde_json::from_str(colors_str).unwrap_or_default();
    db::save_custom_palette(title_str, cat_str, &colors).unwrap_or(-1)
}

#[no_mangle]
pub extern "C" fn cv_delete_saved_palette(id: i64) -> i32 {
    match db::delete_saved_palette(id) {
        Ok(_) => 1,
        Err(_) => 0,
    }
}

#[no_mangle]
pub extern "C" fn cv_get_saved_palettes() -> *mut c_char {
    let list = db::get_saved_palettes().unwrap_or_default();
    let json = serde_json::to_string(&list).unwrap_or_default();
    string_to_c(json)
}

#[no_mangle]
pub extern "C" fn cv_clear_history() -> i32 {
    match db::clear_all_history() {
        Ok(_) => 1,
        Err(_) => 0,
    }
}

#[no_mangle]
pub unsafe extern "C" fn cv_free_string(ptr: *mut c_char) {
    if !ptr.is_null() {
        let _ = CString::from_raw(ptr);
    }
}
