-- ════════════════════════════════════════════════════════════════════
-- Voyna 초기 스키마 (v2.0)
-- 실행 방법: Supabase Studio → SQL Editor → 이 파일 전체 붙여넣기 → Run
-- ════════════════════════════════════════════════════════════════════

-- 공간 검색 확장 (반경 내 명소 조회용)
CREATE EXTENSION IF NOT EXISTS cube;
CREATE EXTENSION IF NOT EXISTS earthdistance;

-- ── ENUM 타입 ──
DO $$ BEGIN
    CREATE TYPE badge_grade AS ENUM ('common', 'rare', 'special', 'premier', 'seasonal');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    CREATE TYPE xp_reason AS ENUM (
        'badge_obtained', 'mission_completed', 'streak_bonus',
        'friend_companion_bonus', 'admin_adjust'
    );
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    CREATE TYPE subscription_plan AS ENUM ('free', 'plus_monthly', 'plus_yearly');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    CREATE TYPE subscription_status AS ENUM ('active', 'cancelled', 'expired');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- ════════════════════════════════════════════════════════════════════
-- 1. users
-- ════════════════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS public.users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    nickname TEXT UNIQUE NOT NULL,
    level INTEGER NOT NULL DEFAULT 1,
    xp INTEGER NOT NULL DEFAULT 0,
    title TEXT,
    photo_url TEXT,
    locale TEXT DEFAULT 'ko',
    fcm_token TEXT,
    is_beta_user BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT nickname_length CHECK (char_length(nickname) BETWEEN 2 AND 20),
    CONSTRAINT level_range CHECK (level BETWEEN 1 AND 99),
    CONSTRAINT xp_non_negative CHECK (xp >= 0)
);

CREATE INDEX IF NOT EXISTS idx_users_level ON public.users(level DESC);
CREATE INDEX IF NOT EXISTS idx_users_nickname ON public.users(nickname);

-- ════════════════════════════════════════════════════════════════════
-- 2. locations
-- ════════════════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS public.locations (
    id BIGSERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    name_en TEXT,
    description TEXT,
    lat DOUBLE PRECISION NOT NULL,
    lng DOUBLE PRECISION NOT NULL,
    radius_m INTEGER NOT NULL DEFAULT 100,
    category TEXT NOT NULL,
    region TEXT NOT NULL,
    district TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT lat_range CHECK (lat BETWEEN -90 AND 90),
    CONSTRAINT lng_range CHECK (lng BETWEEN -180 AND 180),
    CONSTRAINT radius_positive CHECK (radius_m BETWEEN 30 AND 500)
);

CREATE INDEX IF NOT EXISTS idx_locations_region ON public.locations(region);
CREATE INDEX IF NOT EXISTS idx_locations_category ON public.locations(category);
CREATE INDEX IF NOT EXISTS idx_locations_earth ON public.locations
    USING gist (ll_to_earth(lat, lng));

