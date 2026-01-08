-- ONE TEAM - テストデータ投入（修正版）
-- 既存データがある場合はスキップします

-- テスト用ユーザー（重複を避けるため ON CONFLICT を使用）
INSERT INTO users (user_id, password_hash, role, name) VALUES
('admin', 'admin123', 'admin', 'システム管理者')
ON CONFLICT (user_id) DO NOTHING;

INSERT INTO users (user_id, password_hash, role, name) VALUES
('user001', 'user123', 'sales_rep', '営業太郎')
ON CONFLICT (user_id) DO NOTHING;

INSERT INTO users (user_id, password_hash, role, name) VALUES
('user002', 'user123', 'sales_rep', '営業花子')
ON CONFLICT (user_id) DO NOTHING;

INSERT INTO users (user_id, password_hash, role, name) VALUES
('user003', 'user123', 'sales_rep', '営業次郎')
ON CONFLICT (user_id) DO NOTHING;

-- 2026年1月のチーム目標
INSERT INTO team_goals (year, month, revenue_target) VALUES
(2026, 1, 10000000)
ON CONFLICT (year, month) DO UPDATE SET revenue_target = 10000000;

-- 2026年1月の個人目標
-- 営業太郎
INSERT INTO individual_goals (
    user_id, 
    year, 
    month, 
    revenue_target,
    daily_offer_target,
    daily_negotiation_target,
    daily_closing_target,
    daily_riatis_view_target,
    daily_crm_time_target,
    monthly_offer_target,
    monthly_negotiation_target,
    monthly_closing_target,
    monthly_riatis_view_target,
    monthly_crm_time_target
) VALUES (
    (SELECT id FROM users WHERE user_id = 'user001'),
    2026,
    1,
    3000000,
    5, 3, 1, 5, 60,
    150, 90, 30, 150, 1800
)
ON CONFLICT (user_id, year, month) DO UPDATE SET
    revenue_target = 3000000,
    daily_offer_target = 5,
    daily_negotiation_target = 3,
    daily_closing_target = 1,
    daily_riatis_view_target = 5,
    daily_crm_time_target = 60,
    monthly_offer_target = 150,
    monthly_negotiation_target = 90,
    monthly_closing_target = 30,
    monthly_riatis_view_target = 150,
    monthly_crm_time_target = 1800;

-- 営業花子
INSERT INTO individual_goals (
    user_id, 
    year, 
    month, 
    revenue_target,
    daily_offer_target,
    daily_negotiation_target,
    daily_closing_target,
    daily_riatis_view_target,
    daily_crm_time_target,
    monthly_offer_target,
    monthly_negotiation_target,
    monthly_closing_target,
    monthly_riatis_view_target,
    monthly_crm_time_target
) VALUES (
    (SELECT id FROM users WHERE user_id = 'user002'),
    2026,
    1,
    3500000,
    6, 4, 1, 6, 60,
    180, 120, 35, 180, 1800
)
ON CONFLICT (user_id, year, month) DO UPDATE SET
    revenue_target = 3500000,
    daily_offer_target = 6,
    daily_negotiation_target = 4,
    daily_closing_target = 1,
    daily_riatis_view_target = 6,
    daily_crm_time_target = 60,
    monthly_offer_target = 180,
    monthly_negotiation_target = 120,
    monthly_closing_target = 35,
    monthly_riatis_view_target = 180,
    monthly_crm_time_target = 1800;

-- 営業次郎
INSERT INTO individual_goals (
    user_id, 
    year, 
    month, 
    revenue_target,
    daily_offer_target,
    daily_negotiation_target,
    daily_closing_target,
    daily_riatis_view_target,
    daily_crm_time_target,
    monthly_offer_target,
    monthly_negotiation_target,
    monthly_closing_target,
    monthly_riatis_view_target,
    monthly_crm_time_target
) VALUES (
    (SELECT id FROM users WHERE user_id = 'user003'),
    2026,
    1,
    3500000,
    6, 4, 1, 6, 60,
    180, 120, 35, 180, 1800
)
ON CONFLICT (user_id, year, month) DO UPDATE SET
    revenue_target = 3500000,
    daily_offer_target = 6,
    daily_negotiation_target = 4,
    daily_closing_target = 1,
    daily_riatis_view_target = 6,
    daily_crm_time_target = 60,
    monthly_offer_target = 180,
    monthly_negotiation_target = 120,
    monthly_closing_target = 35,
    monthly_riatis_view_target = 180,
    monthly_crm_time_target = 1800;

