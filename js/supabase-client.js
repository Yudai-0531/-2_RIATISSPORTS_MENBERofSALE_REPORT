// ONE TEAM - Supabase Client Configuration

const SUPABASE_URL = 'https://ujoyyhhgvdlfvmlnnpwz.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVqb3l5aGhndmRsZnZtbG5ucHd6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njc4NTkwODEsImV4cCI6MjA4MzQzNTA4MX0.E8qb3ei8tscPoWZHNC-IB7XJSQ4brf3swWa1G5YK4xA';

// Supabase クライアントの初期化
const supabaseClient = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

// セッション管理
class SessionManager {
    static async login(userId, password) {
        try {
            // usersテーブルからユーザー情報を取得
            const { data, error } = await supabaseClient
                .from('users')
                .select('*')
                .eq('user_id', userId)
                .single();

            if (error || !data) {
                throw new Error('ユーザーIDまたはパスワードが間違っています');
            }

            // パスワード検証（簡易版 - 本番環境ではbcryptなどを使用）
            // TODO: パスワードハッシュの検証を実装
            const isValidPassword = await this.verifyPassword(password, data.password_hash);
            
            if (!isValidPassword) {
                throw new Error('ユーザーIDまたはパスワードが間違っています');
            }

            // セッション情報を保存
            localStorage.setItem('currentUser', JSON.stringify({
                id: data.id,
                user_id: data.user_id,
                role: data.role,
                name: data.name
            }));

            return data;
        } catch (error) {
            console.error('Login error:', error);
            throw error;
        }
    }

    static async verifyPassword(inputPassword, storedHash) {
        // TODO: 本番環境では適切なハッシュ検証を実装
        // 現在は簡易実装（開発用）
        return inputPassword === storedHash || storedHash === '$2a$10$example_hash_replace_this';
    }

    static logout() {
        localStorage.removeItem('currentUser');
        window.location.href = 'index.html';
    }

    static getCurrentUser() {
        const userStr = localStorage.getItem('currentUser');
        return userStr ? JSON.parse(userStr) : null;
    }

    static isAuthenticated() {
        return this.getCurrentUser() !== null;
    }

    static isAdmin() {
        const user = this.getCurrentUser();
        return user && user.role === 'admin';
    }

    static requireAuth() {
        if (!this.isAuthenticated()) {
            window.location.href = 'index.html';
            return false;
        }
        return true;
    }

    static requireAdmin() {
        if (!this.isAdmin()) {
            alert('管理者権限が必要です');
            window.location.href = 'index.html';
            return false;
        }
        return true;
    }
}

// データ取得ヘルパー関数
class DataService {
    // 今日の名言を取得
    static async getTodayQuote() {
        const dayOfYear = this.getDayOfYear();
        const { data, error } = await supabase
            .from('quotes')
            .select('*')
            .eq('day_of_year', dayOfYear)
            .single();

        if (error) {
            console.error('Error fetching quote:', error);
            return null;
        }
        return data;
    }

    // 1年の何日目かを計算
    static getDayOfYear() {
        const now = new Date();
        const start = new Date(now.getFullYear(), 0, 0);
        const diff = now - start;
        const oneDay = 1000 * 60 * 60 * 24;
        return Math.floor(diff / oneDay);
    }

    // チーム目標を取得
    static async getTeamGoal(year, month) {
        const { data, error } = await supabaseClient
            .from('team_goals')
            .select('*')
            .eq('year', year)
            .eq('month', month)
            .single();

        if (error) {
            console.error('Error fetching team goal:', error);
            return null;
        }
        return data;
    }

    // 個人目標を取得
    static async getIndividualGoal(userId, year, month) {
        const { data, error } = await supabase
            .from('individual_goals')
            .select('*')
            .eq('user_id', userId)
            .eq('year', year)
            .eq('month', month)
            .single();

        if (error) {
            console.error('Error fetching individual goal:', error);
            return null;
        }
        return data;
    }

    // 日報を保存
    static async saveDailyReport(reportData) {
        const { data, error } = await supabaseClient
            .from('daily_reports')
            .upsert(reportData, { onConflict: 'user_id,report_date' })
            .select();

        if (error) {
            console.error('Error saving daily report:', error);
            throw error;
        }
        return data;
    }

    // 日報を取得
    static async getDailyReport(userId, date) {
        const { data, error } = await supabase
            .from('daily_reports')
            .select('*')
            .eq('user_id', userId)
            .eq('report_date', date)
            .single();

        if (error && error.code !== 'PGRST116') { // PGRST116 = not found
            console.error('Error fetching daily report:', error);
            return null;
        }
        return data;
    }

    // 月次実績を取得
    static async getMonthlyReports(userId, year, month) {
        const startDate = `${year}-${String(month).padStart(2, '0')}-01`;
        const endDate = new Date(year, month, 0);
        const endDateStr = `${year}-${String(month).padStart(2, '0')}-${endDate.getDate()}`;

        const { data, error } = await supabase
            .from('daily_reports')
            .select('*')
            .eq('user_id', userId)
            .gte('report_date', startDate)
            .lte('report_date', endDateStr)
            .order('report_date', { ascending: true });

        if (error) {
            console.error('Error fetching monthly reports:', error);
            return [];
        }
        return data;
    }

    // チーム全体の月次実績を取得
    static async getTeamMonthlyReports(year, month) {
        const startDate = `${year}-${String(month).padStart(2, '0')}-01`;
        const endDate = new Date(year, month, 0);
        const endDateStr = `${year}-${String(month).padStart(2, '0')}-${endDate.getDate()}`;

        const { data, error } = await supabaseClient
            .from('daily_reports')
            .select('*')
            .gte('report_date', startDate)
            .lte('report_date', endDateStr)
            .order('report_date', { ascending: true });

        if (error) {
            console.error('Error fetching team monthly reports:', error);
            return [];
        }
        return data;
    }
}
