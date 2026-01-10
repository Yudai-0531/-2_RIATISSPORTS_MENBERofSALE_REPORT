# 🔄 Quick Guide: Updating App Icons

## When to Use This Guide
Use this guide whenever you need to update the ONE TEAM app icon (e.g., design refresh, rebranding, new logo variant).

---

## 📋 Prerequisites

### Required Tools
- **ImageMagick**: For image conversion and resizing
  ```bash
  # Check if installed
  convert --version
  
  # Install if needed (macOS)
  brew install imagemagick
  
  # Install if needed (Ubuntu/Debian)
  sudo apt-get install imagemagick
  ```

### Source Image Requirements
- **Format**: PNG or JPG
- **Resolution**: 1024×1024 pixels minimum (recommended)
- **Aspect Ratio**: 1:1 (square)
- **Design**: Ensure logo/content is centered for circular cropping
- **Safe Zone**: Keep important elements within 80% center area

---

## 🚀 Step-by-Step Update Process

### Step 1: Prepare Your New Icon
```bash
# Navigate to project directory
cd /home/user/webapp

# Place your new icon file in the root directory
# Example: new-icon.png (1024×1024)
```

### Step 2: Run the Icon Generation Script
```bash
# Make script executable (first time only)
chmod +x generate-app-icons.sh

# Generate all icon sizes
./generate-app-icons.sh new-icon.png
```

**What this does:**
- Generates all 13 icon sizes (16×16 to 512×512)
- Creates multi-resolution favicon.ico
- Tests circular cropping for Android
- Optimizes all images for production

### Step 3: Verify the Generated Icons

#### Check Generated Files
```bash
# List all generated icons
ls -lh icons/

# View circular crop test
open temp_icons/test-circular-192.png
# or
xdg-open temp_icons/test-circular-192.png
```

#### Verify Image Quality
```bash
# Check specific icon details
identify icons/icon-192x192.png
identify icons/apple-touch-icon.png
```

**What to check:**
- ✅ Logo is centered and visible
- ✅ No important elements cut off in circular crop
- ✅ Neon glow or effects preserved
- ✅ Colors accurate to source

### Step 4: Test Locally

#### Start Local Server
```bash
# Using Python
python3 -m http.server 8000

# Using npx
npx serve
```

#### Test in Browsers
1. **Favicon**: Open http://localhost:8000 and check browser tab
2. **PWA Manifest**: 
   - Chrome DevTools → Application → Manifest
   - Verify all icons load without errors
3. **Apple Touch Icon**: Check on iOS device (Add to Home Screen)

### Step 5: Commit Changes

```bash
# Stage all changes
git add .

# Commit with descriptive message
git commit -m "feat(icons): update app icon to [describe change]

- Update source icon to [new design description]
- Regenerate all icon sizes (favicon, Apple, Android/PWA)
- Verify circular cropping and safe zones
- Test PWA manifest and HTML references"

# Push to branch
git push origin genspark_ai_developer
```

### Step 6: Create Pull Request

```bash
# Create PR using GitHub CLI
gh pr create \
  --title "feat(icons): Update App Icon [Brief Description]" \
  --body "Description of changes..." \
  --base main \
  --head genspark_ai_developer
```

---

## 🎨 Design Guidelines

### Safe Zone Recommendations
```
┌─────────────────────────┐
│  ┌─────────────────┐    │
│  │                 │    │
│  │  [YOUR LOGO]    │    │ ← 80% safe zone
│  │                 │    │   (circular crop)
│  └─────────────────┘    │
└─────────────────────────┘
     1024×1024 canvas
```

### Color Palette Consistency
Ensure your new icon matches the app's theme:
- **Background**: Black (#000000) or dark theme
- **Primary**: Neon Red (#ff0033) or brand color
- **Style**: Cyberpunk/Tech aesthetic

### File Naming Convention
```bash
# Source files
app-icon-source.jpg          # Primary source (1024×1024)
app-icon-source-v2.jpg       # Version 2 (if needed)

# Keep old sources for reference
app-icon-source-2024.jpg     # Dated archive
```

---

## 📁 Generated Files Reference

After running the script, these files will be updated:

### Browser Icons
- `favicon.ico` - Multi-resolution (16, 32, 48px)
- `icons/favicon-16x16.png`
- `icons/favicon-32x32.png`
- `icons/favicon-48x48.png`

### Apple Icons
- `icons/apple-touch-icon.png` (180×180)
- `icons/apple-touch-icon-ipad.png` (167×167)

### Android/PWA Icons
- `icons/icon-72x72.png` (ldpi)
- `icons/icon-96x96.png` (mdpi)
- `icons/icon-128x128.png` (hdpi)
- `icons/icon-144x144.png` (xhdpi)
- `icons/icon-152x152.png` (xxhdpi)
- `icons/icon-192x192.png` (xxxhdpi / PWA standard)
- `icons/icon-384x384.png` (high-res)
- `icons/icon-512x512.png` (PWA standard high-res)

---

## ✅ Verification Checklist

Before committing, verify:

- [ ] All 13 icon files generated successfully
- [ ] Circular crop test looks good (temp_icons/test-circular-192.png)
- [ ] Logo centered and visible in all sizes
- [ ] No compression artifacts or quality loss
- [ ] Favicon displays correctly in browser tab
- [ ] PWA manifest references all icons (no 404s)
- [ ] Theme colors match in manifest.json
- [ ] All HTML files still reference icons correctly

---

## 🐛 Troubleshooting

### Issue: Icons look pixelated
**Solution**: Use a higher resolution source image (minimum 1024×1024)

### Issue: Logo cut off in circular crop
**Solution**: Keep logo within 80% center area of canvas

### Issue: Script fails with "ImageMagick not found"
**Solution**: Install ImageMagick:
```bash
# macOS
brew install imagemagick

# Ubuntu/Debian
sudo apt-get install imagemagick
```

### Issue: Generated icons too large
**Solution**: Script automatically optimizes. If needed, reduce source image size:
```bash
convert source.png -quality 90 -strip optimized.png
```

---

## 🔧 Advanced Usage

### Custom Icon Sizes
If you need additional sizes:
```bash
convert app-icon-source.jpg -resize 256x256 icons/icon-256x256.png
```

### Batch Optimization
Optimize all icons after generation:
```bash
cd icons
for img in *.png; do
  convert "$img" -strip -quality 95 "optimized-$img"
done
```

### Create Adaptive Icon Layers (for native Android)
```bash
# Extract foreground (logo only, transparent background)
convert app-icon-source.jpg -alpha set -channel A -evaluate set 0 foreground.png

# Solid background
convert -size 1024x1024 xc:#000000 background.png
```

---

## 📚 Related Documentation

- `ICON_IMPLEMENTATION_SUMMARY.md` - Complete implementation details
- `APP_ICON_SETUP.md` - PWA and icon configuration
- `manifest.json` - PWA manifest configuration
- `generate-app-icons.sh` - Icon generation script

---

## 💡 Tips & Best Practices

1. **Keep Source Files**: Always save original source images (PSD, AI, SVG)
2. **Version Control**: Use dated filenames for source images
3. **Test Early**: Check circular crop before final generation
4. **Document Changes**: Update CHANGELOG.md with icon updates
5. **Cache Busting**: Consider adding version query params after major updates
   ```html
   <link rel="icon" href="/icons/icon-192x192.png?v=2">
   ```

---

**Last Updated**: 2026-01-10  
**Script Version**: 1.0  
**Maintainer**: ONE TEAM Development Team
