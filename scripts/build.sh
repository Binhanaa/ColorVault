#!/bin/bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
cd "$DIR"

echo "==> 1. Compiling Rust ColorVault Core Engine (release)..."
export PATH="$HOME/.cargo/bin:$PATH"
cargo build --release

echo "==> 2. Preparing macOS App Bundle Structure..."
APP_NAME="ColorVault"
BUILD_DIR="$DIR/build"
APP_BUNDLE="$BUILD_DIR/$APP_NAME.app"

rm -rf "$APP_BUNDLE"
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Frameworks"
mkdir -p "$APP_BUNDLE/Contents/Resources"

# Copy Resources
cp "$DIR/swift/Resources/Info.plist" "$APP_BUNDLE/Contents/Info.plist"
cp "$DIR/swift/Resources/AppIcon.icns" "$APP_BUNDLE/Contents/Resources/AppIcon.icns"
if [ -f "$DIR/swift/Resources/MenuBarIcon.png" ]; then
    cp "$DIR/swift/Resources/MenuBarIcon.png" "$APP_BUNDLE/Contents/Resources/"
fi
if [ -f "$DIR/swift/Resources/MenuBarIcon@2x.png" ]; then
    cp "$DIR/swift/Resources/MenuBarIcon@2x.png" "$APP_BUNDLE/Contents/Resources/"
fi

# Copy Rust dylib to Frameworks
cp "$DIR/target/release/libcolorvault_core.dylib" "$APP_BUNDLE/Contents/Frameworks/"

# Fix library install name
install_name_tool -id "@rpath/libcolorvault_core.dylib" "$APP_BUNDLE/Contents/Frameworks/libcolorvault_core.dylib"

echo "==> 3. Compiling Swift Native App..."
swiftc -O \
    -target arm64-apple-macos14.0 \
    -framework AppKit \
    -framework SwiftUI \
    -framework Foundation \
    -L "$DIR/target/release" \
    -lcolorvault_core \
    -Xlinker -rpath -Xlinker "@executable_path/../Frameworks" \
    swift/*.swift swift/Views/*.swift swift/Views/Components/*.swift \
    -o "$APP_BUNDLE/Contents/MacOS/$APP_NAME"

echo "==> 4. Fixing rpath on binary..."
RAW_DYLIB_PATH=$(otool -L "$APP_BUNDLE/Contents/MacOS/$APP_NAME" | grep "libcolorvault_core.dylib" | awk '{print $1}')
if [ -n "$RAW_DYLIB_PATH" ] && [ "$RAW_DYLIB_PATH" != "@rpath/libcolorvault_core.dylib" ]; then
    install_name_tool -change "$RAW_DYLIB_PATH" "@rpath/libcolorvault_core.dylib" "$APP_BUNDLE/Contents/MacOS/$APP_NAME"
fi

echo "==> 5. Code Signing App Bundle..."
codesign --force --deep --sign - "$APP_BUNDLE"

echo "==> Build finished successfully at: $APP_BUNDLE"
