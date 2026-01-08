# 📧 メール通知機能 - クイックセットアップガイド

## 🎯 目的

営業メンバーが日報を提出したら、**official.riatis.sports@gmail.com** に自動でメール通知が届きます。

---

## ⚡ 最速セットアップ（推奨）

### Step 1: Supabase SQLを実行（データベース設定） 🗄️

> **💡 何をするの？**  
> データベースに「日報が保存されたら自動でメール送信する」という仕組み（Trigger）を設定します。

---

**手順:**

1. **Supabase Dashboardを開く**
   - https://supabase.com/dashboard にアクセス
   - プロジェクト「ONE TEAM」をクリック

2. **SQL Editorを開く**
   - 左メニューの **「SQL Editor」** をクリック（SQLのアイコン）
   - 「New query」ボタンをクリック（または既存のクエリタブを使用）

3. **SQLファイルの内容をコピペ**
   - プロジェクトフォルダから `supabase-email-notification-setup.sql` ファイルを開く
   - **ファイルの全内容をコピー**
   - SQL Editorの画面に**ペースト**

4. **実行する**
   - 右下の **「Run」** ボタンをクリック（または `Ctrl+Enter` / `⌘+Enter`）
   - 「Success. No rows returned」と表示されればOK! ✅

**✅ 確認方法:**
- SQL Editorで以下のSQLを実行:
  ```sql
  SELECT * FROM pg_trigger WHERE tgname = 'trigger_notify_report_submission';
  ```
- 1行結果が返ってくればTriggerが正しく設定されています!

---

**🎯 これで完了！**  
日報が保存されると、自動でメール送信処理が起動するようになりました。

---

### Step 2: Edge Functionデプロイ（メール送信機能を有効化）

> **💡 Edge Functionとは?**  
> Supabaseのサーバー上で動くプログラムのこと。日報が保存されたら、自動でGmailからメールを送信してくれます。

---

#### 2-1. Supabase CLIをインストール 🛠️

**何をするの？**  
パソコンからSupabaseを操作できるツールをインストールします。

**手順:**

1. **ターミナル（コマンドプロンプト）を開く**
   - Mac: Spotlight検索 (⌘+スペース) → 「ターミナル」と入力
   - Windows: スタートメニュー → 「コマンドプロンプト」または「PowerShell」

2. **以下のコマンドを実行**
   ```bash
   npm install -g supabase
   ```

3. **確認**
   ```bash
   supabase --version
   ```
   バージョン番号（例: `1.150.0`）が表示されればOK! ✅

**❌ エラーが出たら?**
- `npm: command not found` → Node.jsがインストールされていません
  - https://nodejs.org/ から最新版をダウンロードしてインストール
  - インストール後、ターミナルを再起動して再度実行

---

#### 2-2. Supabaseにログイン & プロジェクトをリンク 🔗

**何をするの？**  
あなたのSupabaseアカウントにログインして、ONE TEAMプロジェクトと紐付けます。

**手順:**

1. **Supabaseにログイン**
   ```bash
   supabase login
   ```
   
   **何が起きるか:**
   - ブラウザが自動で開きます
   - 「Authorize Supabase CLI」という画面が表示されます
   - **「Authorize」ボタンをクリック**
   - ターミナルに戻って `Logged in.` と表示されればOK! ✅

2. **プロジェクトをリンク**
   ```bash
   supabase link --project-ref ujoyyhhgvdlfvmlnnpwz
   ```
   
   **何が起きるか:**
   - 「Enter your database password」と聞かれます
   - **Supabaseのデータベースパスワードを入力**（画面には表示されません）
   - `Linked to project: ujoyyhhgvdlfvmlnnpwz` と表示されればOK! ✅

**🔑 データベースパスワードがわからない場合:**
1. https://supabase.com/dashboard にアクセス
2. プロジェクト「ONE TEAM」を選択
3. 左メニュー「Settings」 → 「Database」
4. 「Database Password」をリセットして新しいパスワードを取得

---

#### 2-3. Edge Functionをデプロイ 🚀

**何をするの？**  
メール送信プログラムをSupabaseのサーバーにアップロードします。

**手順:**

1. **ターミナルでプロジェクトフォルダに移動**
   ```bash
   cd /path/to/webapp
   ```
   
   **例:**
   - Mac: `cd ~/Desktop/webapp`
   - Windows: `cd C:\Users\YourName\Desktop\webapp`

2. **Edge Functionをデプロイ**
   ```bash
   supabase functions deploy send-report-notification
   ```
   
   **何が起きるか:**
   - `Deploying function...` と表示されます
   - 数秒〜数十秒待ちます
   - `Deployed function send-report-notification` と表示されればOK! ✅

**✅ 確認方法:**
1. https://supabase.com/dashboard にアクセス
2. プロジェクト「ONE TEAM」を選択
3. 左メニュー「Edge Functions」をクリック
4. `send-report-notification` が表示されていればOK!

---

#### 2-4. Gmail設定（メール送信に必要なパスワード取得） 📧

**何をするの？**  
GmailからメールをSupabaseが送信できるように、専用パスワードを取得します。

> **⚠️ 重要:** 通常のGmailパスワードではなく、**アプリ専用パスワード**を使います。

---

##### 📝 Gmail App Passwordを取得する

**手順（画像付き解説）:**

1. **Googleアカウントのセキュリティページを開く**
   - https://myaccount.google.com/security にアクセス
   - `official.riatis.sports@gmail.com` でログイン

