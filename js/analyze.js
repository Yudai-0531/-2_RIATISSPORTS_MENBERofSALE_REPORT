// ONE TEAM - Analyze Page Logic

let currentScope = 'your'; // 'your' or 'team'
let currentPeriod = 'monthly'; // 'daily' or 'monthly'
let currentUser = null;
let revenueChart = null;

document.addEventListener('DOMContentLoaded', async () => {
    // 認証チェック
    if (!SessionManager.requireAuth()) return;

    currentUser = SessionManager.getCurrentUser();
    
    // 初期データ読み込み
    await loadAnalyzeData();

    // コントロールボタンのイベント設定
    setupControls();
    
    // ナビゲーション設定
    setupNavigation();
});

// コントロールボタンの設定
function setupControls() {
    // スコープ切り替え（YOUR / TEAM）
    const scopeButtons = document.querySelectorAll('.scope-toggle .toggle-btn');
    scopeButtons.forEach(btn => {
        btn.addEventListener('click', async () => {
            if (btn.classList.contains('active')) return;
            
            scopeButtons.forEach(b => b.classList.remove('active'));
            btn.classList.add('active');
            
            currentScope = btn.dataset.scope;
            await loadAnalyzeData();
        });
    });

    // 期間切り替え（DAILY / MONTHLY）
    const periodButtons = document.querySelectorAll('.period-toggle .toggle-btn');
    periodButtons.forEach(btn => {
        btn.addEventListener('click', async () => {
            if (btn.classList.contains('active')) return;
            
            periodButtons.forEach(b => b.classList.remove('active'));
            btn.classList.add('active');
            
            currentPeriod = btn.dataset.period;
            await loadAnalyzeData();
        });
    });
}

// 分析データの読み込み
async function loadAnalyzeData() {
    const today = new Date();
    const year = today.getFullYear();
    const month = today.getMonth() + 1;

    if (currentPeriod === 'monthly') {
        await loadMonthlyData(year, month);
    } else {
        await loadDailyData(year, month);
    }
}

// 月次データの読み込み
async function loadMonthlyData(year, month) {
    try {
        let reports, goal;

        if (currentScope === 'your') {
            // 個人データ
            reports = await DataService.getMonthlyReports(currentUser.id, year, month);
            goal = await DataService.getIndividualGoal(currentUser.id, year, month);
        } else {
            // チームデータ
            reports = await DataService.getTeamMonthlyReports(year, month);
            goal = await DataService.getTeamGoal(year, month);
        }

        // 売上集計
        const actualRevenue = reports.reduce((sum, r) => sum + parseFloat(r.revenue_amount || 0), 0);
        const targetRevenue = goal ? parseFloat(goal.revenue_target) : 0;
        const achievementRate = targetRevenue > 0 ? (actualRevenue / targetRevenue * 100).toFixed(1) : 0;

        // サマリー表示
        document.getElementById('targetRevenue').textContent = formatCurrency(targetRevenue);
        document.getElementById('actualRevenue').textContent = formatCurrency(actualRevenue);
        document.getElementById('achievementRate').textContent = `${achievementRate}%`;
        
        // 達成率の色分け
        const achievementEl = document.getElementById('achievementRate');
        if (achievementRate >= 100) {
            achievementEl.style.color = '#00ff00';
        } else if (achievementRate >= 80) {
            achievementEl.style.color = '#ffaa00';
        } else {
            achievementEl.style.color = '#ff0040';
        }

        // 日別売上データを準備
        const daysInMonth = new Date(year, month, 0).getDate();
        const dailyRevenue = Array(daysInMonth).fill(0);
        
        reports.forEach(report => {
            const day = new Date(report.report_date).getDate();
            dailyRevenue[day - 1] = parseFloat(report.revenue_amount || 0);
        });

        // 累積売上を計算
        const cumulativeRevenue = [];
        let sum = 0;
        dailyRevenue.forEach(revenue => {
            sum += revenue;
            cumulativeRevenue.push(sum);
        });

        // グラフ描画
        drawMonthlyChart(cumulativeRevenue, targetRevenue, daysInMonth);

        // KPIサマリー表示
        if (currentScope === 'your' && goal) {
            displayKpiSummary(reports, goal);
        } else {
            document.getElementById('kpiSummary').style.display = 'none';
        }

    } catch (error) {
        console.error('Error loading monthly data:', error);
        alert('データの読み込みに失敗しました');
    }
}