-- サンプル日報データ（1月1日〜1月7日）
-- 営業太郎の日報
INSERT INTO daily_reports (user_id, report_date, offer_count, negotiation_count, closing_count, riatis_view_count, crm_time, revenue_amount, next_action) VALUES
((SELECT id FROM users WHERE user_id = 'user001'), '2026-01-01', 6, 3, 1, 5, 65, 150000, '大口顧客Aへのフォローアップ')
ON CONFLICT (user_id, report_date) DO NOTHING;

INSERT INTO daily_reports (user_id, report_date, offer_count, negotiation_count, closing_count, riatis_view_count, crm_time, revenue_amount, next_action) VALUES
((SELECT id FROM users WHERE user_id = 'user001'), '2026-01-02', 5, 4, 1, 6, 70, 120000, '新規リスト20件へのアプローチ')
ON CONFLICT (user_id, report_date) DO NOTHING;

INSERT INTO daily_reports (user_id, report_date, offer_count, negotiation_count, closing_count, riatis_view_count, crm_time, revenue_amount, next_action) VALUES
((SELECT id FROM users WHERE user_id = 'user001'), '2026-01-03', 7, 2, 0, 4, 55, 0, '見積書作成と提案準備')
ON CONFLICT (user_id, report_date) DO NOTHING;

INSERT INTO daily_reports (user_id, report_date, offer_count, negotiation_count, closing_count, riatis_view_count, crm_time, revenue_amount, next_action) VALUES
((SELECT id FROM users WHERE user_id = 'user001'), '2026-01-04', 4, 3, 2, 5, 60, 280000, '週末のクロージング準備')
ON CONFLICT (user_id, report_date) DO NOTHING;

INSERT INTO daily_reports (user_id, report_date, offer_count, negotiation_count, closing_count, riatis_view_count, crm_time, revenue_amount, next_action) VALUES
((SELECT id FROM users WHERE user_id = 'user001'), '2026-01-05', 5, 3, 1, 6, 65, 150000, 'B社との最終商談')
ON CONFLICT (user_id, report_date) DO NOTHING;

INSERT INTO daily_reports (user_id, report_date, offer_count, negotiation_count, closing_count, riatis_view_count, crm_time, revenue_amount, next_action) VALUES
((SELECT id FROM users WHERE user_id = 'user001'), '2026-01-06', 8, 5, 2, 7, 80, 350000, '来週のアポ設定')
ON CONFLICT (user_id, report_date) DO NOTHING;

INSERT INTO daily_reports (user_id, report_date, offer_count, negotiation_count, closing_count, riatis_view_count, crm_time, revenue_amount, next_action) VALUES
((SELECT id FROM users WHERE user_id = 'user001'), '2026-01-07', 6, 4, 1, 5, 70, 180000, '月次レポート作成')
ON CONFLICT (user_id, report_date) DO NOTHING;

-- 営業花子の日報
INSERT INTO daily_reports (user_id, report_date, offer_count, negotiation_count, closing_count, riatis_view_count, crm_time, revenue_amount, next_action) VALUES
((SELECT id FROM users WHERE user_id = 'user002'), '2026-01-01', 7, 4, 1, 6, 70, 200000, 'C社への提案書準備')
ON CONFLICT (user_id, report_date) DO NOTHING;

INSERT INTO daily_reports (user_id, report_date, offer_count, negotiation_count, closing_count, riatis_view_count, crm_time, revenue_amount, next_action) VALUES
((SELECT id FROM users WHERE user_id = 'user002'), '2026-01-02', 6, 5, 2, 7, 75, 320000, '新規開拓エリア調査')
ON CONFLICT (user_id, report_date) DO NOTHING;

INSERT INTO daily_reports (user_id, report_date, offer_count, negotiation_count, closing_count, riatis_view_count, crm_time, revenue_amount, next_action) VALUES
((SELECT id FROM users WHERE user_id = 'user002'), '2026-01-03', 8, 3, 1, 5, 60, 150000, 'フォローアップメール送信')
ON CONFLICT (user_id, report_date) DO NOTHING;

