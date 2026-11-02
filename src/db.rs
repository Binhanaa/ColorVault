use std::fs;
use std::path::PathBuf;
use rusqlite::{params, Connection, Result};
use serde::{Deserialize, Serialize};
use crate::color::{make_color_item, parse_hex, ColorItem};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct HistoryRecord {
    pub id: i64,
    pub color: ColorItem,
    pub source: String,
    pub is_favorite: bool,
    pub created_at: String,
    pub use_count: i64,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct FavoriteRecord {
    pub hex: String,
    pub color: ColorItem,
    pub created_at: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SavedPaletteRecord {
    pub id: i64,
    pub title: String,
    pub category: String,
    pub colors: Vec<ColorItem>,
    pub is_favorite: bool,
    pub created_at: String,
}

pub fn get_db_path() -> PathBuf {
    let mut path = dirs::data_local_dir().unwrap_or_else(|| {
        PathBuf::from("/Users/abdallah/Library/Application Support")
    });
    path.push("ColorVault");
    if !path.exists() {
        let _ = fs::create_dir_all(&path);
    }
    path.push("colorvault.sqlite");
    path
}

pub fn open_db() -> Result<Connection> {
    let path = get_db_path();
    let conn = Connection::open(path)?;

    // Enable WAL mode for ultra-fast concurrent writes and crash durability
    conn.execute_batch("PRAGMA journal_mode = WAL; PRAGMA synchronous = NORMAL;")?;

    conn.execute_batch(
        "
        CREATE TABLE IF NOT EXISTS color_history (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            hex TEXT UNIQUE NOT NULL,
            r INTEGER NOT NULL,
            g INTEGER NOT NULL,
            b INTEGER NOT NULL,
            name TEXT NOT NULL,
            source TEXT NOT NULL,
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
            use_count INTEGER DEFAULT 1
        );

        CREATE TABLE IF NOT EXISTS permanent_favorites (
            hex TEXT PRIMARY KEY NOT NULL,
            r INTEGER NOT NULL,
            g INTEGER NOT NULL,
            b INTEGER NOT NULL,
            name TEXT NOT NULL,
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP
        );

        CREATE TABLE IF NOT EXISTS saved_palettes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            category TEXT NOT NULL,
            colors_json TEXT NOT NULL,
            is_favorite INTEGER DEFAULT 0,
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP
        );
        "
    )?;

    Ok(conn)
}

pub fn record_color_usage(hex_str: &str, name: &str, source: &str) -> Result<ColorItem> {
    let rgb = parse_hex(hex_str).unwrap_or(crate::color::Rgb::new(59, 130, 246));
    let hex_normalized = rgb.to_hex();
    let item = make_color_item(rgb, name);

    let conn = open_db()?;
    let now = chrono::Local::now().to_rfc3339();

    // Upsert: increment use_count if already exists
    conn.execute(
        "
        INSERT INTO color_history (hex, r, g, b, name, source, created_at, use_count)
        VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, 1)
        ON CONFLICT(hex) DO UPDATE SET
            use_count = use_count + 1,
            created_at = ?7,
            source = ?6;
        ",
        params![hex_normalized, rgb.r, rgb.g, rgb.b, name, source, now],
    )?;

    Ok(item)
}

pub fn is_favorite(hex: &str) -> bool {
    let rgb = parse_hex(hex).unwrap_or(crate::color::Rgb::new(0, 0, 0));
    let norm_hex = rgb.to_hex();
    if let Ok(conn) = open_db() {
        let count: i64 = conn.query_row(
            "SELECT count(*) FROM permanent_favorites WHERE hex = ?1;",
            params![norm_hex],
            |row| row.get(0),
        ).unwrap_or(0);
        count > 0
    } else {
        false
    }
}

pub fn toggle_color_favorite(hex: &str, name: &str) -> Result<bool> {
    let conn = open_db()?;
    let rgb = parse_hex(hex).unwrap_or(crate::color::Rgb::new(0, 0, 0));
    let norm_hex = rgb.to_hex();

    let exists: i64 = conn.query_row(
        "SELECT count(*) FROM permanent_favorites WHERE hex = ?1;",
        params![norm_hex],
        |row| row.get(0),
    ).unwrap_or(0);

    if exists > 0 {
        // Remove from favorites
        conn.execute(
            "DELETE FROM permanent_favorites WHERE hex = ?1;",
            params![norm_hex],
        )?;
        Ok(false)
    } else {
        // Add to permanent favorites
        let now = chrono::Local::now().to_rfc3339();
        conn.execute(
            "INSERT INTO permanent_favorites (hex, r, g, b, name, created_at) VALUES (?1, ?2, ?3, ?4, ?5, ?6);",
            params![norm_hex, rgb.r, rgb.g, rgb.b, name, now],
        )?;
        Ok(true)
    }
}

