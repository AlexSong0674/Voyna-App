-- ════════════════════════════════════════════════════════════════════
-- Voyna DB Reset — 기존 객체 모두 삭제 후 깨끗하게 시작
-- 실행 방법: SQL Editor에 이 파일 전체 복사 → Run
-- ⚠️ 이미 데이터가 있다면 모두 삭제됨 (개발 초기 단계라 OK)
-- ════════════════════════════════════════════════════════════════════

-- 트리거 먼저 제거 (테이블 의존)
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP TRIGGER IF EXISTS users_updated_at ON public.users;

-- 뷰
DROP VIEW IF EXISTS public.leaderboard CASCADE;

-- 함수
DROP FUNCTION IF EXISTS public.handle_new_user() CASCADE;
DROP FUNCTION IF EXISTS public.touch_updated_at() CASCADE;
DROP FUNCTION IF EXISTS public.get_locations_within_radius(DOUBLE PRECISION, DOUBLE PRECISION, DOUBLE PRECISION) CASCADE;
DROP FUNCTION IF EXISTS public.badge_acquisition_rate(BIGINT) CASCADE;
DROP FUNCTION IF EXISTS public.count_category_badges(UUID, TEXT) CASCADE;
DROP FUNCTION IF EXISTS public.recommend_badges(UUID, DOUBLE PRECISION, DOUBLE PRECISION, INT) CASCADE;

-- 테이블 (CASCADE로 외래키도 함께)
DROP TABLE IF EXISTS public.user_badges CASCADE;
DROP TABLE IF EXISTS public.xp_log CASCADE;
DROP TABLE IF EXISTS public.subscriptions CASCADE;
DROP TABLE IF EXISTS public.events CASCADE;
DROP TABLE IF EXISTS public.seasons CASCADE;
DROP TABLE IF EXISTS public.badges CASCADE;
DROP TABLE IF EXISTS public.locations CASCADE;
DROP TABLE IF EXISTS public.users CASCADE;

-- ENUM
DROP TYPE IF EXISTS public.badge_grade CASCADE;
DROP TYPE IF EXISTS public.xp_reason CASCADE;
DROP TYPE IF EXISTS public.subscription_plan CASCADE;
DROP TYPE IF EXISTS public.subscription_status CASCADE;

-- ✅ Reset 완료. 이제 0001_initial_schema.sql을 실행하세요.
SELECT 'Reset complete. Run 0001_initial_schema.sql next.' AS status;
