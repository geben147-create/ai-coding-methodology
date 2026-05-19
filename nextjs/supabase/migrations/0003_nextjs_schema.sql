-- =============================================================================
-- TRUSTA · Next.js Auth + Trial System
-- Run in Supabase SQL Editor
-- =============================================================================

-- ---------------------------------------------------------------------------
-- 1. settings 테이블 (trial_days 등 운영 설정값)
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.settings (
  key        TEXT        PRIMARY KEY,
  value      TEXT        NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

INSERT INTO public.settings (key, value)
VALUES ('trial_days', '3')
ON CONFLICT (key) DO NOTHING;

-- ---------------------------------------------------------------------------
-- 2. profiles 테이블
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.profiles (
  id               UUID        PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email            TEXT        NOT NULL,
  brand_name       TEXT,
  plan             TEXT        NOT NULL DEFAULT 'free_trial'
                   CHECK (plan IN ('free_trial', 'standard', 'growth', 'admin')),
  trial_started_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  trial_ends_at    TIMESTAMPTZ NOT NULL,
  trial_status     TEXT        NOT NULL DEFAULT 'active'
                   CHECK (trial_status IN ('active', 'expired', 'paid')),
  created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 인덱스
CREATE INDEX IF NOT EXISTS profiles_trial_status_idx ON public.profiles (trial_status);
CREATE INDEX IF NOT EXISTS profiles_plan_idx          ON public.profiles (plan);
CREATE INDEX IF NOT EXISTS profiles_trial_ends_at_idx ON public.profiles (trial_ends_at);

-- ---------------------------------------------------------------------------
-- 3. RLS 활성화
-- ---------------------------------------------------------------------------
ALTER TABLE public.settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- settings: 인증 사용자 읽기, admin만 쓰기
DROP POLICY IF EXISTS "settings_authenticated_read" ON public.settings;
DROP POLICY IF EXISTS "settings_admin_write"         ON public.settings;

CREATE POLICY "settings_authenticated_read" ON public.settings
  FOR SELECT TO authenticated, anon USING (TRUE);

CREATE POLICY "settings_admin_write" ON public.settings
  FOR ALL TO authenticated
  USING (
    EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND plan = 'admin')
  )
  WITH CHECK (
    EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND plan = 'admin')
  );

-- profiles: 본인 행만
DROP POLICY IF EXISTS "profiles_select_own" ON public.profiles;
DROP POLICY IF EXISTS "profiles_update_own" ON public.profiles;

CREATE POLICY "profiles_select_own" ON public.profiles
  FOR SELECT TO authenticated USING (id = auth.uid());

CREATE POLICY "profiles_update_own" ON public.profiles
  FOR UPDATE TO authenticated
  USING (id = auth.uid())
  WITH CHECK (
    id = auth.uid()
    AND plan NOT IN ('admin')
  );

-- ---------------------------------------------------------------------------
-- 4. 트리거: 신규 가입 시 profile 자동 생성
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
  SELECT value::INT INTO v_trial_days
  FROM public.settings WHERE key = 'trial_days';

  IF v_trial_days IS NULL OR v_trial_days < 1 THEN
    v_trial_days := 3;
  END IF;

  INSERT INTO public.profiles (
    id, email, brand_name, plan,
    trial_started_at, trial_ends_at, trial_status, created_at
  ) VALUES (
    NEW.id,
    NEW.email,
    NEW.raw_user_meta_data->>'brand_name',
    'free_trial',
    NOW(),
    NOW() + (v_trial_days || ' days')::INTERVAL,
    'active',
    NOW()
  );

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ---------------------------------------------------------------------------
-- 5. 서버 사이드 trial 체크 함수 (service_role 에서 호출)
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.check_and_expire_trial(p_user_id UUID)
RETURNS TABLE(allowed BOOLEAN, trial_status TEXT, plan TEXT)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_profile public.profiles%ROWTYPE;
BEGIN
  SELECT * INTO v_profile FROM public.profiles WHERE id = p_user_id;

  IF NOT FOUND THEN
    RETURN QUERY SELECT FALSE, 'no_profile'::TEXT, 'free_trial'::TEXT;
    RETURN;
  END IF;

  -- 유료 플랜은 무조건 허용
  IF v_profile.plan IN ('standard', 'growth', 'admin') THEN
    RETURN QUERY SELECT TRUE, v_profile.trial_status, v_profile.plan;
    RETURN;
  END IF;

  -- 만료 여부 확인
  IF v_profile.trial_status = 'expired' OR NOW() > v_profile.trial_ends_at THEN
    IF v_profile.trial_status != 'expired' THEN
      UPDATE public.profiles SET trial_status = 'expired' WHERE id = p_user_id;
    END IF;
    RETURN QUERY SELECT FALSE, 'expired'::TEXT, v_profile.plan;
    RETURN;
  END IF;

  RETURN QUERY SELECT TRUE, 'active'::TEXT, v_profile.plan;
END;
$$;

-- 확인
SELECT 'Migration complete' AS status;
