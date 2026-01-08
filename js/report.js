// ONE TEAM - Report Page Logic

document.addEventListener('DOMContentLoaded', async () => {
    // 認証チェック
    if (!SessionManager.requireAuth()) return;

    const currentUser = SessionManager.getCurrentUser();
    const today = new Date();
    const year = today.getFullYear();
    const month = today.getMonth() + 1;
    const todayStr = today.toISOString().split('T')[0];

    // 日付表示
    document.getElementById('reportDate').textContent = formatDate(today);

    // データ読み込み
    await loadQuote();
    await loadGoals(currentUser.id, year, month);
    await loadTodayReport(currentUser.id, todayStr);

    // フォーム送信
    const reportForm = document.getElementById('reportForm');
    reportForm.addEventListener('submit', async (e) => {
        e.preventDefault();
        await saveReport(currentUser.id, todayStr);
    });

    // ナビゲーション
    setupNavigation();
});

// 今日の名言を読み込み
async function loadQuote() {
    try {
        const quote = await DataService.getTodayQuote();
        if (quote) {
            document.getElementById('quoteText').textContent = quote.content_en;
            document.getElementById('quoteTextJp').textContent = quote.content_jp;
            document.getElementById('quoteAuthor').textContent = `- ${quote.author}`;
        } else {
            document.getElementById('quoteText').textContent = 'The only way to do great work is to love what you do.';
            document.getElementById('quoteTextJp').textContent = '素晴らしい仕事をする唯一の方法は、自分のやっていることを愛することだ。';
            document.getElementById('quoteAuthor').textContent = '- Steve Jobs';
        }
    } catch (error) {
        console.error('Error loading quote:', error);
    }
}

// 目標を読み込み
async function loadGoals(userId, year, month) {
    try {
        // チーム目標
        const teamGoal = await DataService.getTeamGoal(year, month);
        if (teamGoal) {
            document.getElementById('teamGoal').textContent = formatCurrency(teamGoal.revenue_target);
        }

        // 個人目標
        const individualGoal = await DataService.getIndividualGoal(userId, year, month);
        if (individualGoal) {
            document.getElementById('yourGoal').textContent = formatCurrency(individualGoal.revenue_target);
            
            // 目標値のヒント表示
            if (individualGoal.daily_offer_target > 0) {
                document.getElementById('offerTarget').textContent = `目標: ${individualGoal.daily_offer_target}`;
            }
            if (individualGoal.daily_negotiation_target > 0) {
                document.getElementById('negotiationTarget').textContent = `目標: ${individualGoal.daily_negotiation_target}`;
            }
            if (individualGoal.daily_closing_target > 0) {
                document.getElementById('closingTarget').textContent = `目標: ${individualGoal.daily_closing_target}`;
            }
            if (individualGoal.daily_riatis_view_target > 0) {
                document.getElementById('riatisViewTarget').textContent = `目標: ${individualGoal.daily_riatis_view_target}`;
            }
            if (individualGoal.daily_crm_time_target > 0) {
                document.getElementById('crmTimeTarget').textContent = `目標: ${individualGoal.daily_crm_time_target}分`;
            }
        }
    } catch (error) {
        console.error('Error loading goals:', error);
    }
}

// 今日の日報を読み込み
async function loadTodayReport(userId, date) {
    try {
        const report = await DataService.getDailyReport(userId, date);
        if (report) {
            // フォームに値を設定
            document.getElementById('revenueAmount').value = report.revenue_amount || 0;
            document.getElementById('offerCount').value = report.offer_count || 0;
            document.getElementById('negotiationCount').value = report.negotiation_count || 0;
            document.getElementById('closingCount').value = report.closing_count || 0;
            document.getElementById('riatisViewCount').value = report.riatis_view_count || 0;
            document.getElementById('crmTime').value = report.crm_time || 0;
            document.getElementById('nextAction').value = report.next_action || '';
        }
    } catch (error) {
        console.error('Error loading today report:', error);
    }
}

// 日報を保存
async function saveReport(userId, date) {
    const submitBtn = document.querySelector('.btn-submit');
    submitBtn.disabled = true;
    submitBtn.textContent = '保存中...';

    try {
        const reportData = {
            user_id: userId,
            report_date: date,
            revenue_amount: parseFloat(document.getElementById('revenueAmount').value) || 0,
            offer_count: parseInt(document.getElementById('offerCount').value) || 0,
            negotiation_count: parseInt(document.getElementById('negotiationCount').value) || 0,
            closing_count: parseInt(document.getElementById('closingCount').value) || 0,
            riatis_view_count: parseInt(document.getElementById('riatisViewCount').value) || 0,
            crm_time: parseInt(document.getElementById('crmTime').value) || 0,
            next_action: document.getElementById('nextAction').value.trim()
        };

        await DataService.saveDailyReport(reportData);
        
        // メール通知を送信（非同期・エラーが出ても保存処理は成功扱い）
        try {
            const currentUser = SessionManager.getCurrentUser();
            if (typeof EmailNotificationService !== 'undefined') {
                console.log('📧 メール通知を送信中...', {
                    user: currentUser.name,
                    date: reportData.report_date
                });
                
                // Edge Function経由で送信（推奨）
                const result = await EmailNotificationService.sendReportNotificationViaEdgeFunction(reportData, currentUser);
                
                if (result.success) {
                    console.log('✅ メール通知を送信しました:', result);
                } else {
                    console.warn('⚠️ メール通知の送信に失敗:', result);
                }
            } else {
                console.warn('⚠️ EmailNotificationService が読み込まれていません');
            }
        } catch (emailError) {
            // メール送信失敗しても日報保存は成功として扱う
            console.error('⚠️ メール通知の送信エラー:', emailError);
            console.error('エラー詳細:', emailError.message || emailError);
        }
        
        alert('✅ 日報を保存しました！');
        submitBtn.textContent = '保存する';
        submitBtn.disabled = false;
    } catch (error) {
        console.error('Error saving report:', error);
        alert('❌ 保存に失敗しました。もう一度お試しください。');
        submitBtn.textContent = '保存する';
        submitBtn.disabled = false;
    }
}

// ナビゲーション設定
function setupNavigation() {
    const navButtons = document.querySelectorAll('.nav-btn');
    
    navButtons.forEach(btn => {
        btn.addEventListener('click', () => {
            const page = btn.dataset.page;
            if (page === 'report') {
                // 既に日報ページにいる
            } else if (page === 'analyze') {
                window.location.href = 'analyze.html';
            }
        });
    });

    // ログアウト
    document.getElementById('logoutBtn').addEventListener('click', () => {
        if (confirm('ログアウトしますか？')) {
            SessionManager.logout();
        }
    });
}

// ユーティリティ関数
function formatDate(date) {
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    const weekdays = ['日', '月', '火', '水', '木', '金', '土'];
    const weekday = weekdays[date.getDay()];
    return `${year}年${month}月${day}日（${weekday}）`;
}

function formatCurrency(amount) {
    return `¥${Number(amount).toLocaleString('ja-JP')}`;
}
