# ONE TEAM - メール通知機能 セットアップガイド

## 概要

営業メンバーが日報を提出すると、自動的に管理者メールアドレス(`official.riatis.sports@gmail.com`)に通知が届く機能です。

---

## 🎯 実装内容

### 通知される情報
- **提出者名**: 誰が報告したか
- **提出日時**: いつ報告したか（時刻まで）
- **対象日**: どの日の日報か
- **KPI実績**: 
  - 売上金額
  - オファー数
  - 商談数
  - 成約数
  - RIATIS視聴数
  - CRM操作時間
- **明日のアクション**: 次のアクションプラン

---

## 📋 セットアップ手順

### 方法1: Supabase Edge Function + Database Trigger（推奨）

#### Step 1: Database Triggerの設定

Supabase SQL Editorで以下のSQLを実行:

```bash
supabase-email-notification-setup.sql
```

このSQLは以下を実行します:
1. メール通知用の関数 `notify_report_submission()` を作成
2. `daily_reports` テーブルにTriggerを設定（INSERT/UPDATE時に発火）

#### Step 2: Edge Functionのデプロイ

```bash
# Supabase CLIをインストール（未インストールの場合）
npm install -g supabase

# Supabaseプロジェクトにログイン
supabase login

# プロジェクトをリンク
supabase link --project-ref ujoyyhhgvdlfvmlnnpwz

# Edge Functionをデプロイ
supabase functions deploy send-report-notification

# 環境変数を設定
supabase secrets set SMTP_HOST=smtp.gmail.com
supabase secrets set SMTP_PORT=587
supabase secrets set SMTP_USER=official.riatis.sports@gmail.com
supabase secrets set SMTP_PASSWORD=your_app_password_here
```

#### Step 3: Gmail App Passwordの取得

1. Google アカウント設定へアクセス: https://myaccount.google.com/
2. セキュリティ → 2段階認証を有効化
3. アプリパスワードを生成
   - アプリ: メール
   - デバイス: その他（「ONE TEAM」と入力）
4. 生成された16桁のパスワードをコピー
5. Step 2の `SMTP_PASSWORD` に設定

---

### 方法2: Webhookを使用した簡易実装

より簡単に実装したい場合は、Supabase Webhookと外部サービス（Zapier、Make.com等）を組み合わせることもできます。

#### Step 1: Supabase Database Webhookを有効化

1. Supabase Dashboard → Database → Webhooks
2. 新しいWebhookを作成:
   - **Name**: `daily-report-notification`
   - **Table**: `daily_reports`
   - **Events**: `INSERT`, `UPDATE`
   - **Type**: `HTTP Request`
   - **URL**: Zapier/Make.comのWebhook URL

#### Step 2: Zapier/Make.comでフローを作成

**Zapierの場合:**

1. Trigger: Webhooks by Zapier → Catch Hook
2. Action: Gmail → Send Email
   - To: `official.riatis.sports@gmail.com`
   - Subject: `[ONE TEAM] 日報提出通知 - {{user_name}}`
   - Body: HTML形式で整形

**Make.com（Integromat）の場合:**

1. Webhook → Custom Webhook
2. Gmail → Send an Email
   - Recipient: `official.riatis.sports@gmail.com`
   - Subject: `[ONE TEAM] 日報提出通知`
   - Content: データを整形して送信

---

## 🧪 テスト方法

### 1. 手動テスト

```sql
-- テストユーザーで日報を作成
INSERT INTO daily_reports (
    user_id, 
    report_date, 
    offer_count, 
    negotiation_count, 
    closing_count, 
    riatis_view_count, 
    crm_time, 
    revenue_amount, 
    next_action
) VALUES (
    (SELECT id FROM users WHERE user_id = 'user001'),
    CURRENT_DATE,
    10,
    5,
    2,
    8,
    120,
    500000,
    '明日は新規顧客3社にアプローチします'
);
```

### 2. アプリからテスト

1. ONE TEAMにログイン
2. 日報画面（REPORT）で各KPIを入力
3. 「保存する」ボタンをクリック
4. `official.riatis.sports@gmail.com` にメールが届くか確認

---

## 📧 メール本文サンプル

```
件名: [ONE TEAM] 日報提出通知 - 営業太郎

━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 ONE TEAM 日報提出通知
━━━━━━━━━━━━━━━━━━━━━━━━━━━━

日報が提出されました

提出者: 営業太郎
提出日時: 2026-01-08 18:30:45
対象日: 2026-01-08

📈 本日のKPI実績
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
💰 売上金額: ¥500,000
📧 オファー数: 10 件
🤝 商談数: 5 件
✅ 成約数: 2 件
📺 RIATIS視聴数: 8 回
⏱️ CRM操作時間: 120 分

🎯 明日のアクション
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
明日は新規顧客3社にアプローチします

━━━━━━━━━━━━━━━━━━━━━━━━━━━━
このメールは ONE TEAM システムから自動送信されています。
© 2026 RIATIS Sports
```

---

## 🔧 トラブルシューティング

### メールが届かない場合

1. **Gmail App Passwordの確認**
   - 16桁のパスワードが正しく設定されているか
   - スペースなしで入力されているか

2. **Edge Functionのログ確認**
   ```bash
   supabase functions logs send-report-notification
   ```

3. **Triggerの動作確認**
   ```sql
   -- Triggerが正しく設定されているか確認
   SELECT * FROM pg_trigger WHERE tgname = 'trigger_notify_report_submission';
   ```

4. **メールがスパムフォルダに入っていないか確認**

### エラーログの確認

```bash
# Supabase Dashboard
# Settings → API → Logs → Functions
```

---

## 🚀 次のステップ

### 拡張機能案

1. **複数の管理者に通知**
   - 管理者テーブルを作成
   - 複数のメールアドレスに一斉送信

2. **通知のカスタマイズ**
   - 特定の条件（売上が目標以上など）でのみ通知
   - 通知頻度の調整（日次サマリー等）

3. **Slack/Discord連携**
   - Edge FunctionでSlack Webhookを呼び出し
   - チームチャットに即座通知

4. **プッシュ通知**
   - Firebase Cloud Messagingを統合
   - モバイルアプリ通知

---

## 📚 参考リンク

- [Supabase Edge Functions](https://supabase.com/docs/guides/functions)
- [Supabase Database Webhooks](https://supabase.com/docs/guides/database/webhooks)
- [Gmail App Password設定](https://support.google.com/accounts/answer/185833)
- [SMTP設定ガイド](https://support.google.com/mail/answer/7126229)

---

**作成日**: 2026-01-08  
**バージョン**: 1.0.0