INSERT INTO daily_reports (user_id, report_date, offer_count, negotiation_count, closing_count, riatis_view_count, crm_time, revenue_amount, next_action) VALUES
((SELECT id FROM users WHERE user_id = 'user002'), '2026-01-04', 5, 4, 1, 6, 65, 180000, 'D社訪問準備')
ON CONFLICT (user_id, report_date) DO NOTHING;

INSERT INTO daily_reports (user_id, report_date, offer_count, negotiation_count, closing_count, riatis_view_count, crm_time, revenue_amount, next_action) VALUES
((SELECT id FROM users WHERE user_id = 'user002'), '2026-01-05', 7, 5, 2, 8, 85, 380000, '週次MTG資料作成')
ON CONFLICT (user_id, report_date) DO NOTHING;

INSERT INTO daily_reports (user_id, report_date, offer_count, negotiation_count, closing_count, riatis_view_count, crm_time, revenue_amount, next_action) VALUES
((SELECT id FROM users WHERE user_id = 'user002'), '2026-01-06', 9, 6, 3, 7, 90, 450000, '大型案件クロージング')
ON CONFLICT (user_id, report_date) DO NOTHING;

INSERT INTO daily_reports (user_id, report_date, offer_count, negotiation_count, closing_count, riatis_view_count, crm_time, revenue_amount, next_action) VALUES
((SELECT id FROM users WHERE user_id = 'user002'), '2026-01-07', 6, 4, 1, 6, 70, 200000, '来週のスケジュール調整')
ON CONFLICT (user_id, report_date) DO NOTHING;

-- 追加の名言データ（11日〜30日分）
INSERT INTO quotes (day_of_year, author, content_en, content_jp) VALUES
(11, 'Michael Phelps', 'You can''t put a limit on anything. The more you dream, the farther you get.', '何事にも限界を設けるな。夢を見れば見るほど、遠くへ行ける。')
ON CONFLICT (day_of_year) DO NOTHING;

INSERT INTO quotes (day_of_year, author, content_en, content_jp) VALUES
(12, 'Lionel Messi', 'You have to fight to reach your dream. You have to sacrifice and work hard for it.', '夢を掴むには戦わなければならない。犠牲を払い、懸命に働く必要がある。')
ON CONFLICT (day_of_year) DO NOTHING;

INSERT INTO quotes (day_of_year, author, content_en, content_jp) VALUES
(13, 'Wayne Gretzky', 'You miss 100% of the shots you don''t take.', '打たなかったシュートは100%外れる。')
ON CONFLICT (day_of_year) DO NOTHING;

INSERT INTO quotes (day_of_year, author, content_en, content_jp) VALUES
(14, 'Derek Jeter', 'There may be people that have more talent than you, but there''s no excuse for anyone to work harder than you do.', 'あなたより才能がある人はいるかもしれない。しかし、あなたより努力する言い訳は誰にもない。')
ON CONFLICT (day_of_year) DO NOTHING;

INSERT INTO quotes (day_of_year, author, content_en, content_jp) VALUES
(15, 'Pelé', 'Success is no accident. It is hard work, perseverance, learning, studying, sacrifice and most of all, love of what you are doing.', '成功は偶然ではない。努力、忍耐、学習、犠牲、そして何より愛が必要だ。')
ON CONFLICT (day_of_year) DO NOTHING;

INSERT INTO quotes (day_of_year, author, content_en, content_jp) VALUES
(16, 'Roger Federer', 'I fear no one, but respect everyone.', '誰も恐れないが、全員を尊重する。')
ON CONFLICT (day_of_year) DO NOTHING;

INSERT INTO quotes (day_of_year, author, content_en, content_jp) VALUES
(17, 'Simone Biles', 'I''d rather regret the risks that didn''t work out than the chances I didn''t take at all.', 'うまくいかなかったリスクを後悔する方が、挑戦しなかったことを後悔するよりマシだ。')
ON CONFLICT (day_of_year) DO NOTHING;

