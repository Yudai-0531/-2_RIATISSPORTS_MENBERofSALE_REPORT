# データリセット手順書

## 概要
本番運用開始前にテストデータを削除し、クリーンな状態でアプリを使用開始するための手順です。

---

## ⚠️ 重要な注意事項

- **この操作は元に戻せません**
- 実行前に必ずSupabaseのバックアップを取得してください
- 実行後は管理者ユーザー（admin）のみが残ります

---

## リセット手順

### 1. Supabaseにアクセス

1. ブラウザで [Supabase](https://supabase.com) を開く
2. プロジェクト `ujoyyhhgvdlfvmlnnpwz` にログイン

### 2. SQL Editorを開く

1. 左サイドバーの **SQL Editor** をクリック
2. **+ New query** をクリック

### 3. リセットSQLを実行

1. `reset-data.sql` ファイルの内容をコピー
2. SQL Editorにペースト
3. **Run** ボタンをクリック（または Ctrl + Enter）

### 4. 実行結果の確認

以下のメッセージが表示されればOKです：
```
Success. No rows returned
```

---

## リセット後のデータ状態

| テーブル | 状態 | 説明 |
|---------|------|------|
| **quotes** | ✓ 保持 | 名言データ（10件）は残る |
| **users** | ✓ 管理者のみ | admin ユーザーのみ残る |
| **daily_reports** | ✗ 削除 | 日報データは全て削除 |
| **individual_goals** | ✗ 削除 | 個人目標は全て削除 |
| **team_goals** | ✗ 削除 | チーム目標は全て削除 |

---

## 次のステップ

### 1. 管理者ログイン

```
URL: https://[your-vercel-domain]/index.html
ユーザーID: admin
パスワード: admin123
```

### 2. 営業メンバーのユーザー登録

1. 管理画面（ADMIN）に移動
2. 「ユーザー管理」セクションで各メンバーを登録
   - ユーザーID（例: yamada_taro）
   - 名前（例: 山田太郎）
   - パスワード（各自で決定）

### 3. 今月の目標設定

1. 「チーム目標設定」でチーム全体の売上目標を入力
2. 「個人目標設定」で各メンバーの目標を設定
   - 売上目標
   - オファー数、商談数、成約数などのKPI目標

### 4. 日報入力開始

各メンバーにログイン情報を共有し、本日から日報入力を開始できます。

---

## トラブルシューティング

### エラーが発生した場合

1. **外部キー制約エラー**
   - SQLの実行順序を確認してください
   - `reset-data.sql` の順序通りに実行する必要があります

2. **権限エラー**
   - Supabaseプロジェクトの管理者権限があることを確認してください

3. **データが削除されない**
   - SQL Editorでクエリが正常に実行されたか確認
   - F5でSupabaseダッシュボードをリフレッシュ

### 確認用SQL

データが正しくリセットされたか確認する場合：

```sql
SELECT 'users' as table_name, COUNT(*) as count FROM users
UNION ALL
SELECT 'team_goals', COUNT(*) FROM team_goals
UNION ALL
SELECT 'individual_goals', COUNT(*) FROM individual_goals
UNION ALL
SELECT 'daily_reports', COUNT(*) FROM daily_reports
UNION ALL
SELECT 'quotes', COUNT(*) FROM quotes;
```

期待される結果：
- users: 1件（adminのみ）
- team_goals: 0件
- individual_goals: 0件
- daily_reports: 0件
- quotes: 10件

---

## サポート

問題が発生した場合は、開発者にお問い合わせください。

**作成日**: 2026-01-08
