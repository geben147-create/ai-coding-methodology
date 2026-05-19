-- =============================================================================
-- TRUSTA · Auth System Migration
-- 실행: Supabase Dashboard → SQL Editor → 이 파일 내용 붙여넣기 → Run
-- =============================================================================

-- ---------------------------------------------------------------------------
-- 1. settings 테이블 (운영자가 조정하는 설정값 관리)
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.settings (
  key        TEXT        PRIMARY KEY,
  value      TEXT        NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 기본 trial_days = 3 (Supabase에서 수정 가능)
INSERT INTO public.settings (key, value)
VALUES ('trial_days', '3')
ON CONFLICT (key) DO NOTHING;

-- ---------------------------------------------------------------------------
-- 2. profiles 테이블 (auth.users 와 1:1 연결)
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.profiles (
  id               UUID        PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email            TEXT        NOT NULL,
  privacy_agreed   BOOLEAN     NOT NULL DEFAULT FALSE,
  marketing_agreed BOOLEAN     NOT NULL DEFAULT FALSE,
  plan             TEXT        NOT NULL DEFAULT 'free_trial'
                   CHECK (plan IN ('free_trial', 'standard', 'growth', 'admin')),
  trial_started_at TIMESTAMPTZ,
  trial_ends_at    TIMESTAMPTZ,
  trial_status     TEXT        NOT NULL DEFAULT 'active'
                   CHECK (trial_status IN ('active', 'expired', 'cancelled')),
  created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ---------------------------------------------------------------------------
-- 3. RLS 활성화
-- ---------------------------------------------------------------------------
ALTER TABLE public.settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- settings: 누구나 읽기 가능, admin 플랜만 쓰기 가능
DROP POLICY IF EXISTS "settings_read"         ON public.settings;
DROP POLICY IF EXISTS "settings_admin_write"  ON public.settings;

CREATE POLICY "settings_read" ON public.settings
  FOR SELECT USING (TRUE);

CREATE POLICY "settings_admin_write" ON public.settings
  FOR ALL TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE id = auth.uid() AND plan = 'admin'
    )
  );

-- profiles: 본인 행만 읽기/수정 가능
DROP POLICY IF EXISTS "profiles_select_own" ON public.profiles;
DROP POLICY IF EXISTS "profiles_update_own" ON public.profiles;

CREATE POLICY "profiles_select_own" ON public.profiles
  FOR SELECT TO authenticated
  USING (id = auth.uid());

CREATE POLICY "profiles_update_own" ON public.profiles
  FOR UPDATE TO authenticated
  USING (id = auth.uid())
  WITH CHECK (
    id = auth.uid()
    AND plan NOT IN ('admin')  -- 자기 승격 방지
  );

-- ---------------------------------------------------------------------------
-- 4. 트리거 함수: 신규 가입 시 profiles 자동 생성 + 무료체험 기간 계산
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_trial_days INT;
BEGIN
  -- settings 테이블에서 trial_days 읽기
  SELECT value::INT INTO v_trial_days
  FROM public.settings
  WHERE key = 'trial_days';

  -- 읽기 실패 시 기본값 3일
  IF v_trial_days IS NULL OR v_trial_days < 1 THEN
    v_trial_days := 3;
  END IF;

  INSERT INTO public.profiles (
    id,
    email,
    privacy_agreed,
    marketing_agreed,
    plan,
    trial_started_at,
    trial_ends_at,
    trial_status,
    created_at
  ) VALUES (
    NEW.id,
    NEW.email,
    COALESCE((NEW.raw_user_meta_data->>'privacy_agreed')::BOOLEAN, FALSE),
    COALESCE((NEW.raw_user_meta_data->>'marketing_agreed')::BOOLEAN, FALSE),
    'free_trial',
    NOW(),
    NOW() + (v_trial_days || ' days')::INTERVAL,
    'active',
    NOW()
  );

  RETURN NEW;
END;
$$;

-- 트리거 등록
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ---------------------------------------------------------------------------
-- 5. 인덱스
-- ---------------------------------------------------------------------------
CREATE INDEX IF NOT EXISTS profiles_trial_status_idx ON public.profiles (trial_status);
CREATE INDEX IF NOT EXISTS profiles_plan_idx          ON public.profiles (plan);

-- ---------------------------------------------------------------------------
-- 완료 확인용 조회
-- ---------------------------------------------------------------------------
SELECT 'settings' AS tbl, count(*) FROM public.settings
UNION ALL
SELECT 'profiles' AS tbl, count(*) FROM public.profiles;
