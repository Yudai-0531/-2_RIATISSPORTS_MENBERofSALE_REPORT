#!/bin/bash

##############################################################################
# ONE TEAM App Icon Generator
# Generates all required icon resolutions for iOS, Android, and PWA
##############################################################################

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
SOURCE_FILE="${1:-app-icon-source.jpg}"
ICONS_DIR="icons"
TEMP_DIR="temp_icons"

echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  ONE TEAM App Icon Generator${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo ""

# Check if source file exists
if [ ! -f "$SOURCE_FILE" ]; then
    echo -e "${RED}Error: Source file '$SOURCE_FILE' not found!${NC}"
    echo "Usage: $0 [source-image-file]"
    echo "Example: $0 ONE_TEAM_icon.jpg"
    exit 1
fi

# Check if ImageMagick is installed
if ! command -v convert &> /dev/null; then
    echo -e "${RED}Error: ImageMagick is not installed!${NC}"
    echo "Please install ImageMagick to proceed."
    exit 1
fi

# Create directories
mkdir -p "$ICONS_DIR"
mkdir -p "$TEMP_DIR"

echo -e "${YELLOW}Source file: $SOURCE_FILE${NC}"
echo ""

# Get source file info
SOURCE_INFO=$(identify "$SOURCE_FILE" 2>/dev/null || echo "Unknown format")
echo -e "${YELLOW}Source info: $SOURCE_INFO${NC}"
echo ""

##############################################################################
# Icon Generation Functions
##############################################################################

generate_icon() {
    local size=$1
    local output=$2
    local description=$3
    
    echo -e "  Generating ${GREEN}${size}x${size}${NC} → ${output} ${YELLOW}($description)${NC}"
    
    convert "$SOURCE_FILE" \
        -resize "${size}x${size}" \
        -strip \
        -quality 95 \
        "$output"
}

generate_favicon() {
    local size=$1
    local output=$2
    
    echo -e "  Generating favicon ${GREEN}${size}x${size}${NC} → ${output}"
    
    convert "$SOURCE_FILE" \
        -resize "${size}x${size}" \
        -strip \
        -quality 95 \
        "$output"
}

##############################################################################
# Generate Icons
##############################################################################

echo -e "${GREEN}[1/4] Generating Favicon Icons${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
generate_favicon 16 "$ICONS_DIR/favicon-16x16.png"
generate_favicon 32 "$ICONS_DIR/favicon-32x32.png"
generate_favicon 48 "$ICONS_DIR/favicon-48x48.png"

# Generate multi-resolution favicon.ico
convert "$SOURCE_FILE" \
    -resize 16x16 "$TEMP_DIR/favicon-16.png"
convert "$SOURCE_FILE" \
    -resize 32x32 "$TEMP_DIR/favicon-32.png"
convert "$SOURCE_FILE" \
    -resize 48x48 "$TEMP_DIR/favicon-48.png"

convert "$TEMP_DIR/favicon-16.png" \
        "$TEMP_DIR/favicon-32.png" \
        "$TEMP_DIR/favicon-48.png" \
        favicon.ico

echo -e "  Generated ${GREEN}multi-resolution favicon.ico${NC}"
echo ""

echo -e "${GREEN}[2/4] Generating Apple Touch Icons${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
generate_icon 180 "$ICONS_DIR/apple-touch-icon.png" "iPhone"
generate_icon 167 "$ICONS_DIR/apple-touch-icon-ipad.png" "iPad"
echo ""

echo -e "${GREEN}[3/4] Generating Android/Chrome Icons${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
generate_icon 72 "$ICONS_DIR/icon-72x72.png" "ldpi"
generate_icon 96 "$ICONS_DIR/icon-96x96.png" "mdpi"
generate_icon 128 "$ICONS_DIR/icon-128x128.png" "hdpi"
generate_icon 144 "$ICONS_DIR/icon-144x144.png" "xhdpi"
generate_icon 152 "$ICONS_DIR/icon-152x152.png" "xxhdpi"
generate_icon 192 "$ICONS_DIR/icon-192x192.png" "xxxhdpi / PWA standard"
generate_icon 384 "$ICONS_DIR/icon-384x384.png" "high-res"
generate_icon 512 "$ICONS_DIR/icon-512x512.png" "PWA standard high-res"
echo ""

echo -e "${GREEN}[4/4] Testing Icon Safe Zones${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Test circular crop for Android adaptive icons
echo -e "  Testing circular crop (Android)..."
convert "$ICONS_DIR/icon-192x192.png" \
    \( +clone -threshold -1 -negate -fill white -draw "circle 96,96 96,0" \) \
    -alpha off -compose copy_opacity -composite \
    "$TEMP_DIR/test-circular-192.png"

echo -e "  ${GREEN}✓${NC} Circular crop test saved to temp_icons/test-circular-192.png"
echo ""

# Clean up temp directory (keep test files for verification)
echo -e "${YELLOW}Cleaning up temporary files...${NC}"
rm -f "$TEMP_DIR/favicon-"*.png

##############################################################################
# Summary
##############################################################################

echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  ✓ Icon Generation Complete!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo "Generated icons:"
echo "  • Favicon: 16x16, 32x32, 48x48, multi-res .ico"
echo "  • Apple: 180x180 (iPhone), 167x167 (iPad)"
echo "  • Android/PWA: 72, 96, 128, 144, 152, 192, 384, 512px"
echo ""
echo "Test files (for verification):"
echo "  • $TEMP_DIR/test-circular-192.png - Circular crop preview"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  1. Review the test-circular-192.png to ensure logo is visible"
echo "  2. Update manifest.json if needed"
echo "  3. Deploy to production"
echo ""
