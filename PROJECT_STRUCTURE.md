# ONE TEAM - プロジェクト構造

## ディレクトリ構成

```
/home/user/webapp/
│
├── index.html              # ログイン画面
├── report.html             # 日報入力画面（未実装）
├── analyze.html            # 分析画面（未実装）
├── admin.html              # 管理画面（未実装）
│
├── css/
│   └── style.css          # メインスタイルシート
│
├── js/
│   ├── auth.js            # 認証ロジック
│   ├── supabase-client.js # Supabase接続（未作成）
│   ├── report.js          # 日報機能（未作成）
│   ├── analyze.js         # 分析機能（未作成）
│   └── admin.js           # 管理機能（未作成）
│
├── images/                # 画像ファイル用
│
├── README.md              # プロジェクト説明
├── PROJECT_STRUCTURE.md   # このファイル
└── .gitignore             # Git除外設定
```

## 実装状況

### ✅ 完了
- [x] プロジェクト初期設定
- [x] ログイン画面UI（HTML/CSS）
- [x] Neon/Cyberpunkデザインベース

### 🚧 次のステップ
- [ ] Supabase設定・接続
- [ ] データベーステーブル設計
- [ ] 認証機能実装
- [ ] 日報入力画面
- [ ] 分析画面
- [ ] 管理画面

## デザインコンセプト

- **カラーパレット**: Black (#000000) + Vivid Red (#ff0040)
- **雰囲気**: Neon/Cyberpunk - クール&アグレッシブ
- **ターゲット**: スマホファースト（レスポンシブ対応）

## 次の開発タスク

1. **Supabaseプロジェクト作成**
   - URL・anon keyの取得
   - テーブル設計・作成

2. **認証機能実装**
   - ログイン処理
   - セッション管理

3. **日報画面開発**
   - モチベーション名言表示
   - KPI入力フォーム

4. **分析画面開発**
   - グラフ表示
   - チーム/個人切り替え

5. **管理画面開発**
   - ユーザー管理
   - 目標設定
