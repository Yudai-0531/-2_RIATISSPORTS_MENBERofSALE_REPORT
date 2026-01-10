#!/bin/bash

# ONE TEAM Icon Update Script
# Purpose: Generate PWA icons with NO white padding for iOS
# This script ensures full-bleed icons without any white borders

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}ONE TEAM Icon Update (No Padding)${NC}"
echo -e "${GREEN}========================================${NC}"

# Check if source image exists
SOURCE_IMAGE="ONE_TEAM_icon.jpg"
if [ ! -f "$SOURCE_IMAGE" ]; then
    SOURCE_IMAGE="app-icon-source.jpg"
    echo -e "${YELLOW}Using existing source: $SOURCE_IMAGE${NC}"
fi

if [ ! -f "$SOURCE_IMAGE" ]; then
    echo -e "${RED}Error: Source image not found!${NC}"
    exit 1
fi

# Check if ImageMagick is installed
if ! command -v convert &> /dev/null; then
    echo -e "${RED}Error: ImageMagick is not installed!${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Source image found: $SOURCE_IMAGE${NC}"
echo -e "${GREEN}✓ ImageMagick is available${NC}"
echo ""

# Create temporary working image with NO transparency, pure black background
echo -e "${YELLOW}Processing source image...${NC}"
TEMP_IMAGE="temp_icon_processed.png"

# Step 1: Flatten any transparency to black background
# Step 2: Ensure square aspect ratio by cropping to center
# Get image dimensions and make it square
SIZE=$(identify -format "%[fx:max(w,h)]" "$SOURCE_IMAGE")
convert "$SOURCE_IMAGE" \
    -background black \
    -alpha remove \
    -alpha off \
    -gravity center \
    -extent "${SIZE}x${SIZE}" \
    "$TEMP_IMAGE"

echo -e "${GREEN}✓ Image processed (transparency removed, black background)${NC}"

# Create icons directory if it doesn't exist
mkdir -p icons

# Generate all required icon sizes with NO padding
echo ""
echo -e "${YELLOW}Generating icon sizes...${NC}"

# Function to generate icon with specific size
generate_icon() {
    local size=$1
    local filename=$2
    echo "  → Generating $filename ($size x $size)"
    
    convert "$TEMP_IMAGE" \
        -resize "${size}x${size}!" \
        -background black \
        -alpha remove \
        -alpha off \
        "icons/$filename"
}

# iOS specific icons (180x180 is critical for apple-touch-icon)
generate_icon 180 "apple-touch-icon.png"
generate_icon 167 "apple-touch-icon-ipad.png"

# Android/Chrome icons
generate_icon 192 "icon-192x192.png"
generate_icon 512 "icon-512x512.png"

# Additional PWA icon sizes
generate_icon 72 "icon-72x72.png"
generate_icon 96 "icon-96x96.png"
generate_icon 128 "icon-128x128.png"
generate_icon 144 "icon-144x144.png"
generate_icon 152 "icon-152x152.png"
generate_icon 384 "icon-384x384.png"

# Favicon sizes
generate_icon 16 "favicon-16x16.png"
generate_icon 32 "favicon-32x32.png"
generate_icon 48 "favicon-48x48.png"

echo ""
echo -e "${GREEN}✓ All icons generated successfully!${NC}"

# Generate favicon.ico (multi-resolution)
echo ""
echo -e "${YELLOW}Generating favicon.ico...${NC}"
convert icons/favicon-16x16.png icons/favicon-32x32.png icons/favicon-48x48.png \
    -background black \
    -alpha remove \
    favicon.ico
echo -e "${GREEN}✓ favicon.ico created${NC}"

# Cleanup temporary file
rm -f "$TEMP_IMAGE"

# Verify generated files
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Verification:${NC}"
echo -e "${GREEN}========================================${NC}"

# Check critical iOS icon
if [ -f "icons/apple-touch-icon.png" ]; then
    ICON_INFO=$(identify icons/apple-touch-icon.png)
    echo -e "${GREEN}✓ apple-touch-icon.png: $ICON_INFO${NC}"
    
    # Verify it's opaque (no alpha channel)
    ALPHA_CHECK=$(identify -format "%A" icons/apple-touch-icon.png)
    if [ "$ALPHA_CHECK" = "False" ] || [ "$ALPHA_CHECK" = "Blend" ]; then
        echo -e "${GREEN}  → No alpha channel (fully opaque) ✓${NC}"
    else
        echo -e "${YELLOW}  → Warning: Alpha channel detected${NC}"
    fi
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Icon Update Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Clear browser cache and PWA cache"
echo "2. Re-add app to iOS home screen"
echo "3. Verify no white padding appears"
echo ""
echo -e "${GREEN}All icons are now optimized for full-bleed display!${NC}"