INSERT INTO quotes (day_of_year, author, content_en, content_jp) VALUES
(18, 'David Beckham', 'I always wanted to be the best I could be at whatever I did.', '何をするにも、できる限り最高の自分でありたいと思っていた。')
ON CONFLICT (day_of_year) DO NOTHING;

INSERT INTO quotes (day_of_year, author, content_en, content_jp) VALUES
(19, 'Rafael Nadal', 'You fight, you try your best, but if you lose, you don''t have to break five racquets and smash up the locker room.', '戦い、ベストを尽くせ。負けてもラケットを壊す必要はない。')
ON CONFLICT (day_of_year) DO NOTHING;

INSERT INTO quotes (day_of_year, author, content_en, content_jp) VALUES
(20, 'Floyd Mayweather', 'I don''t fold under pressure, great athletes perform better under pressure.', 'プレッシャーに屈しない。偉大なアスリートはプレッシャー下でより良いパフォーマンスを発揮する。')
ON CONFLICT (day_of_year) DO NOTHING;

INSERT INTO quotes (day_of_year, author, content_en, content_jp) VALUES
(21, 'Neymar Jr.', 'I think that the best thing that I can do is just keep my head down and keep working.', '最善の方法は、頭を下げて働き続けることだと思う。')
ON CONFLICT (day_of_year) DO NOTHING;

INSERT INTO quotes (day_of_year, author, content_en, content_jp) VALUES
(22, 'Naomi Osaka', 'If I''m playing someone higher ranked than me, I try to think more positively.', '自分よりランクが上の相手と対戦するときは、よりポジティブに考えるようにしている。')
ON CONFLICT (day_of_year) DO NOTHING;

INSERT INTO quotes (day_of_year, author, content_en, content_jp) VALUES
(23, 'Novak Djokovic', 'I had to have some balls to be Irish Catholic in South London.', '困難な状況でも勇気を持つことが大切だ。')
ON CONFLICT (day_of_year) DO NOTHING;

INSERT INTO quotes (day_of_year, author, content_en, content_jp) VALUES
(24, 'Shaquille O''Neal', 'Excellence is not a singular act but a habit. You are what you do repeatedly.', '卓越性は一度の行為ではなく習慣だ。あなたは繰り返し行うことそのものだ。')
ON CONFLICT (day_of_year) DO NOTHING;

INSERT INTO quotes (day_of_year, author, content_en, content_jp) VALUES
(25, 'Magic Johnson', 'All kids need is a little help, a little hope and somebody who believes in them.', '子供たちに必要なのは、少しの助けと希望、そして信じてくれる誰かだ。')
ON CONFLICT (day_of_year) DO NOTHING;

INSERT INTO quotes (day_of_year, author, content_en, content_jp) VALUES
(26, 'Larry Bird', 'Leadership is getting players to believe in you. If you tell a teammate you''re ready to play as tough as you''re able to, you''d better go out there and do it.', 'リーダーシップとは、選手にあなたを信じさせることだ。')
ON CONFLICT (day_of_year) DO NOTHING;

INSERT INTO quotes (day_of_year, author, content_en, content_jp) VALUES
(27, 'Stephen Curry', 'Success is not an accident, success is a choice.', '成功は偶然ではない。成功は選択だ。')
ON CONFLICT (day_of_year) DO NOTHING;

INSERT INTO quotes (day_of_year, author, content_en, content_jp) VALUES
(28, 'Kevin Durant', 'Hard work beats talent when talent fails to work hard.', '才能が努力を怠れば、努力が才能に勝つ。')
ON CONFLICT (day_of_year) DO NOTHING;

INSERT INTO quotes (day_of_year, author, content_en, content_jp) VALUES
(29, 'LeBron James', 'I like criticism. It makes you strong.', '批判は好きだ。それは人を強くする。')
ON CONFLICT (day_of_year) DO NOTHING;

INSERT INTO quotes (day_of_year, author, content_en, content_jp) VALUES
(30, 'Kobe Bryant', 'The most important thing is to try and inspire people so that they can be great in whatever they want to do.', '最も重要なことは、人々を鼓舞し、何をするにも偉大になれるよう促すことだ。')
ON CONFLICT (day_of_year) DO NOTHING;
