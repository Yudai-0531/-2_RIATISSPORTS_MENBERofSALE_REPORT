#!/bin/bash

# ONE TEAM Icon Generator - No Padding Version
# This script generates all required app icons from the source image
# with no padding, ensuring the logo fills the entire icon area

set -e

# Source image
SOURCE_IMAGE="２ONE TEAM_icon.jpeg"
ICONS_DIR="icons"
TEMP_DIR="temp_icons"

# Check if source image exists
if [ ! -f "$SOURCE_IMAGE" ]; then
    echo "Error: Source image '$SOURCE_IMAGE' not found!"
    exit 1
fi

# Create temporary directory
mkdir -p "$TEMP_DIR"

echo "=========================================="
echo "  ONE TEAM Icon Generator (No Padding)"
echo "=========================================="
echo ""
echo "Source: $SOURCE_IMAGE"
echo "Output: $ICONS_DIR/"
echo ""

# Function to generate icon with specific size
generate_icon() {
    local SIZE=$1
    local OUTPUT=$2
    local DESCRIPTION=$3
    
    echo "Generating: $OUTPUT ($SIZE x $SIZE) - $DESCRIPTION"
    
    # Use -resize with ^ to fill the entire area, then crop from center
    # This ensures no white padding and logo is centered
    convert "$SOURCE_IMAGE" \
        -resize "${SIZE}x${SIZE}^" \
        -gravity center \
        -extent "${SIZE}x${SIZE}" \
        -quality 100 \
        "$TEMP_DIR/$OUTPUT"
}

# Generate all required sizes

echo "--- Favicon Sizes ---"
generate_icon 16 "favicon-16x16.png" "Favicon 16x16"
generate_icon 32 "favicon-32x32.png" "Favicon 32x32"
generate_icon 48 "favicon-48x48.png" "Favicon 48x48"

echo ""
echo "--- Apple Touch Icons ---"
generate_icon 120 "apple-touch-icon-120x120.png" "iPhone (Retina)"
generate_icon 152 "apple-touch-icon-152x152.png" "iPad (Retina)"
generate_icon 167 "apple-touch-icon-167x167.png" "iPad Pro"
generate_icon 180 "apple-touch-icon-180x180.png" "iPhone (Plus/X)"
generate_icon 180 "apple-touch-icon.png" "Default Apple Touch Icon"

echo ""
echo "--- PWA/Android Icons ---"
generate_icon 72 "icon-72x72.png" "PWA 72x72"
generate_icon 96 "icon-96x96.png" "PWA 96x96"
generate_icon 128 "icon-128x128.png" "PWA 128x128"
generate_icon 144 "icon-144x144.png" "PWA 144x144"
generate_icon 152 "icon-152x152.png" "PWA 152x152"
generate_icon 192 "icon-192x192.png" "PWA 192x192"
generate_icon 384 "icon-384x384.png" "PWA 384x384"
generate_icon 512 "icon-512x512.png" "PWA 512x512"

echo ""
echo "--- Maskable Icons (with safe zone) ---"
# Maskable icons need 20% safe zone padding to prevent clipping
# We'll add a 20% border to ensure content stays within safe zone
generate_maskable_icon() {
    local SIZE=$1
    local OUTPUT=$2
    local DESCRIPTION=$3
    
    echo "Generating: $OUTPUT ($SIZE x $SIZE) - $DESCRIPTION"
    
    # Calculate safe zone (80% of total size)
    local SAFE_SIZE=$(echo "$SIZE * 0.8" | bc | cut -d'.' -f1)
    
    # First resize to safe size, then add padding to reach full size
    convert "$SOURCE_IMAGE" \
        -resize "${SAFE_SIZE}x${SAFE_SIZE}^" \
        -gravity center \
        -extent "${SAFE_SIZE}x${SAFE_SIZE}" \
        -background black \
        -gravity center \
        -extent "${SIZE}x${SIZE}" \
        -quality 100 \
        "$TEMP_DIR/$OUTPUT"
}

generate_maskable_icon 192 "icon-maskable-192x192.png" "Maskable 192x192"
generate_maskable_icon 512 "icon-maskable-512x512.png" "Maskable 512x512"

echo ""
echo "--- Generating Favicon.ico ---"
# Generate multi-size favicon.ico (16x16, 32x32, 48x48)
convert "$TEMP_DIR/favicon-16x16.png" \
        "$TEMP_DIR/favicon-32x32.png" \
        "$TEMP_DIR/favicon-48x48.png" \
        "$TEMP_DIR/favicon.ico"

echo ""
echo "--- Moving icons to $ICONS_DIR ---"
# Backup existing icons
if [ -d "$ICONS_DIR" ]; then
    BACKUP_DIR="${ICONS_DIR}_backup_$(date +%Y%m%d_%H%M%S)"
    echo "Backing up existing icons to $BACKUP_DIR"
    mv "$ICONS_DIR" "$BACKUP_DIR"
fi

# Move new icons to destination
mkdir -p "$ICONS_DIR"
mv "$TEMP_DIR"/*.png "$ICONS_DIR/"
mv "$TEMP_DIR"/favicon.ico ./

# Clean up
rm -rf "$TEMP_DIR"

echo ""
echo "=========================================="
echo "  ✓ Icon generation completed!"
echo "=========================================="
echo ""
echo "Generated files:"
echo "  - favicon.ico (root directory)"
echo "  - $ICONS_DIR/*.png (all app icons)"
echo ""
echo "Next steps:"
echo "  1. Test icons on different devices"
echo "  2. Clear browser cache to see changes"
echo "  3. Update cache version in HTML files"
echo ""