// 日次データの読み込み
async function loadDailyData(year, month) {
    try {
        let reports;

        if (currentScope === 'your') {
            reports = await DataService.getMonthlyReports(currentUser.id, year, month);
        } else {
            reports = await DataService.getTeamMonthlyReports(year, month);
        }

        // 日別売上データを準備
        const daysInMonth = new Date(year, month, 0).getDate();
        const dailyRevenue = Array(daysInMonth).fill(0);
        
        reports.forEach(report => {
            const day = new Date(report.report_date).getDate();
            dailyRevenue[day - 1] = parseFloat(report.revenue_amount || 0);
        });

        // 合計・平均計算
        const totalRevenue = dailyRevenue.reduce((sum, r) => sum + r, 0);
        const avgRevenue = totalRevenue / daysInMonth;

        // サマリー表示（日次は目標なし）
        document.getElementById('targetRevenue').textContent = '---';
        document.getElementById('actualRevenue').textContent = formatCurrency(totalRevenue);
        document.getElementById('achievementRate').textContent = formatCurrency(avgRevenue) + ' /日';
        document.getElementById('achievementRate').style.color = '#00aaff';

        // グラフ描画
        drawDailyChart(dailyRevenue, daysInMonth);

        // KPIサマリーは非表示
        document.getElementById('kpiSummary').style.display = 'none';

    } catch (error) {
        console.error('Error loading daily data:', error);
        alert('データの読み込みに失敗しました');
    }
}

// 月次グラフ描画（累積）
function drawMonthlyChart(cumulativeRevenue, targetRevenue, daysInMonth) {
    const ctx = document.getElementById('revenueChart').getContext('2d');
    
    // 既存グラフを破棄
    if (revenueChart) {
        revenueChart.destroy();
    }

    const labels = Array.from({length: daysInMonth}, (_, i) => `${i + 1}日`);
    const targetLine = Array(daysInMonth).fill(targetRevenue);

    revenueChart = new Chart(ctx, {
        type: 'line',
        data: {
            labels: labels,
            datasets: [
                {
                    label: '実績（累積）',
                    data: cumulativeRevenue,
                    borderColor: '#ff0040',
                    backgroundColor: 'rgba(255, 0, 64, 0.1)',
                    borderWidth: 3,
                    tension: 0.2,
                    fill: true
                },
                {
                    label: '目標',
                    data: targetLine,
                    borderColor: '#666666',
                    borderWidth: 2,
                    borderDash: [5, 5],
                    tension: 0,
                    fill: false,
                    pointRadius: 0
                }
            ]
        },
        options: {
            responsive: true,
            maintainAspectRatio: true,
            plugins: {
                legend: {
                    display: true,
                    labels: {
                        color: '#ffffff',
                        font: { size: 12 }
                    }
                },
                tooltip: {
                    backgroundColor: 'rgba(0, 0, 0, 0.8)',
                    titleColor: '#ff0040',
                    bodyColor: '#ffffff',
                    callbacks: {
                        label: function(context) {
                            return context.dataset.label + ': ' + formatCurrency(context.parsed.y);
                        }
                    }
                }
            },
            scales: {
                x: {
                    ticks: { color: '#999999' },
                    grid: { color: 'rgba(255, 255, 255, 0.1)' }
                },
                y: {
                    ticks: { 
                        color: '#999999',
                        callback: function(value) {
                            return '¥' + (value / 1000) + 'K';
                        }
                    },
                    grid: { color: 'rgba(255, 255, 255, 0.1)' }
                }
            }
        }
    });
}

