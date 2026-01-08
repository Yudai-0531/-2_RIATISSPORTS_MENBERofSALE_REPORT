# ONE TEAM - データベース設計

## Supabase接続情報

- **Project URL**: `https://ujoyyhhgvdlfvmlnnpwz.supabase.co`
- **Anon Key**: 環境変数で管理

---

## テーブル設計

### 1. `users` - ユーザー情報
```sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id VARCHAR(50) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'sales_rep', -- 'sales_rep' or 'admin'
    name VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index
CREATE INDEX idx_users_user_id ON users(user_id);
CREATE INDEX idx_users_role ON users(role);
```

### 2. `team_goals` - チーム月次目標
```sql
CREATE TABLE team_goals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    year INTEGER NOT NULL,
    month INTEGER NOT NULL,
    revenue_target DECIMAL(15, 2) NOT NULL, -- 当月チーム売上目標
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(year, month)
);

-- Index
CREATE INDEX idx_team_goals_year_month ON team_goals(year, month);
```

### 3. `individual_goals` - 個人月次目標
```sql
CREATE TABLE individual_goals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    year INTEGER NOT NULL,
    month INTEGER NOT NULL,
    revenue_target DECIMAL(15, 2) NOT NULL, -- 個人売上目標
    
    -- KPI目標（日次）
    daily_offer_target INTEGER DEFAULT 0,
    daily_negotiation_target INTEGER DEFAULT 0,
    daily_closing_target INTEGER DEFAULT 0,
    daily_riatis_view_target INTEGER DEFAULT 0,
    daily_crm_time_target INTEGER DEFAULT 0, -- 分単位
    
    -- KPI目標（月次）
    monthly_offer_target INTEGER DEFAULT 0,
    monthly_negotiation_target INTEGER DEFAULT 0,
    monthly_closing_target INTEGER DEFAULT 0,
    monthly_riatis_view_target INTEGER DEFAULT 0,
    monthly_crm_time_target INTEGER DEFAULT 0, -- 分単位
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, year, month)
);

-- Index
CREATE INDEX idx_individual_goals_user_year_month ON individual_goals(user_id, year, month);
```

### 4. `daily_reports` - 日報
```sql
CREATE TABLE daily_reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    report_date DATE NOT NULL,
    
    -- KPI実績
    offer_count INTEGER DEFAULT 0,
    negotiation_count INTEGER DEFAULT 0,
    closing_count INTEGER DEFAULT 0,
    riatis_view_count INTEGER DEFAULT 0,
    crm_time INTEGER DEFAULT 0, -- 分単位
    
    -- 売上金額（直接入力）
    revenue_amount DECIMAL(15, 2) DEFAULT 0,
    
    -- 明日のアクション
    next_action TEXT,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, report_date)
);

-- Index
CREATE INDEX idx_daily_reports_user_date ON daily_reports(user_id, report_date);
CREATE INDEX idx_daily_reports_date ON daily_reports(report_date);
```

### 5. `quotes` - モチベーション名言マスタ
```sql
CREATE TABLE quotes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    day_of_year INTEGER UNIQUE NOT NULL, -- 1-365
    author VARCHAR(100),
    content_en TEXT NOT NULL,
    content_jp TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index
CREATE INDEX idx_quotes_day_of_year ON quotes(day_of_year);
```

---

## Row Level Security (RLS) ポリシー

### `users` テーブル
```sql
-- 自分の情報のみ閲覧可能
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own data"
    ON users FOR SELECT
    USING (auth.uid() = id);
```

### `daily_reports` テーブル
```sql
-- 自分の日報のみ作成・閲覧・更新可能
ALTER TABLE daily_reports ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own reports"
    ON daily_reports FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own reports"
    ON daily_reports FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own reports"
    ON daily_reports FOR UPDATE
    USING (auth.uid() = user_id);
```

### `quotes` テーブル
```sql
-- 全員が閲覧可能
ALTER TABLE quotes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view quotes"
    ON quotes FOR SELECT
    TO authenticated
    USING (true);
```

---

## 初期データ例

### 管理者ユーザー作成
```sql
INSERT INTO users (user_id, password_hash, role, name)
VALUES ('admin', 'HASHED_PASSWORD_HERE', 'admin', '管理者');
```

### サンプル名言データ
```sql
INSERT INTO quotes (day_of_year, author, content_en, content_jp) VALUES
(1, 'Vince Lombardi', 'Winners never quit and quitters never win.', '勝者は決して諦めない。諦める者は決して勝てない。'),
(2, 'Michael Jordan', 'I can accept failure, everyone fails at something. But I can''t accept not trying.', '失敗は受け入れられる。誰もが何かに失敗する。しかし、挑戦しないことは受け入れられない。');
```

---

## 次のステップ

1. Supabase管理画面でSQLを実行
2. テーブル作成確認
3. 初期データ投入
4. フロントエンド接続テスト
