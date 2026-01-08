// ONE TEAM - Email Notification Helper
// 日報提出時にメール通知を送信するヘルパー関数

/**
 * 代替実装: クライアントサイドからメール送信
 * 
 * Supabase Edge Functionが使えない場合、以下のサービスを利用:
 * - EmailJS (https://www.emailjs.com/)
 * - SendGrid Web API
 * - Resend (https://resend.com/)
 */

class EmailNotificationService {
    // EmailJS設定（無料プランで月200通まで）
    static EMAILJS_SERVICE_ID = 'YOUR_SERVICE_ID'; // EmailJSで取得
    static EMAILJS_TEMPLATE_ID = 'YOUR_TEMPLATE_ID'; // EmailJSで取得
    static EMAILJS_PUBLIC_KEY = 'YOUR_PUBLIC_KEY'; // EmailJSで取得
    static ADMIN_EMAIL = 'official.riatis.sports@gmail.com';

    /**
     * 日報提出通知を送信
     * @param {Object} reportData - 日報データ
     * @param {Object} userData - ユーザーデータ
     */
    static async sendReportNotification(reportData, userData) {
        try {
            // EmailJSが読み込まれているか確認
            if (typeof emailjs === 'undefined') {
                console.warn('EmailJS not loaded. Email notification skipped.');
                return { success: false, error: 'EmailJS not loaded' };
            }

            const templateParams = {
                to_email: this.ADMIN_EMAIL,
                user_name: userData.name || 'Unknown User',
                user_id: userData.user_id,
                report_date: this.formatDate(reportData.report_date),
                report_time: this.formatDateTime(new Date()),
                revenue_amount: this.formatCurrency(reportData.revenue_amount),
                offer_count: reportData.offer_count || 0,
                negotiation_count: reportData.negotiation_count || 0,
                closing_count: reportData.closing_count || 0,
                riatis_view_count: reportData.riatis_view_count || 0,
                crm_time: reportData.crm_time || 0,
                next_action: reportData.next_action || '（未入力）',
            };

            // EmailJSでメール送信
            const response = await emailjs.send(
                this.EMAILJS_SERVICE_ID,
                this.EMAILJS_TEMPLATE_ID,
                templateParams,
                this.EMAILJS_PUBLIC_KEY
            );

            console.log('Email notification sent successfully:', response);
            return { success: true, response };

        } catch (error) {
            console.error('Error sending email notification:', error);
            return { success: false, error: error.message };
        }
    }

    /**
     * Supabase Edge Functionを使用してメール送信
     * @param {Object} reportData - 日報データ
     * @param {Object} userData - ユーザーデータ
     */
    static async sendReportNotificationViaEdgeFunction(reportData, userData) {
        try {
            const notificationData = {
                to: this.ADMIN_EMAIL,
                subject: `[ONE TEAM] 日報提出通知 - ${userData.name}`,
                html: this.buildEmailHTML(reportData, userData),
                user_name: userData.name,
                report_date: reportData.report_date,
                report_time: new Date().toISOString(),
            };

            const response = await fetch(
                `${SUPABASE_URL}/functions/v1/send-report-notification`,
                {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'Authorization': `Bearer ${SUPABASE_ANON_KEY}`,
                    },
                    body: JSON.stringify(notificationData),
                }
            );

            const result = await response.json();

            if (!response.ok) {
                throw new Error(result.error || 'Failed to send notification');
            }

            console.log('Email notification sent via Edge Function:', result);
            return { success: true, result };

        } catch (error) {
            console.error('Error sending email via Edge Function:', error);
            return { success: false, error: error.message };
        }
    }

    /**
     * メールHTML本文を構築
     */
    static buildEmailHTML(reportData, userData) {
        return `
        <html>
        <head>
            <style>
                body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
                .header { background-color: #FF0040; color: white; padding: 20px; text-align: center; }
                .content { padding: 20px; background-color: #f4f4f4; }
                .kpi-table { width: 100%; border-collapse: collapse; margin: 20px 0; background-color: white; }
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
                <p><strong class="highlight">提出者:</strong> ${userData.name}</p>
                <p><strong class="highlight">提出日時:</strong> ${this.formatDateTime(new Date())}</p>
                <p><strong class="highlight">対象日:</strong> ${this.formatDate(reportData.report_date)}</p>
                
                <h3>📈 本日のKPI実績</h3>
                <table class="kpi-table">
                    <tr><th>項目</th><th>実績</th></tr>
                    <tr><td>💰 売上金額</td><td><strong>${this.formatCurrency(reportData.revenue_amount)}</strong></td></tr>
                    <tr><td>📧 オファー数</td><td>${reportData.offer_count || 0} 件</td></tr>
                    <tr><td>🤝 商談数</td><td>${reportData.negotiation_count || 0} 件</td></tr>
                    <tr><td>✅ 成約数</td><td>${reportData.closing_count || 0} 件</td></tr>
                    <tr><td>📺 RIATIS視聴数</td><td>${reportData.riatis_view_count || 0} 回</td></tr>
                    <tr><td>⏱️ CRM操作時間</td><td>${reportData.crm_time || 0} 分</td></tr>
                </table>

                <h3>🎯 明日のアクション</h3>
                <p style="background-color: white; padding: 15px; border-left: 4px solid #FF0040;">
                    ${reportData.next_action || '（未入力）'}
                </p>
            </div>
            <div class="footer">
                <p>このメールは ONE TEAM システムから自動送信されています。</p>
                <p>© 2026 RIATIS Sports</p>
            </div>
        </body>
        </html>
        `;
    }

    // ユーティリティ関数
    static formatDate(dateStr) {
        const date = new Date(dateStr);
        return date.toLocaleDateString('ja-JP', {
            year: 'numeric',
            month: '2-digit',
            day: '2-digit',
        });
    }

    static formatDateTime(date) {
        return date.toLocaleString('ja-JP', {
            year: 'numeric',
            month: '2-digit',
            day: '2-digit',
            hour: '2-digit',
            minute: '2-digit',
            second: '2-digit',
        });
    }

    static formatCurrency(amount) {
        return `¥${Number(amount || 0).toLocaleString('ja-JP')}`;
    }
}
