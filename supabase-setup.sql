-- ONE TEAM - Supabase Database Setup Script
-- このSQLをSupabase SQL Editorで実行してください

-- 1. usersテーブル
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id VARCHAR(50) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'sales_rep',
    name VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_users_user_id ON users(user_id);
CREATE INDEX idx_users_role ON users(role);

-- 2. team_goalsテーブル
CREATE TABLE team_goals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    year INTEGER NOT NULL,
    month INTEGER NOT NULL,
    revenue_target DECIMAL(15, 2) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(year, month)
);

CREATE INDEX idx_team_goals_year_month ON team_goals(year, month);

-- 3. individual_goalsテーブル
CREATE TABLE individual_goals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    year INTEGER NOT NULL,
    month INTEGER NOT NULL,
    revenue_target DECIMAL(15, 2) NOT NULL,
    daily_offer_target INTEGER DEFAULT 0,
    daily_negotiation_target INTEGER DEFAULT 0,
    daily_closing_target INTEGER DEFAULT 0,
    daily_riatis_view_target INTEGER DEFAULT 0,
    daily_crm_time_target INTEGER DEFAULT 0,
    monthly_offer_target INTEGER DEFAULT 0,
    monthly_negotiation_target INTEGER DEFAULT 0,
    monthly_closing_target INTEGER DEFAULT 0,
    monthly_riatis_view_target INTEGER DEFAULT 0,
    monthly_crm_time_target INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, year, month)
);

CREATE INDEX idx_individual_goals_user_year_month ON individual_goals(user_id, year, month);

-- 4. daily_reportsテーブル
CREATE TABLE daily_reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    report_date DATE NOT NULL,
    offer_count INTEGER DEFAULT 0,
    negotiation_count INTEGER DEFAULT 0,
    closing_count INTEGER DEFAULT 0,
    riatis_view_count INTEGER DEFAULT 0,
    crm_time INTEGER DEFAULT 0,
    revenue_amount DECIMAL(15, 2) DEFAULT 0,
    next_action TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, report_date)
);

CREATE INDEX idx_daily_reports_user_date ON daily_reports(user_id, report_date);
CREATE INDEX idx_daily_reports_date ON daily_reports(report_date);

-- 5. quotesテーブル
CREATE TABLE quotes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    day_of_year INTEGER UNIQUE NOT NULL,
    author VARCHAR(100),
    content_en TEXT NOT NULL,
    content_jp TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_quotes_day_of_year ON quotes(day_of_year);

-- 初期データ: サンプル名言（10件）
INSERT INTO quotes (day_of_year, author, content_en, content_jp) VALUES
(1, 'Vince Lombardi', 'Winners never quit and quitters never win.', '勝者は決して諦めない。諦める者は決して勝てない。'),
(2, 'Michael Jordan', 'I can accept failure, everyone fails at something. But I can''t accept not trying.', '失敗は受け入れられる。しかし、挑戦しないことは受け入れられない。'),
(3, 'Muhammad Ali', 'Don''t count the days, make the days count.', '日数を数えるな、日々を価値あるものにしろ。'),
(4, 'Kobe Bryant', 'The moment you give up is the moment you let someone else win.', '諦めた瞬間が、誰かに勝利を譲る瞬間だ。'),
(5, 'Cristiano Ronaldo', 'Talent without working hard is nothing.', '努力なき才能は無に等しい。'),
(6, 'Usain Bolt', 'Worrying gets you nowhere. If you turn up worrying about how you''re going to perform, you''ve already lost.', '心配しても何も得られない。不安を抱えたまま挑めば、既に負けている。'),
(7, 'Serena Williams', 'I really think a champion is defined not by their wins but by how they can recover when they fall.', '真のチャンピオンは勝利ではなく、転んだ時の立ち直り方で決まる。'),
(8, 'Tom Brady', 'You never get over losses. You never get over championships, either.', '敗北は忘れられない。勝利もまた同じだ。'),
(9, 'LeBron James', 'Don''t be afraid of failure. This is the way to succeed.', '失敗を恐れるな。それが成功への道だ。'),
(10, 'Tiger Woods', 'The greatest thing about tomorrow is, I will be better than I am today.', '明日の素晴らしさは、今日より成長できることだ。');

-- 管理者ユーザー作成（パスワード: admin123）
-- 注意: 本番環境では必ず強力なパスワードに変更してください
INSERT INTO users (user_id, password_hash, role, name) VALUES
('admin', '$2a$10$example_hash_replace_this', 'admin', 'システム管理者');

-- サンプルユーザー作成（パスワード: user123）
INSERT INTO users (user_id, password_hash, role, name) VALUES
('user001', '$2a$10$example_hash_replace_this', 'sales_rep', '営業太郎');

COMMIT;
