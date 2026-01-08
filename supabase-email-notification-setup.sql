-- ONE TEAM - Email Notification Setup for Daily Report Submission
-- このSQLをSupabase SQL Editorで実行してください

-- ============================================
-- メール通知用のDatabase Function作成
-- ============================================

-- 日報提出時に管理者にメール通知を送る関数
CREATE OR REPLACE FUNCTION notify_report_submission()
RETURNS TRIGGER AS $$
DECLARE
    user_name TEXT;
    report_time TIMESTAMP WITH TIME ZONE;
    email_subject TEXT;
    email_body TEXT;
BEGIN
    -- ユーザー名を取得
    SELECT name INTO user_name
    FROM users
    WHERE id = NEW.user_id;

    -- 報告時刻
    report_time := NEW.updated_at;

    -- メール件名
    email_subject := '[ONE TEAM] 日報提出通知 - ' || COALESCE(user_name, 'Unknown User');

    -- メール本文（HTML形式）
    email_body := format(
        '<html>
        <head>
            <style>
                body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
                .header { background-color: #FF0040; color: white; padding: 20px; text-align: center; }
                .content { padding: 20px; background-color: #f4f4f4; }
                .kpi-table { width: 100%%; border-collapse: collapse; margin: 20px 0; background-color: white; }
                .kpi-table th, .kpi-table td { padding: 12px; text-align: left; border-bottom: 1px solid #ddd; }
                .kpi-table th { background-color: #1a1a1a; color: white; }
                .footer { padding: 20px; text-align: center; font-size: 12px; color: #666; }
                .highlight { color: #FF0040; font-weight: bold; }
            </style>
        </head>
        <body>
            <div class="header">
                <h1>📊 ONE TEAM 日報提出通知</h1>
            </div>
            <div class="content">
                <h2>日報が提出されました</h2>
                <p><strong class="highlight">提出者:</strong> %s</p>
                <p><strong class="highlight">提出日時:</strong> %s</p>
                <p><strong class="highlight">対象日:</strong> %s</p>
                
                <h3>📈 本日のKPI実績</h3>
                <table class="kpi-table">
                    <tr>
                        <th>項目</th>
                        <th>実績</th>
                    </tr>
                    <tr>
                        <td>💰 売上金額</td>
                        <td><strong>¥%s</strong></td>
                    </tr>
                    <tr>
                        <td>📧 オファー数</td>
                        <td>%s 件</td>
                    </tr>
                    <tr>
                        <td>🤝 商談数</td>
                        <td>%s 件</td>
                    </tr>
                    <tr>
                        <td>✅ 成約数</td>
                        <td>%s 件</td>
                    </tr>
                    <tr>
                        <td>📺 RIATIS視聴数</td>
                        <td>%s 回</td>
                    </tr>
                    <tr>
                        <td>⏱️ CRM操作時間</td>
                        <td>%s 分</td>
                    </tr>
                </table>

                <h3>🎯 明日のアクション</h3>
                <p style="background-color: white; padding: 15px; border-left: 4px solid #FF0040;">
                    %s
                </p>
            </div>
            <div class="footer">
                <p>このメールは ONE TEAM システムから自動送信されています。</p>
                <p>© 2026 RIATIS Sports</p>
            </div>
        </body>
        </html>',
        COALESCE(user_name, 'Unknown User'),
        to_char(report_time, 'YYYY-MM-DD HH24:MI:SS'),
        to_char(NEW.report_date, 'YYYY-MM-DD'),
        to_char(COALESCE(NEW.revenue_amount, 0), 'FM999,999,999'),
        COALESCE(NEW.offer_count, 0),
        COALESCE(NEW.negotiation_count, 0),
        COALESCE(NEW.closing_count, 0),
        COALESCE(NEW.riatis_view_count, 0),
        COALESCE(NEW.crm_time, 0),
        COALESCE(NEW.next_action, '（未入力）')
    );

    -- Supabase Edge Functionを呼び出してメール送信
    -- 注意: この部分は後でEdge Functionで実装します
    PERFORM net.http_post(
        url := current_setting('app.edge_function_url', true) || '/send-report-notification',
        headers := jsonb_build_object(
            'Content-Type', 'application/json',
            'Authorization', 'Bearer ' || current_setting('app.edge_function_secret', true)
        ),
        body := jsonb_build_object(
            'to', 'official.riatis.sports@gmail.com',
            'subject', email_subject,
            'html', email_body,
            'user_name', user_name,
            'report_date', NEW.report_date,
            'report_time', report_time
        )
    );

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- Triggerの作成
-- ============================================

-- 日報がINSERTまたはUPDATEされた時に通知を送る
DROP TRIGGER IF EXISTS trigger_notify_report_submission ON daily_reports;

CREATE TRIGGER trigger_notify_report_submission
    AFTER INSERT OR UPDATE ON daily_reports
    FOR EACH ROW
    EXECUTE FUNCTION notify_report_submission();

-- ============================================
-- 設定の説明
-- ============================================

COMMENT ON FUNCTION notify_report_submission() IS 
'日報提出時に管理者メール(official.riatis.sports@gmail.com)に通知を送信する関数。
営業メンバーが日報を保存すると自動的にトリガーされます。';

-- ============================================
-- 補足: Edge Function設定について
-- ============================================

-- 以下の設定をSupabase Dashboardで行う必要があります:
-- 
-- 1. Edge Functionの作成:
--    - Supabase Dashboard > Edge Functions
--    - 関数名: send-report-notification
--    - 実装内容: supabase/functions/send-report-notification/index.ts
--
-- 2. 環境変数の設定:
--    - SMTP設定（Gmail SMTP or SendGrid API Key）
--    - ADMIN_EMAIL: official.riatis.sports@gmail.com
--
-- 3. Database設定値（必要に応じて）:
--    ALTER DATABASE postgres SET app.edge_function_url = 'https://[your-project-ref].supabase.co/functions/v1';
--    ALTER DATABASE postgres SET app.edge_function_secret = '[your-anon-key]';

COMMIT;