// 日次グラフ描画
function drawDailyChart(dailyRevenue, daysInMonth) {
    const ctx = document.getElementById('revenueChart').getContext('2d');
    
    if (revenueChart) {
        revenueChart.destroy();
    }

    const labels = Array.from({length: daysInMonth}, (_, i) => `${i + 1}日`);

    revenueChart = new Chart(ctx, {
        type: 'bar',
        data: {
            labels: labels,
            datasets: [
                {
                    label: '日別売上',
                    data: dailyRevenue,
                    backgroundColor: 'rgba(255, 0, 64, 0.7)',
                    borderColor: '#ff0040',
                    borderWidth: 1
                }
            ]
        },
        options: {
            responsive: true,
            maintainAspectRatio: true,
            plugins: {
                legend: {
                    display: true,
                    labels: {
                        color: '#ffffff',
                        font: { size: 12 }
                    }
                },
                tooltip: {
                    backgroundColor: 'rgba(0, 0, 0, 0.8)',
                    titleColor: '#ff0040',
                    bodyColor: '#ffffff',
                    callbacks: {
                        label: function(context) {
                            return '売上: ' + formatCurrency(context.parsed.y);
                        }
                    }
                }
            },
            scales: {
                x: {
                    ticks: { color: '#999999' },
                    grid: { color: 'rgba(255, 255, 255, 0.1)' }
                },
                y: {
                    ticks: { 
                        color: '#999999',
                        callback: function(value) {
                            return '¥' + (value / 1000) + 'K';
                        }
                    },
                    grid: { color: 'rgba(255, 255, 255, 0.1)' }
                }
            }
        }
    });
}

// KPIサマリー表示
function displayKpiSummary(reports, goal) {
    document.getElementById('kpiSummary').style.display = 'block';

    // 累積KPI計算
    const totalOffer = reports.reduce((sum, r) => sum + (r.offer_count || 0), 0);
    const totalNegotiation = reports.reduce((sum, r) => sum + (r.negotiation_count || 0), 0);
    const totalClosing = reports.reduce((sum, r) => sum + (r.closing_count || 0), 0);
    const totalRiatis = reports.reduce((sum, r) => sum + (r.riatis_view_count || 0), 0);
    const totalCrm = reports.reduce((sum, r) => sum + (r.crm_time || 0), 0);

    // 表示
    document.getElementById('kpiOffer').textContent = totalOffer;
    document.getElementById('kpiNegotiation').textContent = totalNegotiation;
    document.getElementById('kpiClosing').textContent = totalClosing;
    document.getElementById('kpiRiatis').textContent = totalRiatis;
    document.getElementById('kpiCrm').textContent = totalCrm + '分';

    // 目標表示
    if (goal.monthly_offer_target) {
        document.getElementById('kpiOfferTarget').textContent = `目標: ${goal.monthly_offer_target}`;
    }
    if (goal.monthly_negotiation_target) {
        document.getElementById('kpiNegotiationTarget').textContent = `目標: ${goal.monthly_negotiation_target}`;
    }
    if (goal.monthly_closing_target) {
        document.getElementById('kpiClosingTarget').textContent = `目標: ${goal.monthly_closing_target}`;
    }
    if (goal.monthly_riatis_view_target) {
        document.getElementById('kpiRiatisTarget').textContent = `目標: ${goal.monthly_riatis_view_target}`;
    }
    if (goal.monthly_crm_time_target) {
        document.getElementById('kpiCrmTarget').textContent = `目標: ${goal.monthly_crm_time_target}分`;
    }
}

// ナビゲーション設定
function setupNavigation() {
    const navButtons = document.querySelectorAll('.nav-btn');
    
    navButtons.forEach(btn => {
        btn.addEventListener('click', () => {
            const page = btn.dataset.page;
            if (page === 'report') {
                window.location.href = 'report.html';
            } else if (page === 'analyze') {
                // 既に分析ページにいる
            }
        });
    });

    document.getElementById('logoutBtn').addEventListener('click', () => {
        if (confirm('ログアウトしますか？')) {
            SessionManager.logout();
        }
    });
}

// ユーティリティ関数
function formatCurrency(amount) {
    return `¥${Number(amount).toLocaleString('ja-JP')}`;
}
