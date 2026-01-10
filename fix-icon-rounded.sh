#!/bin/bash

##############################################################################
# ONE TEAM Icon Fix - Rounded Corners with Transparent Background
# Purpose: Create properly rounded icons that display without white padding on iOS
##############################################################################

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}════════════════════════════════════════════════${NC}"
echo -e "${GREEN}ONE TEAM Icon Fix - Rounded Transparent Icons${NC}"
echo -e "${GREEN}════════════════════════════════════════════════${NC}"
echo ""

SOURCE="app-icon-source.jpg"

if [ ! -f "$SOURCE" ]; then
    echo -e "${RED}Error: Source file $SOURCE not found!${NC}"
    exit 1
fi

# Check ImageMagick
if ! command -v convert &> /dev/null; then
    echo -e "${RED}Error: ImageMagick not installed!${NC}"
    exit 1
fi

mkdir -p icons

echo -e "${YELLOW}Generating rounded corner icons with transparent background...${NC}"
echo ""

# Function to generate rounded icon with transparent corners
generate_rounded_icon() {
    local size=$1
    local output=$2
    local radius=$3
    local desc=$4
    
    echo -e "  Generating ${GREEN}${size}x${size}${NC} → ${output} ${YELLOW}(${desc})${NC}"
    
    # Create rounded corner mask and apply to icon
    convert "$SOURCE" -resize "${size}x${size}!" \
        \( +clone -alpha opaque -fill white -colorize 100% \
           -draw "fill black polygon 0,0 0,${radius} ${radius},0 fill white circle ${radius},${radius} ${radius},0" \
           \( +clone -flip \) -compose Multiply -composite \
           \( +clone -flop \) -compose Multiply -composite \
        \) -alpha off -compose CopyOpacity -composite \
        -background none \
        "$output"
}

# Apple Touch Icons (most important - iOS uses these)
# iOS applies ~22.5% corner radius (40.5px for 180px icon)
generate_rounded_icon 180 "icons/apple-touch-icon.png" 40 "iPhone - 22.5% radius"
generate_rounded_icon 167 "icons/apple-touch-icon-ipad.png" 37 "iPad - 22.5% radius"

# Android/PWA icons with appropriate corner radius
# Android typically uses ~20% corner radius
generate_rounded_icon 192 "icons/icon-192x192.png" 38 "Android - 20% radius"
generate_rounded_icon 512 "icons/icon-512x512.png" 102 "PWA high-res - 20% radius"
generate_rounded_icon 384 "icons/icon-384x384.png" 77 "High-res - 20% radius"
generate_rounded_icon 152 "icons/icon-152x152.png" 30 "xxhdpi - 20% radius"
generate_rounded_icon 144 "icons/icon-144x144.png" 29 "xhdpi - 20% radius"
generate_rounded_icon 128 "icons/icon-128x128.png" 26 "hdpi - 20% radius"
generate_rounded_icon 96 "icons/icon-96x96.png" 19 "mdpi - 20% radius"
generate_rounded_icon 72 "icons/icon-72x72.png" 14 "ldpi - 20% radius"

# Favicons - less radius needed (browser tabs are usually square or slight rounding)
echo ""
echo -e "${YELLOW}Generating favicons (minimal rounding)...${NC}"
convert "$SOURCE" -resize 48x48! icons/favicon-48x48.png
convert "$SOURCE" -resize 32x32! icons/favicon-32x32.png
convert "$SOURCE" -resize 16x16! icons/favicon-16x16.png

# Multi-resolution favicon.ico
convert icons/favicon-16x16.png icons/favicon-32x32.png icons/favicon-48x48.png favicon.ico

echo ""
echo -e "${GREEN}════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✓ Icon Generation Complete!${NC}"
echo -e "${GREEN}════════════════════════════════════════════════${NC}"
echo ""

# Verify critical files
for file in "icons/apple-touch-icon.png" "icons/icon-192x192.png" "icons/icon-512x512.png"; do
    if [ -f "$file" ]; then
        info=$(identify "$file" | awk '{print $3, $6}')
        echo -e "${GREEN}✓${NC} $file: $info"
    fi
done

echo ""
echo -e "${YELLOW}Important:${NC}"
echo "  • Icons now have rounded corners with transparent background"
echo "  • iOS will display these without white padding"
echo "  • The transparent corners match iOS's corner radius"
echo "  • Cache must be cleared for changes to take effect"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo "  1. Deploy updated icons to production"
echo "  2. Clear browser/PWA cache"
echo "  3. Remove and re-add app to iOS home screen"
echo ""
