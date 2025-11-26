#!/bin/bash

# Script to generate app icons from SVG for iOS and Android
# Requires: librsvg (for rsvg-convert)
# Install on macOS: brew install librsvg

# Check if rsvg-convert is installed
if ! command -v rsvg-convert &> /dev/null; then
    echo "rsvg-convert is not installed. Installing via Homebrew..."
    brew install librsvg
fi

cd "$(dirname "$0")"

SVG_FILE="assets/app_icon.svg"
TEMP_PNG="temp_icon.png"

# Generate high-res base image
echo "Generating base image..."
rsvg-convert -w 1024 -h 1024 "$SVG_FILE" > "$TEMP_PNG"

# Android icons
echo "Generating Android icons..."
mkdir -p android/app/src/main/res/mipmap-mdpi
mkdir -p android/app/src/main/res/mipmap-hdpi
mkdir -p android/app/src/main/res/mipmap-xhdpi
mkdir -p android/app/src/main/res/mipmap-xxhdpi
mkdir -p android/app/src/main/res/mipmap-xxxhdpi

sips -z 48 48 "$TEMP_PNG" --out android/app/src/main/res/mipmap-mdpi/ic_launcher.png
sips -z 72 72 "$TEMP_PNG" --out android/app/src/main/res/mipmap-hdpi/ic_launcher.png
sips -z 96 96 "$TEMP_PNG" --out android/app/src/main/res/mipmap-xhdpi/ic_launcher.png
sips -z 144 144 "$TEMP_PNG" --out android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png
sips -z 192 192 "$TEMP_PNG" --out android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png

# iOS icons
echo "Generating iOS icons..."
IOS_DIR="ios/Runner/Assets.xcassets/AppIcon.appiconset"
mkdir -p "$IOS_DIR"

# Generate all required iOS icon sizes
sips -z 20 20 "$TEMP_PNG" --out "$IOS_DIR/Icon-20.png"
sips -z 40 40 "$TEMP_PNG" --out "$IOS_DIR/Icon-20@2x.png"
sips -z 60 60 "$TEMP_PNG" --out "$IOS_DIR/Icon-20@3x.png"
sips -z 29 29 "$TEMP_PNG" --out "$IOS_DIR/Icon-29.png"
sips -z 58 58 "$TEMP_PNG" --out "$IOS_DIR/Icon-29@2x.png"
sips -z 87 87 "$TEMP_PNG" --out "$IOS_DIR/Icon-29@3x.png"
sips -z 40 40 "$TEMP_PNG" --out "$IOS_DIR/Icon-40.png"
sips -z 80 80 "$TEMP_PNG" --out "$IOS_DIR/Icon-40@2x.png"
sips -z 120 120 "$TEMP_PNG" --out "$IOS_DIR/Icon-40@3x.png"
sips -z 120 120 "$TEMP_PNG" --out "$IOS_DIR/Icon-60@2x.png"
sips -z 180 180 "$TEMP_PNG" --out "$IOS_DIR/Icon-60@3x.png"
sips -z 76 76 "$TEMP_PNG" --out "$IOS_DIR/Icon-76.png"
sips -z 152 152 "$TEMP_PNG" --out "$IOS_DIR/Icon-76@2x.png"
sips -z 167 167 "$TEMP_PNG" --out "$IOS_DIR/Icon-83.5@2x.png"
sips -z 1024 1024 "$TEMP_PNG" --out "$IOS_DIR/Icon-1024.png"

# Create Contents.json for iOS
cat > "$IOS_DIR/Contents.json" << 'EOF'
{
  "images" : [
    {
      "size" : "20x20",
      "idiom" : "iphone",
      "filename" : "Icon-20@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "20x20",
      "idiom" : "iphone",
      "filename" : "Icon-20@3x.png",
      "scale" : "3x"
    },
    {
      "size" : "29x29",
      "idiom" : "iphone",
      "filename" : "Icon-29@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "29x29",
      "idiom" : "iphone",
      "filename" : "Icon-29@3x.png",
      "scale" : "3x"
    },
    {
      "size" : "40x40",
      "idiom" : "iphone",
      "filename" : "Icon-40@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "40x40",
      "idiom" : "iphone",
      "filename" : "Icon-40@3x.png",
      "scale" : "3x"
    },
    {
      "size" : "60x60",
      "idiom" : "iphone",
      "filename" : "Icon-60@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "60x60",
      "idiom" : "iphone",
      "filename" : "Icon-60@3x.png",
      "scale" : "3x"
    },
    {
      "size" : "20x20",
      "idiom" : "ipad",
      "filename" : "Icon-20.png",
      "scale" : "1x"
    },
    {
      "size" : "20x20",
      "idiom" : "ipad",
      "filename" : "Icon-20@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "29x29",
      "idiom" : "ipad",
      "filename" : "Icon-29.png",
      "scale" : "1x"
    },
    {
      "size" : "29x29",
      "idiom" : "ipad",
      "filename" : "Icon-29@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "40x40",
      "idiom" : "ipad",
      "filename" : "Icon-40.png",
      "scale" : "1x"
    },
    {
      "size" : "40x40",
      "idiom" : "ipad",
      "filename" : "Icon-40@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "76x76",
      "idiom" : "ipad",
      "filename" : "Icon-76.png",
      "scale" : "1x"
    },
    {
      "size" : "76x76",
      "idiom" : "ipad",
      "filename" : "Icon-76@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "83.5x83.5",
      "idiom" : "ipad",
      "filename" : "Icon-83.5@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "1024x1024",
      "idiom" : "ios-marketing",
      "filename" : "Icon-1024.png",
      "scale" : "1x"
    }
  ],
  "info" : {
    "version" : 1,
    "author" : "xcode"
  }
}
EOF

# Clean up
rm "$TEMP_PNG"

echo "✅ App icons generated successfully!"
echo "Android icons: android/app/src/main/res/mipmap-*/"
echo "iOS icons: ios/Runner/Assets.xcassets/AppIcon.appiconset/"
