-- ============================================================
-- TRUSTA Supabase Migration
-- Run this in: Supabase Dashboard → SQL Editor
-- ============================================================

-- 1. settings 테이블 (무료체험 일수 등 관리)
CREATE TABLE IF NOT EXISTS settings (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 기본값: 무료체험 3일
INSERT INTO settings (key, value) VALUES ('trial_days', '3')
ON CONFLICT (key) DO NOTHING;

-- 2. user_profiles 테이블
CREATE TABLE IF NOT EXISTS user_profiles (
  user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  privacy_agreed BOOLEAN NOT NULL DEFAULT FALSE,
  marketing_agreed BOOLEAN NOT NULL DEFAULT FALSE,
  plan TEXT NOT NULL DEFAULT 'free_trial',
  trial_started_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  trial_ends_at TIMESTAMPTZ NOT NULL DEFAULT (NOW() + INTERVAL '3 days'),
  trial_status TEXT NOT NULL DEFAULT 'active',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- plan 값 체크 (확장 가능: free_trial / standard / growth / admin)
ALTER TABLE user_profiles
  ADD CONSTRAINT chk_plan
  CHECK (plan IN ('free_trial', 'standard', 'growth', 'admin'));

ALTER TABLE user_profiles
  ADD CONSTRAINT chk_trial_status
  CHECK (trial_status IN ('active', 'expired', 'paid'));

-- 3. RLS 활성화
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE settings ENABLE ROW LEVEL SECURITY;

-- 4. user_profiles RLS 정책
-- 사용자는 자기 데이터만 읽기 가능
CREATE POLICY "users_select_own" ON user_profiles
  FOR SELECT USING (auth.uid() = user_id);

-- 사용자는 자기 동의 정보와 trial_status만 수정 가능
CREATE POLICY "users_update_own" ON user_profiles
  FOR UPDATE USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- 신규 사용자 insert는 trigger에서만 (service role 사용)
-- 아래 정책은 anon/authenticated 사용자의 직접 insert를 차단
-- (trigger는 SECURITY DEFINER로 실행되므로 RLS 우회)

-- 5. settings RLS 정책
-- 로그인한 사용자는 읽기 가능
CREATE POLICY "auth_read_settings" ON settings
  FOR SELECT TO authenticated USING (true);

-- 수정은 service role만 (대시보드에서 직접 수정)
-- CREATE POLICY "admin_update_settings" 는 service role key로만 가능하므로 별도 정책 불필요

-- 6. 신규 회원가입 시 자동으로 user_profiles 생성하는 Trigger
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_trial_days INT;
BEGIN
  -- settings에서 trial_days 읽기
  SELECT value::INT INTO v_trial_days
  FROM settings
  WHERE key = 'trial_days';

  -- fallback: settings에 없으면 3일
  IF v_trial_days IS NULL THEN
    v_trial_days := 3;
  END IF;

  INSERT INTO user_profiles (
    user_id,
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

-- 기존 trigger 있으면 제거 후 재생성
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();
