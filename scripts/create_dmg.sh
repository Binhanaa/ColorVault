#!/bin/bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
cd "$DIR"

APP_NAME="ColorVault"
APP_BUNDLE="$DIR/build/$APP_NAME.app"
DMG_NAME="ColorVault.dmg"
OUTPUT_DMG="$DIR/build/$DMG_NAME"
DESKTOP_DMG="$HOME/Desktop/$DMG_NAME"

if [ ! -d "$APP_BUNDLE" ]; then
    echo "App bundle not found! Running build first..."
    "$DIR/scripts/build.sh"
fi

echo "==> 1. Preparing DMG staging folder..."
STAGING_DIR="$DIR/build/dmg_staging"
rm -rf "$STAGING_DIR"
mkdir -p "$STAGING_DIR"

echo "==> 2. Copying $APP_NAME.app to staging..."
cp -R "$APP_BUNDLE" "$STAGING_DIR/"

echo "==> 3. Creating /Applications symlink..."
ln -s /Applications "$STAGING_DIR/Applications"

echo "==> 4. Building compressed DMG ($DMG_NAME)..."
rm -f "$OUTPUT_DMG"
rm -f "$DESKTOP_DMG"

hdiutil create \
    -volname "ColorVault" \
    -srcfolder "$STAGING_DIR" \
    -ov \
    -format UDZO \
    "$OUTPUT_DMG"

echo "==> 5. Outputting DMG..."
if [ -d "$HOME/Desktop" ]; then
    cp "$OUTPUT_DMG" "$DESKTOP_DMG"
    echo "    - Desktop: $DESKTOP_DMG"
    ls -lh "$DESKTOP_DMG"
fi

echo "==> 6. Cleaning up staging..."
rm -rf "$STAGING_DIR"

echo "==> SUCCESS! DMG generated at: $OUTPUT_DMG"
ls -lh "$OUTPUT_DMG"
