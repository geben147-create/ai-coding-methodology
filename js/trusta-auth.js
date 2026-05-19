// js/trusta-auth.js
// TRUSTA 공통 Auth 유틸리티 — 보호된 페이지마다 로드
// 의존: trusta-config.js 가 먼저 로드되어야 함

(function () {
  function getClient() {
    const cfg = window.TRUSTA_CONFIG || {};
    if (!cfg.SUPABASE_URL || cfg.SUPABASE_URL.includes('YOUR')) {
      console.error('[TRUSTA] Supabase 설정이 없습니다. js/trusta-config.js 를 확인하세요.');
      return null;
    }
    return window.supabase.createClient(cfg.SUPABASE_URL, cfg.SUPABASE_ANON_KEY);
  }

  // 로그인 여부 확인. 미로그인이면 /auth/login.html 로 이동.
  async function requireAuth() {
    const sb = getClient();
    if (!sb) return null;
    const { data: { session } } = await sb.auth.getSession();
    if (!session) {
      window.location.href = '/auth/login.html';
      return null;
    }
    return session;
  }

  // 무료체험 유효 여부 확인.
  // - 미로그인  → /auth/login.html
  // - 만료됨    → trial_status = expired 업데이트 후 /trial-expired.html
  // - 정상      → profile 반환
  async function checkTrial() {
    const sb = getClient();
    if (!sb) return null;

    const session = await requireAuth();
    if (!session) return null;

    const { data: profile, error } = await sb
      .from('profiles')
      .select('*')
      .eq('id', session.user.id)
      .single();

    if (error || !profile) {
      console.error('[TRUSTA] 프로필 조회 실패', error);
      window.location.href = '/auth/login.html';
      return null;
    }

    // 유료 플랜 (standard / growth / admin)은 무조건 통과
    if (['standard', 'growth', 'admin'].includes(profile.plan)) {
      return profile;
    }

    // free_trial: 만료 여부 확인
    const now = new Date();
    const trialEnd = profile.trial_ends_at ? new Date(profile.trial_ends_at) : null;
    const isExpired = profile.trial_status === 'expired' || (trialEnd && now > trialEnd);

    if (isExpired) {
      if (profile.trial_status !== 'expired') {
        await sb.from('profiles')
          .update({ trial_status: 'expired' })
          .eq('id', session.user.id);
      }
      window.location.href = '/trial-expired.html';
      return null;
    }

    return profile;
  }

  // 남은 일수 계산 (소수점 올림)
  function daysLeft(profile) {
    if (!profile || !profile.trial_ends_at) return 0;
    const diff = new Date(profile.trial_ends_at) - new Date();
    return Math.max(0, Math.ceil(diff / 86400000));
  }

  window.TRUSTA = { getClient, requireAuth, checkTrial, daysLeft };
})();
