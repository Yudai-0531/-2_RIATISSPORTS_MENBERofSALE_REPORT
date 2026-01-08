// ONE TEAM - Email Notification Edge Function
// 日報提出時に管理者にメール通知を送信する

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { SmtpClient } from "https://deno.land/x/smtp@v0.7.0/mod.ts"

const ADMIN_EMAIL = "official.riatis.sports@gmail.com";

// Gmail SMTP設定（環境変数から取得）
const SMTP_HOST = Deno.env.get("SMTP_HOST") || "smtp.gmail.com";
const SMTP_PORT = parseInt(Deno.env.get("SMTP_PORT") || "587");
const SMTP_USER = Deno.env.get("SMTP_USER") || "";
const SMTP_PASSWORD = Deno.env.get("SMTP_PASSWORD") || "";

interface ReportNotification {
  to: string;
  subject: string;
  html: string;
  user_name: string;
  report_date: string;
  report_time: string;
}

serve(async (req) => {
  // CORS設定
  if (req.method === 'OPTIONS') {
    return new Response('ok', {
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'POST',
        'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
      }
    })
  }

  try {
    const notification: ReportNotification = await req.json();

    console.log('Sending email notification:', {
      to: notification.to,
      user: notification.user_name,
      date: notification.report_date,
    });

    // SMTPクライアント設定
    const client = new SmtpClient();

    await client.connectTLS({
      hostname: SMTP_HOST,
      port: SMTP_PORT,
      username: SMTP_USER,
      password: SMTP_PASSWORD,
    });

    // メール送信
    await client.send({
      from: SMTP_USER,
      to: ADMIN_EMAIL,
      subject: notification.subject,
      content: notification.html,
      html: notification.html,
    });

    await client.close();

    console.log('Email sent successfully to', ADMIN_EMAIL);

    return new Response(
      JSON.stringify({
        success: true,
        message: 'Email notification sent successfully',
        timestamp: new Date().toISOString(),
      }),
      {
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        },
        status: 200,
      }
    );

  } catch (error) {
    console.error('Error sending email:', error);
    
    return new Response(
      JSON.stringify({
        success: false,
        error: error.message,
        timestamp: new Date().toISOString(),
      }),
      {
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        },
        status: 500,
      }
    );
  }
})
