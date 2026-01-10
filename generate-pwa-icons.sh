#!/bin/bash
# ONE TEAM PWA Icon Generator
# Source: oneteam-icon-source.png (500x500 JPEG)

SOURCE="oneteam-icon-source.png"
ICONS_DIR="icons"
PUBLIC_DIR="public"

echo "🎨 ONE TEAM PWAアイコン生成開始..."

# ディレクトリ確認
mkdir -p "$ICONS_DIR"
mkdir -p "$PUBLIC_DIR"

# Favicon生成
echo "📌 Favicon生成中..."
convert "$SOURCE" -resize 16x16 "$ICONS_DIR/favicon-16x16.png"
convert "$SOURCE" -resize 32x32 "$ICONS_DIR/favicon-32x32.png"
convert "$SOURCE" -resize 48x48 "$ICONS_DIR/favicon-48x48.png"

# Apple Touch Icons (iOS) - 角丸なし、透明なし、JPEGで出力
echo "🍎 Apple Touch Icons生成中..."
convert "$SOURCE" -resize 180x180 -background black -flatten -quality 95 "$ICONS_DIR/apple-touch-icon.png"
convert "$SOURCE" -resize 180x180 -background black -flatten -quality 95 "$ICONS_DIR/apple-touch-icon-180x180.png"
convert "$SOURCE" -resize 167x167 -background black -flatten -quality 95 "$ICONS_DIR/apple-touch-icon-167x167.png"
convert "$SOURCE" -resize 152x152 -background black -flatten -quality 95 "$ICONS_DIR/apple-touch-icon-152x152.png"
convert "$SOURCE" -resize 120x120 -background black -flatten -quality 95 "$ICONS_DIR/apple-touch-icon-120x120.png"

# publicディレクトリにもApple Touch Iconをコピー（Vercel対応）
cp "$ICONS_DIR/apple-touch-icon-180x180.png" "$PUBLIC_DIR/apple-touch-icon.png"

# Android/PWA Icons
echo "🤖 Android/PWA Icons生成中..."
convert "$SOURCE" -resize 72x72 "$ICONS_DIR/icon-72x72.png"
convert "$SOURCE" -resize 96x96 "$ICONS_DIR/icon-96x96.png"
convert "$SOURCE" -resize 128x128 "$ICONS_DIR/icon-128x128.png"
convert "$SOURCE" -resize 144x144 "$ICONS_DIR/icon-144x144.png"
convert "$SOURCE" -resize 152x152 "$ICONS_DIR/icon-152x152.png"
convert "$SOURCE" -resize 192x192 "$ICONS_DIR/icon-192x192.png"
convert "$SOURCE" -resize 384x384 "$ICONS_DIR/icon-384x384.png"
convert "$SOURCE" -resize 512x512 "$ICONS_DIR/icon-512x512.png"

# Maskable Icons (Android Adaptive Icons用)
echo "🎭 Maskable Icons生成中..."
convert "$SOURCE" -resize 512x512 -background black -flatten "$ICONS_DIR/icon-maskable-512x512.png"
convert "$SOURCE" -resize 192x192 -background black -flatten "$ICONS_DIR/icon-maskable-192x192.png"

# favicon.ico生成（マルチサイズ）
echo "🔷 favicon.ico生成中..."
convert "$ICONS_DIR/favicon-16x16.png" "$ICONS_DIR/favicon-32x32.png" "$ICONS_DIR/favicon-48x48.png" "favicon.ico"

echo ""
echo "✅ アイコン生成完了！"