pub fn get_all_favorites() -> Result<Vec<FavoriteRecord>> {
    let conn = open_db()?;
    let mut stmt = conn.prepare(
        "
        SELECT hex, r, g, b, name, created_at
        FROM permanent_favorites
        ORDER BY created_at DESC;
        "
    )?;

    let rows = stmt.query_map([], |row| {
        let hex: String = row.get(0)?;
        let r: u8 = row.get(1)?;
        let g: u8 = row.get(2)?;
        let b: u8 = row.get(3)?;
        let name: String = row.get(4)?;
        let created_at: String = row.get(5)?;

        let rgb = crate::color::Rgb::new(r, g, b);
        let color = make_color_item(rgb, &name);

        Ok(FavoriteRecord {
            hex,
            color,
            created_at,
        })
    })?;

    let mut list = Vec::new();
    for r in rows {
        if let Ok(entry) = r {
            list.push(entry);
        }
    }
    Ok(list)
}

pub fn get_recent_history(limit: usize) -> Result<Vec<HistoryRecord>> {
    let conn = open_db()?;
    let mut stmt = conn.prepare(
        "
        SELECT h.id, h.hex, h.r, h.g, h.b, h.name, h.source, h.created_at, h.use_count,
               CASE WHEN f.hex IS NOT NULL THEN 1 ELSE 0 END as is_fav
        FROM color_history h
        LEFT JOIN permanent_favorites f ON h.hex = f.hex
        ORDER BY h.created_at DESC
        LIMIT ?1;
        "
    )?;

    let rows = stmt.query_map(params![limit as i64], |row| {
        let id: i64 = row.get(0)?;
        let _hex: String = row.get(1)?;
        let r: u8 = row.get(2)?;
        let g: u8 = row.get(3)?;
        let b: u8 = row.get(4)?;
        let name: String = row.get(5)?;
        let source: String = row.get(6)?;
        let created_at: String = row.get(7)?;
        let use_count: i64 = row.get(8)?;
        let is_fav_int: i32 = row.get(9)?;

        let rgb = crate::color::Rgb::new(r, g, b);
        let color = make_color_item(rgb, &name);

        Ok(HistoryRecord {
            id,
            color,
            source,
            is_favorite: is_fav_int == 1,
            created_at,
            use_count,
        })
    })?;

    let mut list = Vec::new();
    for r in rows {
        if let Ok(entry) = r {
            list.push(entry);
        }
    }

    Ok(list)
}

pub fn save_custom_palette(title: &str, category: &str, colors: &[ColorItem]) -> Result<i64> {
    let conn = open_db()?;
    let json_colors = serde_json::to_string(colors).unwrap_or_else(|_| "[]".to_string());
    let now = chrono::Local::now().to_rfc3339();

    conn.execute(
        "
        INSERT INTO saved_palettes (title, category, colors_json, is_favorite, created_at)
        VALUES (?1, ?2, ?3, 1, ?4);
        ",
        params![title, category, json_colors, now],
    )?;

    Ok(conn.last_insert_rowid())
}

pub fn delete_saved_palette(id: i64) -> Result<()> {
    let conn = open_db()?;
    conn.execute("DELETE FROM saved_palettes WHERE id = ?1;", params![id])?;
    Ok(())
}

pub fn get_saved_palettes() -> Result<Vec<SavedPaletteRecord>> {
    let conn = open_db()?;
    let mut stmt = conn.prepare(
        "
        SELECT id, title, category, colors_json, is_favorite, created_at
        FROM saved_palettes
        ORDER BY created_at DESC;
        "
    )?;

    let rows = stmt.query_map([], |row| {
        let id: i64 = row.get(0)?;
        let title: String = row.get(1)?;
        let category: String = row.get(2)?;
        let colors_json: String = row.get(3)?;
        let is_fav_int: i32 = row.get(4)?;
        let created_at: String = row.get(5)?;

        let colors: Vec<ColorItem> = serde_json::from_str(&colors_json).unwrap_or_default();

        Ok(SavedPaletteRecord {
            id,
            title,
            category,
            colors,
            is_favorite: is_fav_int == 1,
            created_at,
        })
    })?;

    let mut list = Vec::new();
    for r in rows {
        if let Ok(entry) = r {
            list.push(entry);
        }
    }

    Ok(list)
}

pub fn clear_all_history() -> Result<()> {
    let conn = open_db()?;
    // Clears history but NEVER deletes from permanent_favorites or saved_palettes!
    conn.execute("DELETE FROM color_history;", [])?;
    Ok(())
}
