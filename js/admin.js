// ONE TEAM - Admin Page Logic

let currentTab = 'users';

document.addEventListener('DOMContentLoaded', async () => {
    // 認証チェック（管理者のみ）
    if (!SessionManager.requireAuth()) return;
    
    const currentUser = SessionManager.getCurrentUser();
    if (currentUser.role !== 'admin') {
        alert('管理者権限が必要です');
        window.location.href = 'report.html';
        return;
    }

    // 初期データ読み込み
    await loadUsers();
    await loadUserOptionsForGoals();

    // タブ切り替え
    setupTabs();

    // モーダル設定
    setupModals();

    // フォーム設定
    setupForms();

    // ナビゲーション設定
    setupNavigation();
});

// タブ切り替えの設定
function setupTabs() {
    const tabButtons = document.querySelectorAll('.tab-btn');
    const tabContents = document.querySelectorAll('.tab-content');

    tabButtons.forEach(btn => {
        btn.addEventListener('click', async () => {
            const tabName = btn.dataset.tab;
            
            // アクティブクラスの切り替え
            tabButtons.forEach(b => b.classList.remove('active'));
            btn.classList.add('active');
            
            tabContents.forEach(content => content.classList.remove('active'));
            document.getElementById(`tab-${tabName}`).classList.add('active');
            
            currentTab = tabName;

            // タブごとのデータ読み込み
            if (tabName === 'users') {
                await loadUsers();
            } else if (tabName === 'quotes') {
                await loadQuotes();
            }
        });
    });
}

// ユーザー一覧の読み込み
async function loadUsers() {
    try {
        const { data, error } = await supabaseClient
            .from('users')
            .select('*')
            .order('created_at', { ascending: false });

        if (error) throw error;

        const userList = document.getElementById('userList');
        userList.innerHTML = '';

        if (data.length === 0) {
            userList.innerHTML = '<p class="empty-message">ユーザーが登録されていません</p>';
            return;
        }

        data.forEach(user => {
            const userCard = document.createElement('div');
            userCard.className = 'user-card';
            userCard.innerHTML = `
                <div class="user-info">
                    <h4>${user.name}</h4>
                    <p>ID: ${user.user_id}</p>
                    <span class="role-badge ${user.role}">${user.role === 'admin' ? '管理者' : '営業'}</span>
                </div>
                <div class="user-actions">
                    <button class="btn-edit" onclick="editUser('${user.id}')">編集</button>
                    <button class="btn-delete" onclick="deleteUser('${user.id}', '${user.user_id}')">削除</button>
                </div>
            `;
            userList.appendChild(userCard);
        });
    } catch (error) {
        console.error('Error loading users:', error);
        alert('ユーザー一覧の読み込みに失敗しました');
    }
}

// 目標設定用のユーザー選択肢を読み込み
async function loadUserOptionsForGoals() {
    try {
        const { data, error } = await supabaseClient
            .from('users')
            .select('id, user_id, name')
            .eq('role', 'sales_rep')
            .order('user_id');

        if (error) throw error;

        const select = document.getElementById('goalUserId');
        select.innerHTML = '<option value="">選択してください</option>';
        
        data.forEach(user => {
            const option = document.createElement('option');
            option.value = user.id;
            option.textContent = `${user.name} (${user.user_id})`;
            select.appendChild(option);
        });
    } catch (error) {
        console.error('Error loading user options:', error);
    }
}

// 名言一覧の読み込み
async function loadQuotes() {
    try {
        const { data, error } = await supabaseClient
            .from('quotes')
            .select('*')
            .order('day_of_year', { ascending: true });

        if (error) throw error;

        const quoteList = document.getElementById('quoteList');
        quoteList.innerHTML = '';

        if (data.length === 0) {
            quoteList.innerHTML = '<p class="empty-message">名言が登録されていません</p>';
            return;
        }

        data.forEach(quote => {
            const quoteCard = document.createElement('div');
            quoteCard.className = 'quote-card';
            quoteCard.innerHTML = `
                <div class="quote-info">
                    <span class="quote-day">Day ${quote.day_of_year}</span>
                    <p class="quote-text">${quote.content_en}</p>
                    <p class="quote-text-jp">${quote.content_jp}</p>
                    <p class="quote-author">- ${quote.author}</p>
                </div>
                <div class="quote-actions">
                    <button class="btn-edit" onclick="editQuote('${quote.id}')">編集</button>
                    <button class="btn-delete" onclick="deleteQuote('${quote.id}', ${quote.day_of_year})">削除</button>
                </div>
            `;
            quoteList.appendChild(quoteCard);
        });
    } catch (error) {
        console.error('Error loading quotes:', error);
        alert('名言一覧の読み込みに失敗しました');
    }
}