-- ════════════════════════════════════════════════════════════════════
-- 3. badges
-- ════════════════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS public.badges (
    id BIGSERIAL PRIMARY KEY,
    location_id BIGINT REFERENCES public.locations(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    grade badge_grade NOT NULL,
    xp_reward INTEGER NOT NULL,
    requires_confirmation BOOLEAN NOT NULL DEFAULT FALSE,
    is_premium BOOLEAN DEFAULT FALSE,
    image_url TEXT,
    icon TEXT,
    season_id BIGINT,
    color_hex TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT xp_positive CHECK (xp_reward > 0)
);

CREATE INDEX IF NOT EXISTS idx_badges_location ON public.badges(location_id);
CREATE INDEX IF NOT EXISTS idx_badges_grade ON public.badges(grade);

-- ════════════════════════════════════════════════════════════════════
-- 4. user_badges
-- ════════════════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS public.user_badges (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    badge_id BIGINT NOT NULL REFERENCES public.badges(id),
    obtained_at TIMESTAMPTZ DEFAULT NOW(),
    lat DOUBLE PRECISION NOT NULL,
    lng DOUBLE PRECISION NOT NULL,
    photo_url TEXT,
    UNIQUE (user_id, badge_id)
);

CREATE INDEX IF NOT EXISTS idx_user_badges_user ON public.user_badges(user_id, obtained_at DESC);
CREATE INDEX IF NOT EXISTS idx_user_badges_badge ON public.user_badges(badge_id);

-- ════════════════════════════════════════════════════════════════════
-- 5. xp_log
-- ════════════════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS public.xp_log (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    amount INTEGER NOT NULL,
    reason xp_reason NOT NULL,
    ref_badge_id BIGINT REFERENCES public.badges(id),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_xp_log_user ON public.xp_log(user_id, created_at DESC);

-- ════════════════════════════════════════════════════════════════════
-- 6. subscriptions
-- ════════════════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS public.subscriptions (
    user_id UUID PRIMARY KEY REFERENCES public.users(id) ON DELETE CASCADE,
    plan subscription_plan NOT NULL DEFAULT 'free',
    status subscription_status NOT NULL DEFAULT 'active',
    started_at TIMESTAMPTZ,
    expires_at TIMESTAMPTZ,
    apple_transaction_id TEXT,
    google_purchase_token TEXT,
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ════════════════════════════════════════════════════════════════════
-- 7. seasons, events (V1.1+ 미리 준비)
-- ════════════════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS public.seasons (
    id BIGSERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    theme TEXT,
    start_at TIMESTAMPTZ NOT NULL,
    end_at TIMESTAMPTZ NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    CONSTRAINT season_dates CHECK (end_at > start_at)
);

CREATE TABLE IF NOT EXISTS public.events (
    id BIGSERIAL PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT,
    start_at TIMESTAMPTZ NOT NULL,
    end_at TIMESTAMPTZ NOT NULL,
    banner_url TEXT,
    is_active BOOLEAN DEFAULT TRUE
);

-- ════════════════════════════════════════════════════════════════════
-- 8. 트리거: 가입 시 public.users 자동 생성
-- ════════════════════════════════════════════════════════════════════
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    default_nickname TEXT;
BEGIN
    default_nickname := COALESCE(
        NEW.raw_user_meta_data->>'nickname',
        NEW.raw_user_meta_data->>'name',
        'Voyager_' || substr(NEW.id::text, 1, 8)
    );
    -- 중복 닉네임이면 suffix 추가
    WHILE EXISTS (SELECT 1 FROM public.users WHERE nickname = default_nickname) LOOP
        default_nickname := default_nickname || '_' || floor(random() * 1000)::text;
    END LOOP;

    INSERT INTO public.users (id, nickname, level, xp)
    VALUES (NEW.id, default_nickname, 1, 0)
    ON CONFLICT (id) DO NOTHING;

    INSERT INTO public.subscriptions (user_id, plan, status)
    VALUES (NEW.id, 'free', 'active')
    ON CONFLICT (user_id) DO NOTHING;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_user();

-- updated_at 자동 갱신
CREATE OR REPLACE FUNCTION public.touch_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS users_updated_at ON public.users;
CREATE TRIGGER users_updated_at BEFORE UPDATE ON public.users
    FOR EACH ROW EXECUTE FUNCTION public.touch_updated_at();

-- ════════════════════════════════════════════════════════════════════
-- 9. RLS (Row Level Security) 정책
-- ════════════════════════════════════════════════════════════════════
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_badges ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.xp_log ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subscriptions ENABLE ROW LEVEL SECURITY;

-- users: 모두 SELECT 가능 (랭킹용), 본인만 UPDATE
DROP POLICY IF EXISTS "users_select_all" ON public.users;
CREATE POLICY "users_select_all" ON public.users FOR SELECT USING (true);
DROP POLICY IF EXISTS "users_update_self" ON public.users;
CREATE POLICY "users_update_self" ON public.users
    FOR UPDATE USING (auth.uid() = id);

-- user_badges: 본인 것만 SELECT (랭킹 카운트는 RPC 우회)
DROP POLICY IF EXISTS "user_badges_select_self" ON public.user_badges;
CREATE POLICY "user_badges_select_self" ON public.user_badges
    FOR SELECT USING (auth.uid() = user_id);
-- INSERT는 Edge Function service_role으로만 (어뷰징 방지)

-- xp_log: 본인 것만
DROP POLICY IF EXISTS "xp_log_select_self" ON public.xp_log;
CREATE POLICY "xp_log_select_self" ON public.xp_log
    FOR SELECT USING (auth.uid() = user_id);

-- subscriptions: 본인 것만
DROP POLICY IF EXISTS "subscriptions_select_self" ON public.subscriptions;
CREATE POLICY "subscriptions_select_self" ON public.subscriptions
    FOR SELECT USING (auth.uid() = user_id);

-- 공개 테이블 (locations, badges, events, seasons)
GRANT SELECT ON public.locations TO anon, authenticated;
GRANT SELECT ON public.badges TO anon, authenticated;
GRANT SELECT ON public.events TO anon, authenticated;
GRANT SELECT ON public.seasons TO anon, authenticated;

-- ════════════════════════════════════════════════════════════════════
-- 10. RPC 함수
-- ════════════════════════════════════════════════════════════════════

-- 반경 내 명소 조회
CREATE OR REPLACE FUNCTION public.get_locations_within_radius(
    p_lat DOUBLE PRECISION,
    p_lng DOUBLE PRECISION,
    p_radius_m DOUBLE PRECISION
)
RETURNS SETOF public.locations
LANGUAGE sql
SECURITY DEFINER
AS $$
    SELECT *
    FROM public.locations
    WHERE earth_box(ll_to_earth(p_lat, p_lng), p_radius_m) @> ll_to_earth(lat, lng)
      AND earth_distance(ll_to_earth(p_lat, p_lng), ll_to_earth(lat, lng)) <= p_radius_m
      AND is_active = TRUE
    ORDER BY earth_distance(ll_to_earth(p_lat, p_lng), ll_to_earth(lat, lng));
$$;

-- 배지 획득자 비율
CREATE OR REPLACE FUNCTION public.badge_acquisition_rate(p_badge_id BIGINT)
RETURNS NUMERIC
LANGUAGE sql
SECURITY DEFINER
AS $$
    SELECT
        CASE WHEN total = 0 THEN 0
        ELSE ROUND(100.0 * obtained / total, 1) END
    FROM (
        SELECT
            (SELECT COUNT(*) FROM public.users) as total,
            (SELECT COUNT(*) FROM public.user_badges WHERE badge_id = p_badge_id) as obtained
    ) sub;
$$;

-- 카테고리별 배지 카운트 (칭호 체크용)
CREATE OR REPLACE FUNCTION public.count_category_badges(p_user_id UUID, p_category TEXT)
RETURNS INTEGER
LANGUAGE sql
SECURITY DEFINER
AS $$
    SELECT COUNT(*)::INTEGER
    FROM public.user_badges ub
    JOIN public.badges b ON b.id = ub.badge_id
    JOIN public.locations l ON l.id = b.location_id
    WHERE ub.user_id = p_user_id AND l.category = p_category;
$$;

-- 미수집 배지 추천 (단순 거리순)
CREATE OR REPLACE FUNCTION public.recommend_badges(
    p_user_id UUID,
    p_lat DOUBLE PRECISION,
    p_lng DOUBLE PRECISION,
    p_limit INT DEFAULT 3
)
RETURNS TABLE(badge_id BIGINT, location_name TEXT, distance_m INTEGER, grade badge_grade)
LANGUAGE sql
SECURITY DEFINER
AS $$
    SELECT b.id, l.name,
           earth_distance(ll_to_earth(p_lat, p_lng), ll_to_earth(l.lat, l.lng))::INT,
           b.grade
    FROM public.badges b
    JOIN public.locations l ON l.id = b.location_id
    WHERE NOT EXISTS (
      SELECT 1 FROM public.user_badges ub
      WHERE ub.user_id = p_user_id AND ub.badge_id = b.id
    ) AND l.is_active
    ORDER BY earth_distance(ll_to_earth(p_lat, p_lng), ll_to_earth(l.lat, l.lng))
    LIMIT p_limit;
$$;

-- 리더보드 뷰
CREATE OR REPLACE VIEW public.leaderboard AS
SELECT u.id, u.nickname, u.level, u.title, u.xp,
       (SELECT COUNT(*) FROM public.user_badges ub WHERE ub.user_id = u.id) AS badge_count
FROM public.users u
ORDER BY u.level DESC,
         (SELECT COUNT(*) FROM public.user_badges ub WHERE ub.user_id = u.id) DESC,
         u.xp DESC;

GRANT SELECT ON public.leaderboard TO anon, authenticated;

-- ════════════════════════════════════════════════════════════════════
-- ✅ 스키마 적용 완료
-- 다음 단계: 0002_seed_data.sql 실행 (30곳 명소 + 30 배지)
-- ════════════════════════════════════════════════════════════════════
