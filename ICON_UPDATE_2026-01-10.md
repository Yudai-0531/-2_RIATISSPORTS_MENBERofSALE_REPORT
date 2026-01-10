# ONE TEAM アプリアイコン更新 - 2026-01-10

## 概要
既存のWebアプリの機能を完全に維持したまま、アプリアイコン（Faviconおよびホーム画面追加時のアイコン）を新しいデザインに刷新しました。

## 更新内容

### 1. 新アイコンの生成
- **ソース画像**: `２ONE TEAM_icon.jpeg` (500x500px JPEG)
- **デザイン**: 赤いネオン風の「OT」ロゴと回路図パターン背景
- **処理方法**: ImageMagickを使用して、余白なしで中央にロゴを配置

### 2. 生成されたアイコンサイズ

#### Favicon
- `favicon.ico` (16x16, 32x32, 48x48を含むマルチサイズICO)
- `favicon-16x16.png`
- `favicon-32x32.png`
- `favicon-48x48.png`

#### Apple Touch Icons (iOS対応)
- `apple-touch-icon.png` (180x180 - デフォルト)
- `apple-touch-icon-180x180.png` (iPhone Plus/X)
- `apple-touch-icon-167x167.png` (iPad Pro)
- `apple-touch-icon-152x152.png` (iPad Retina)
- `apple-touch-icon-120x120.png` (iPhone Retina)

#### PWA/Android Icons
- `icon-72x72.png`
- `icon-96x96.png`
- `icon-128x128.png`
- `icon-144x144.png`
- `icon-152x152.png`
- `icon-192x192.png`
- `icon-384x384.png`
- `icon-512x512.png`

#### Maskable Icons (Android Adaptive Icons)
- `icon-maskable-192x192.png` (20%セーフゾーン付き)
- `icon-maskable-512x512.png` (20%セーフゾーン付き)

### 3. 更新されたファイル

#### HTMLファイル
すべてのHTMLファイルのアイコン参照を新バージョン（`v=20260110_v2`）に更新:
- `index.html` (ログイン画面)
- `report.html` (日報入力画面)
- `analyze.html` (分析画面)
- `admin.html` (管理画面)

#### manifest.json
PWAマニフェストファイル内のすべてのアイコン参照を更新

### 4. 技術仕様

#### 画像処理方法
```bash
# 余白なしでアイコンを生成
convert source.jpeg \
    -resize "SIZExSIZE^" \    # ^ で全体を埋める
    -gravity center \          # 中央に配置
    -extent "SIZExSIZE" \      # 指定サイズにクロップ
    -quality 100 \             # 最高品質
    output.png
```

#### Maskable Iconの処理
- アイコンを80%のサイズにリサイズ
- 黒背景で20%のパディングを追加
- Android Adaptive Iconsの要件に準拠

#### キャッシュバスティング
- すべてのアイコン参照に`?v=20260110_v2`クエリパラメータを追加
- ブラウザキャッシュを強制更新

## 機能の保持確認

### 変更なし項目
✅ HTML構造 - 既存のまま保持  
✅ CSS/JavaScript - 一切変更なし  
✅ レポート機能 - 動作そのまま  
✅ 分析機能 - 動作そのまま  
✅ 認証機能 - 動作そのまま  
✅ データベース接続 - 影響なし  

### 変更項目
🔄 アイコンファイル - すべて新デザインに置換  
🔄 HTMLヘッダー - アイコン参照のバージョンパラメータのみ更新  
🔄 manifest.json - アイコンパスのバージョンパラメータのみ更新  

## デプロイ前の確認事項

### ローカルテスト
1. すべてのHTMLファイルがブラウザで正常に表示されることを確認
2. アイコンが正しく読み込まれることを確認
3. PWA機能が正常に動作することを確認

### デバイステスト推奨
- [ ] Chrome (Windows/Mac)でFaviconを確認
- [ ] Safari (iOS)でApple Touch Iconを確認
- [ ] Chrome (Android)でPWAアイコンを確認
- [ ] ホーム画面に追加して表示を確認

### デプロイ後の注意点
1. **キャッシュクリア**: 既存ユーザーには、ブラウザキャッシュのクリアを推奨
2. **PWA再インストール**: ホーム画面に追加済みの場合、一度削除して再追加することで新アイコンが反映
3. **Service Worker**: 必要に応じてService Workerキャッシュをクリア

## 生成スクリプト
`generate-new-icons.sh` - 今後のアイコン更新時に再利用可能

## バックアップ
既存のアイコンは `icons_backup_20260110_115101/` に保存済み

## 変更履歴
- **2026-01-10**: 新デザインアイコンの生成と適用
  - ソース: `２ONE TEAM_icon.jpeg`
  - 生成方法: 余白なし、中央配置、全サイズ対応
  - キャッシュバージョン: `v=20260110_v2`

## 参考情報
- [Apple Touch Icon仕様](https://developer.apple.com/design/human-interface-guidelines/app-icons)
- [PWA Manifest Icons仕様](https://web.dev/add-manifest/)
- [Maskable Icons仕様](https://web.dev/maskable-icon/)