// モーダルの設定
function setupModals() {
    // ユーザーモーダル
    const userModal = document.getElementById('userModal');
    const quoteModal = document.getElementById('quoteModal');

    document.getElementById('btnAddUser').addEventListener('click', () => {
        openUserModal();
    });

    document.getElementById('btnAddQuote').addEventListener('click', () => {
        openQuoteModal();
    });

    // モーダルクローズ
    document.querySelectorAll('.modal-close, .btn-cancel').forEach(btn => {
        btn.addEventListener('click', () => {
            userModal.style.display = 'none';
            quoteModal.style.display = 'none';
        });
    });

    // モーダル外クリックで閉じる
    window.addEventListener('click', (e) => {
        if (e.target === userModal) userModal.style.display = 'none';
        if (e.target === quoteModal) quoteModal.style.display = 'none';
    });
}

// ユーザーモーダルを開く
function openUserModal(userId = null) {
    const modal = document.getElementById('userModal');
    const form = document.getElementById('userForm');
    
    form.reset();
    document.getElementById('editUserId').value = '';
    document.getElementById('userModalTitle').textContent = '新規ユーザー';
    
    modal.style.display = 'flex';
}

// 名言モーダルを開く
function openQuoteModal(quoteId = null) {
    const modal = document.getElementById('quoteModal');
    const form = document.getElementById('quoteForm');
    
    form.reset();
    document.getElementById('editQuoteId').value = '';
    document.getElementById('quoteModalTitle').textContent = '新規名言';
    
    modal.style.display = 'flex';
}

// ユーザー編集
async function editUser(userId) {
    try {
        const { data, error } = await supabaseClient
            .from('users')
            .select('*')
            .eq('id', userId)
            .single();

        if (error) throw error;

        document.getElementById('editUserId').value = data.id;
        document.getElementById('userId').value = data.user_id;
        document.getElementById('password').value = data.password_hash;
        document.getElementById('userName').value = data.name;
        document.getElementById('userRole').value = data.role;
        document.getElementById('userModalTitle').textContent = 'ユーザー編集';
        
        document.getElementById('userModal').style.display = 'flex';
    } catch (error) {
        console.error('Error loading user:', error);
        alert('ユーザー情報の読み込みに失敗しました');
    }
}

// ユーザー削除
async function deleteUser(userId, userIdStr) {
    if (!confirm(`ユーザー「${userIdStr}」を削除しますか？`)) return;

    try {
        const { error } = await supabaseClient
            .from('users')
            .delete()
            .eq('id', userId);

        if (error) throw error;

        alert('ユーザーを削除しました');
        await loadUsers();
    } catch (error) {
        console.error('Error deleting user:', error);
        alert('ユーザーの削除に失敗しました');
    }
}

// 名言編集
async function editQuote(quoteId) {
    try {
        const { data, error } = await supabaseClient
            .from('quotes')
            .select('*')
            .eq('id', quoteId)
            .single();

        if (error) throw error;

        document.getElementById('editQuoteId').value = data.id;
        document.getElementById('dayOfYear').value = data.day_of_year;
        document.getElementById('quoteAuthor').value = data.author;
        document.getElementById('quoteContentEn').value = data.content_en;
        document.getElementById('quoteContentJp').value = data.content_jp;
        document.getElementById('quoteModalTitle').textContent = '名言編集';
        
        document.getElementById('quoteModal').style.display = 'flex';
    } catch (error) {
        console.error('Error loading quote:', error);
        alert('名言情報の読み込みに失敗しました');
    }
}

// 名言削除
async function deleteQuote(quoteId, dayOfYear) {
    if (!confirm(`Day ${dayOfYear}の名言を削除しますか？`)) return;

    try {
        const { error } = await supabaseClient
            .from('quotes')
            .delete()
            .eq('id', quoteId);

        if (error) throw error;

        alert('名言を削除しました');
        await loadQuotes();
    } catch (error) {
        console.error('Error deleting quote:', error);
        alert('名言の削除に失敗しました');
    }
}

// フォームの設定
function setupForms() {
    // ユーザーフォーム
    document.getElementById('userForm').addEventListener('submit', async (e) => {
        e.preventDefault();
        await saveUser();
    });

    // チーム目標フォーム
    document.getElementById('teamGoalForm').addEventListener('submit', async (e) => {
        e.preventDefault();
        await saveTeamGoal();
    });

    // 個人目標フォーム
    document.getElementById('individualGoalForm').addEventListener('submit', async (e) => {
        e.preventDefault();
        await saveIndividualGoal();
    });

    // 名言フォーム
    document.getElementById('quoteForm').addEventListener('submit', async (e) => {
        e.preventDefault();
        await saveQuote();
    });
}

