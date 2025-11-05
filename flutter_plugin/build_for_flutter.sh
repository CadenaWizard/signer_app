#!/bin/bash

# Build script for DLC Plaza Crypto Library for Flutter
# This script builds the Rust library for different platforms

set -e

echo "Building DLC Plaza Crypto Library for Flutter..."

# Build for Android
echo "Building for Android..."
if command -v cargo-ndk &> /dev/null; then
    # Android ARM64
    cargo ndk -t arm64-v8a -o flutter_plugin/android/src/main/jniLibs build --release
    
    # Android ARM
    cargo ndk -t armeabi-v7a -o flutter_plugin/android/src/main/jniLibs build --release
    
    # Android x86_64 (for emulator)
    cargo ndk -t x86_64 -o flutter_plugin/android/src/main/jniLibs build --release
else
    echo "cargo-ndk not found. Install with: cargo install cargo-ndk"
fi

# Build for iOS
echo "Building for iOS..."
if command -v cargo-lipo &> /dev/null; then
    cargo lipo --release
    
    # Copy to iOS framework location
    mkdir -p flutter_plugin/ios/Classes/
    cp target/universal/release/libdlcplazacryptlib.a flutter_plugin/ios/Classes/
else
    echo "cargo-lipo not found. Install with: cargo install cargo-lipo"
fi

# Build for Desktop platforms
echo "Building for Desktop..."

# Linux
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    cargo build --release
    mkdir -p flutter_plugin/linux/
    cp target/release/libdlcplazacryptlib.so flutter_plugin/linux/
fi

# macOS
if [[ "$OSTYPE" == "darwin"* ]]; then
    cargo build --release
    mkdir -p flutter_plugin/macos/
    cp target/release/libdlcplazacryptlib.dylib flutter_plugin/macos/
fi

# Windows
if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
    cargo build --release
    mkdir -p flutter_plugin/windows/
    cp target/release/dlcplazacryptlib.dll flutter_plugin/windows/
fi

echo "Build complete!"
echo "Libraries have been copied to flutter_plugin/ directories"
echo ""
echo "Next steps:"
echo "1. cd flutter_plugin/example"
echo "2. flutter pub get"
echo "3. flutter run" 