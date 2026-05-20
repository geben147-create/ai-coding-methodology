// auth-check.js — 보호된 페이지에서 공통으로 사용
//
// 사용법:
//   <script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2/dist/umd/supabase.min.js"></script>
//   <script src="signup-flow/config.js"></script>
//   <script src="auth-check.js"></script>
//   <script>const result = await initAuthCheck();</script>
//
// 반환값: 인증 성공 시 { sb, session, profile }, 실패 시 null (리다이렉트 처리됨)

async function initAuthCheck() {
  const cfg = window.__TRUSTA__ || {};

  if (!window.supabase || !cfg.SUPABASE_URL || cfg.SUPABASE_URL.includes('YOUR-PROJECT-REF')) {
    console.warn('[TRUSTA] Supabase not configured — auth check skipped');
    return null;
  }

  const sb = window.supabase.createClient(cfg.SUPABASE_URL, cfg.SUPABASE_ANON_KEY);

  // 1. 세션 확인
  const { data: sessionResp } = await sb.auth.getSession();
  const session = sessionResp ? sessionResp.session : null;

  if (!session) {
    window.location.href = cfg.SIGNUP_URL || '/signup-flow/signup.html';
    return null;
  }

  // 2. 프로필 확인
  const { data: profile, error } = await sb
    .from('user_profiles')
    .select('*')
    .eq('user_id', session.user.id)
    .single();

  if (error || !profile) {
    console.warn('[TRUSTA] user_profiles row not found', error);
    window.location.href = cfg.SIGNUP_URL || '/signup-flow/signup.html';
    return null;
  }

  // 3. 만료 체크
  const now = new Date();
  const endsAt = new Date(profile.trial_ends_at);

  // active이지만 시간 지났으면 expired로 DB 업데이트
  if (profile.trial_status === 'active' && endsAt < now) {
    await sb
      .from('user_profiles')
      .update({ trial_status: 'expired' })
      .eq('user_id', session.user.id);
    window.location.href = cfg.TRIAL_EXPIRED_URL || '/trial-expired.html';
    return null;
  }

  if (profile.trial_status === 'expired') {
    window.location.href = cfg.TRIAL_EXPIRED_URL || '/trial-expired.html';
    return null;
  }

  // 4. 허용 상태만 통과 (active / paid)
  if (profile.trial_status !== 'active' && profile.trial_status !== 'paid') {
    window.location.href = cfg.TRIAL_EXPIRED_URL || '/trial-expired.html';
    return null;
  }

  return { sb, session, profile };
}

// global expose (HTML inline script에서 사용)
window.initAuthCheck = initAuthCheck;