// ユーザー保存
async function saveUser() {
    const editUserId = document.getElementById('editUserId').value;
    const userData = {
        user_id: document.getElementById('userId').value.trim(),
        password_hash: document.getElementById('password').value,
        name: document.getElementById('userName').value.trim(),
        role: document.getElementById('userRole').value
    };

    try {
        let error;
        if (editUserId) {
            // 更新
            ({ error } = await supabaseClient
                .from('users')
                .update(userData)
                .eq('id', editUserId));
        } else {
            // 新規作成
            ({ error } = await supabaseClient
                .from('users')
                .insert([userData]));
        }

        if (error) throw error;

        alert('ユーザーを保存しました');
        document.getElementById('userModal').style.display = 'none';
        await loadUsers();
        await loadUserOptionsForGoals();
    } catch (error) {
        console.error('Error saving user:', error);
        alert('ユーザーの保存に失敗しました: ' + error.message);
    }
}

// チーム目標保存
async function saveTeamGoal() {
    const goalData = {
        year: parseInt(document.getElementById('teamYear').value),
        month: parseInt(document.getElementById('teamMonth').value),
        revenue_target: parseFloat(document.getElementById('teamRevenueTarget').value)
    };

    try {
        const { error } = await supabaseClient
            .from('team_goals')
            .upsert([goalData], { onConflict: 'year,month' });

        if (error) throw error;

        alert('チーム目標を保存しました');
    } catch (error) {
        console.error('Error saving team goal:', error);
        alert('チーム目標の保存に失敗しました');
    }
}

// 個人目標保存
async function saveIndividualGoal() {
    const userId = document.getElementById('goalUserId').value;
    if (!userId) {
        alert('ユーザーを選択してください');
        return;
    }

    const goalData = {
        user_id: userId,
        year: parseInt(document.getElementById('goalYear').value),
        month: parseInt(document.getElementById('goalMonth').value),
        revenue_target: parseFloat(document.getElementById('revenueTarget').value || 0),
        daily_offer_target: parseInt(document.getElementById('dailyOfferTarget').value || 0),
        daily_negotiation_target: parseInt(document.getElementById('dailyNegotiationTarget').value || 0),
        daily_closing_target: parseInt(document.getElementById('dailyClosingTarget').value || 0),
        daily_riatis_view_target: parseInt(document.getElementById('dailyRiatisTarget').value || 0),
        daily_crm_time_target: parseInt(document.getElementById('dailyCrmTarget').value || 0),
        monthly_offer_target: parseInt(document.getElementById('monthlyOfferTarget').value || 0),
        monthly_negotiation_target: parseInt(document.getElementById('monthlyNegotiationTarget').value || 0),
        monthly_closing_target: parseInt(document.getElementById('monthlyClosingTarget').value || 0),
        monthly_riatis_view_target: parseInt(document.getElementById('monthlyRiatisTarget').value || 0),
        monthly_crm_time_target: parseInt(document.getElementById('monthlyCrmTarget').value || 0)
    };

    try {
        const { error } = await supabaseClient
            .from('individual_goals')
            .upsert([goalData], { onConflict: 'user_id,year,month' });

        if (error) throw error;

        alert('個人目標を保存しました');
    } catch (error) {
        console.error('Error saving individual goal:', error);
        alert('個人目標の保存に失敗しました');
    }
}

// 名言保存
async function saveQuote() {
    const editQuoteId = document.getElementById('editQuoteId').value;
    const quoteData = {
        day_of_year: parseInt(document.getElementById('dayOfYear').value),
        author: document.getElementById('quoteAuthor').value.trim(),
        content_en: document.getElementById('quoteContentEn').value.trim(),
        content_jp: document.getElementById('quoteContentJp').value.trim()
    };

    try {
        let error;
        if (editQuoteId) {
            // 更新
            ({ error } = await supabaseClient
                .from('quotes')
                .update(quoteData)
                .eq('id', editQuoteId));
        } else {
            // 新規作成
            ({ error } = await supabaseClient
                .from('quotes')
                .insert([quoteData]));
        }

        if (error) throw error;

        alert('名言を保存しました');
        document.getElementById('quoteModal').style.display = 'none';
        await loadQuotes();
    } catch (error) {
        console.error('Error saving quote:', error);
        alert('名言の保存に失敗しました: ' + error.message);
    }
}

// ナビゲーション設定
function setupNavigation() {
    document.getElementById('backToReportBtn').addEventListener('click', () => {
        window.location.href = 'report.html';
    });

    document.getElementById('logoutBtn').addEventListener('click', () => {
        if (confirm('ログアウトしますか？')) {
            SessionManager.logout();
        }
    });
}
