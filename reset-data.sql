-- ONE TEAM - データリセットSQL
-- 本番運用開始前にテストデータを削除するスクリプト
-- このSQLをSupabase SQL Editorで実行してください

-- ⚠️ 警告: このスクリプトは全てのデータを削除します
-- 実行前に必ずバックアップを取得してください

-- 1. 日報データを全て削除
DELETE FROM daily_reports;

-- 2. 個人目標データを全て削除
DELETE FROM individual_goals;

-- 3. チーム目標データを全て削除
DELETE FROM team_goals;

-- 4. サンプルユーザー（user001など）を削除
-- 管理者ユーザー（admin）は残します
DELETE FROM users WHERE role = 'sales_rep';

-- 確認用: 残っているデータを表示
-- SELECT 'users' as table_name, COUNT(*) as count FROM users
-- UNION ALL
-- SELECT 'team_goals', COUNT(*) FROM team_goals
-- UNION ALL
-- SELECT 'individual_goals', COUNT(*) FROM individual_goals
-- UNION ALL
-- SELECT 'daily_reports', COUNT(*) FROM daily_reports
-- UNION ALL
-- SELECT 'quotes', COUNT(*) FROM quotes;

COMMIT;

-- リセット完了後の状態:
-- ✓ quotes: 名言データ（10件）は保持
-- ✓ users: 管理者ユーザー（admin）のみ残る
-- ✗ daily_reports: 全て削除
-- ✗ individual_goals: 全て削除
-- ✗ team_goals: 全て削除
-- ✗ サンプルユーザー: 全て削除

-- 次のステップ:
-- 1. 管理画面（admin.html）から営業メンバーのユーザーIDとパスワードを発行
-- 2. 今月のチーム目標を設定
-- 3. 各メンバーの個人目標を設定
-- 4. 日報入力を開始