2. **2段階認証を有効化（まだの場合）**
   - 「Google へのログイン」セクションを探す
   - 「2段階認証プロセス」をクリック
   - 画面の指示に従って設定（スマホで認証コードを受け取る）
   - ✅ 「オンになっています」と表示されればOK

3. **アプリパスワードを生成**
   - 2段階認証の設定ページの下の方にスクロール
   - **「アプリパスワード」** をクリック（見つからない場合は検索ボックスで「アプリパスワード」と検索）
   - 「アプリを選択」 → **「メール」** を選択
   - 「デバイスを選択」 → **「その他（カスタム名）」** を選択 → `ONE TEAM` と入力
   - **「生成」** ボタンをクリック
   - **16桁のパスワードが表示されます**（例: `abcd efgh ijkl mnop`）
   - ⚠️ **このパスワードをコピーして保存してください!** 二度と表示されません!

---

##### 🔐 Supabaseに環境変数を設定する

**何をするの？**  
先ほど取得した16桁のパスワードをSupabaseに登録します。

**手順:**

1. **ターミナルで以下のコマンドを1行ずつ実行**

   ```bash
   supabase secrets set SMTP_HOST=smtp.gmail.com
   ```
   → `Set secret SMTP_HOST for project ujoyyhhgvdlfvmlnnpwz.` と表示

   ```bash
   supabase secrets set SMTP_PORT=587
   ```
   → `Set secret SMTP_PORT for project ujoyyhhgvdlfvmlnnpwz.` と表示

   ```bash
   supabase secrets set SMTP_USER=official.riatis.sports@gmail.com
   ```
   → `Set secret SMTP_USER for project ujoyyhhgvdlfvmlnnpwz.` と表示

   ```bash
   supabase secrets set SMTP_PASSWORD=abcdefghijklmnop
   ```
   ⚠️ **`abcdefghijklmnop` の部分を、先ほど取得した16桁のパスワードに置き換えてください!**  
   （スペースは削除して、16文字を続けて入力）
   
   → `Set secret SMTP_PASSWORD for project ujoyyhhgvdlfvmlnnpwz.` と表示

2. **確認**
   ```bash
   supabase secrets list
   ```
   以下のように4つのシークレットが表示されればOK! ✅
   ```
   SMTP_HOST
   SMTP_PORT
   SMTP_USER
   SMTP_PASSWORD
   ```

---

**🎉 これでStep 2完了です!**  
次はStep 3でテストしてみましょう!

---

### Step 3: テスト（メールが届くか確認） ✅

**手順:**

1. **ONE TEAMアプリを開く**
   - https://your-vercel-app.vercel.app/ にアクセス
   - ユーザーIDとパスワードでログイン

2. **日報画面で適当な数値を入力**
   - 売上金額: `100000` と入力
   - オファー数: `5` と入力
   - その他の項目も適当に入力
   - 明日のネクストアクション: `テストです` と入力

3. **「保存する」ボタンをクリック**
   - 「✅ 日報を保存しました!」と表示される

4. **ブラウザのコンソールを開いてログを確認**
   - キーボードの `F12` を押す（Mac: `⌘+Option+I`）
   - 「Console」タブをクリック
   - 以下のようなログが表示されていればOK:
     ```
     📧 メール通知を送信中... {user: "営業太郎", date: "2026-01-08"}
     ✅ メール通知を送信しました: {success: true, ...}
     ```
   
   **❌ エラーが出た場合:**
   - `⚠️ メール通知の送信に失敗` → Step 2-4のGmail設定を再確認
   - 詳細なエラーメッセージをコピーして、トラブルシューティングセクションを参照

5. **メールボックスを確認**
   - `official.riatis.sports@gmail.com` の受信トレイを開く
   - 件名 `[ONE TEAM] 日報提出通知 - 営業太郎` のメールが届いていればOK! 🎉
   
   **📫 メールが届かない場合:**
   - 迷惑メールフォルダを確認
   - 5〜10分待ってから再度確認
   - それでも届かない場合は、トラブルシューティングセクションを参照

---

**🎊 成功！メール通知が動作しています！**

---

## ✉️ メール内容

**件名:**
```
[ONE TEAM] 日報提出通知 - 営業太郎
```

**本文:**
```
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
```

---

## 🔍 トラブルシューティング

### メールが届かない

**1. Edge Functionログ確認**
```bash
supabase functions logs send-report-notification
```

**2. Trigger確認**
```sql
SELECT * FROM pg_trigger WHERE tgname = 'trigger_notify_report_submission';
```

**3. Gmail App Passwordの再確認**
- スペースなしで入力されているか
- 正しい16桁のパスワードか

**4. スパムフォルダを確認**

---

## 📦 ファイル構成

```
webapp/
├── supabase-email-notification-setup.sql  # Database Trigger設定
├── supabase/
│   └── functions/
│       └── send-report-notification/
│           └── index.ts                   # メール送信ロジック
├── js/
│   ├── email-notification.js              # メール通知ヘルパー
│   └── report.js                          # 日報保存時に通知呼び出し
└── report.html                            # メール通知スクリプト読み込み
```

---

## 🚀 完了！

これで営業メンバーが日報を保存するたびに、自動でメール通知が `official.riatis.sports@gmail.com` に届きます。

---

**作成日**: 2026-01-08  
**所要時間**: 約10分
