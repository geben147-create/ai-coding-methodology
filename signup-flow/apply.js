// apply.js — TRUSTA Auth (Signup + Login)
// Uses Supabase Auth. User profile + trial timer is created via DB trigger.

(function () {
  const cfg = window.__TRUSTA__ || {};

  // ----- Supabase client (lazy) -----
  function getSB() {
    if (!window.supabase || !cfg.SUPABASE_URL || cfg.SUPABASE_URL.includes('YOUR-PROJECT-REF')) {
      return null;
    }
    return window.supabase.createClient(cfg.SUPABASE_URL, cfg.SUPABASE_ANON_KEY);
  }

  // ----- Tab switch -----
  window.switchTab = function (tab) {
    const isSignup = tab === 'signup';
    const sf = document.getElementById('signup-form');
    const lf = document.getElementById('login-form');
    const ts = document.getElementById('tab-signup');
    const tl = document.getElementById('tab-login');
    const err = document.getElementById('auth-error');

    if (sf) sf.style.display = isSignup ? '' : 'none';
    if (lf) lf.style.display = isSignup ? 'none' : '';
    if (ts) {
      ts.classList.toggle('active', isSignup);
      ts.setAttribute('aria-selected', isSignup ? 'true' : 'false');
    }
    if (tl) {
      tl.classList.toggle('active', !isSignup);
      tl.setAttribute('aria-selected', !isSignup ? 'true' : 'false');
    }
    if (err) {
      err.classList.remove('is-shown');
      err.textContent = '';
    }
  };

  // ----- Helpers -----
  const isValidEmail = (v) => /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(String(v || '').trim());

  function showError(msg) {
    const el = document.getElementById('auth-error');
    if (!el) return;
    el.textContent = msg;
    el.classList.add('is-shown');
  }

  function clearError() {
    const el = document.getElementById('auth-error');
    if (!el) return;
    el.classList.remove('is-shown');
    el.textContent = '';
  }

  function setBtnLoading(btn, loadingText) {
    if (!btn) return null;
    const labelEl = btn.querySelector('.label');
    const orig = labelEl ? labelEl.textContent : null;
    btn.classList.add('is-loading');
    btn.disabled = true;
    if (labelEl && loadingText) labelEl.textContent = loadingText;
    return orig;
  }

  function clearBtnLoading(btn, origText) {
    if (!btn) return;
    const labelEl = btn.querySelector('.label');
    btn.classList.remove('is-loading');
    btn.disabled = false;
    if (labelEl && origText) labelEl.textContent = origText;
  }

  // ----- Live validation for Signup -----
  function validateSignup() {
    const email = document.getElementById('s-email')?.value.trim() || '';
    const pw    = document.getElementById('s-pw')?.value || '';
    const pw2   = document.getElementById('s-pw2')?.value || '';
    const priv  = document.getElementById('s-privacy')?.checked;

    const ok = isValidEmail(email) && pw.length >= 8 && pw === pw2 && priv;
    const btn = document.getElementById('signup-btn');
    if (btn) {
      btn.disabled = !ok;
      btn.classList.toggle('is-disabled', !ok);
    }
    return ok;
  }

  // Bind live-validation listeners
  ['s-email', 's-pw', 's-pw2'].forEach((id) => {
    const el = document.getElementById(id);
    if (el) el.addEventListener('input', validateSignup);
  });

  // Consent checkbox visual + validation
  ['s-privacy', 's-marketing'].forEach((id) => {
    const el = document.getElementById(id);
    if (!el) return;
    el.addEventListener('change', () => {
      const wrap = el.closest('.consent');
      if (wrap) wrap.classList.toggle('checked', el.checked);
      validateSignup();
    });
  });

  // ----- Signup submit -----
  const signupForm = document.getElementById('signup-form');
  if (signupForm) {
    signupForm.addEventListener('submit', async (e) => {
      e.preventDefault();
      clearError();

      const sb = getSB();
      if (!sb) {
        showError('Supabase 설정이 필요합니다. signup-flow/config.js를 확인해 주세요.');
        return;
      }

      const email     = document.getElementById('s-email').value.trim();
      const pw        = document.getElementById('s-pw').value;
      const pw2       = document.getElementById('s-pw2').value;
      const privacy   = document.getElementById('s-privacy').checked;
      const marketing = document.getElementById('s-marketing').checked;

      if (!isValidEmail(email)) { showError('올바른 이메일 형식을 입력해 주세요.'); return; }
      if (pw.length < 8)        { showError('비밀번호는 8자 이상으로 입력해 주세요.'); return; }
      if (pw !== pw2)           { showError('비밀번호가 일치하지 않습니다.'); return; }
      if (!privacy)             { showError('개인정보 수집·이용 동의에 체크해 주세요.'); return; }

      const btn = document.getElementById('signup-btn');
      const origText = setBtnLoading(btn, '처리 중…');

      try {
        const { data, error } = await sb.auth.signUp({
          email,
          password: pw,
          options: {
            data: {
              privacy_agreed: privacy,
              marketing_agreed: marketing,
            },
          },
        });
        if (error) throw error;

        // Profile + trial 타이머는 DB trigger(handle_new_user)가 생성.
        window.location.href = cfg.THANK_YOU_URL || 'thank-you.html';
      } catch (err) {
        const raw = (err && err.message) ? err.message : '';
        const msg = (raw.includes('already registered') || raw.includes('User already registered'))
          ? '이미 가입된 이메일입니다. 로그인 탭을 이용해 주세요.'
          : (raw || '회원가입 중 오류가 발생했습니다.');
        showError(msg);
        clearBtnLoading(btn, origText);
      }
    });
  }

  // ----- Login submit -----
  const loginForm = document.getElementById('login-form');
  if (loginForm) {
    loginForm.addEventListener('submit', async (e) => {
      e.preventDefault();
      clearError();

      const sb = getSB();
      if (!sb) {
        showError('Supabase 설정이 필요합니다. signup-flow/config.js를 확인해 주세요.');
        return;
      }

      const email = document.getElementById('l-email').value.trim();
      const pw    = document.getElementById('l-pw').value;

      if (!isValidEmail(email)) { showError('올바른 이메일 형식을 입력해 주세요.'); return; }
      if (!pw)                  { showError('비밀번호를 입력해 주세요.'); return; }

      const btn = document.getElementById('login-btn');
      const origText = setBtnLoading(btn, '로그인 중…');

      try {
        const { data, error } = await sb.auth.signInWithPassword({ email, password: pw });
        if (error) throw error;
        window.location.href = cfg.DASHBOARD_URL || '../dashboard.html';
      } catch (err) {
        const raw = (err && err.message) ? err.message : '';
        const msg = raw.includes('Invalid login credentials')
          ? '이메일 또는 비밀번호가 올바르지 않습니다.'
          : (raw || '로그인 중 오류가 발생했습니다.');
        showError(msg);
        clearBtnLoading(btn, origText);
      }
    });
  }

  // Initial state
  validateSignup();
})();
