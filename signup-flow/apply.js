// apply.js — signup form handler
// Enables submit when required fields + privacy_agreed are valid,
// submits to Supabase `leads` table, redirects to thank-you on success.

(function () {
  const cfg  = window.__TRUSTA__ || {};
  const form = document.getElementById('apply-form');
  if (!form) return;

  const fields = {
    email:     document.getElementById('f-email'),
    brand:     document.getElementById('f-brand'),
    contact:   document.getElementById('f-contact'),
    website:   document.getElementById('f-url'),
    sample:    document.getElementById('f-sample'),
    privacy:   document.getElementById('f-privacy'),
    marketing: document.getElementById('f-marketing'),
  };
  const submitBtn   = document.getElementById('submit-btn');
  const submitError = document.getElementById('submit-error');

  const isValidEmail = (v) => /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(String(v || '').trim());

  function validate() {
    const okEmail   = isValidEmail(fields.email.value);
    const okBrand   = fields.brand.value.trim().length > 0;
    const okContact = fields.contact.value.trim().length > 0;
    const okSample  = fields.sample.value.trim().length > 0;
    const okPrivacy = fields.privacy.checked === true;
    const allOk = okEmail && okBrand && okContact && okSample && okPrivacy;
    submitBtn.disabled = !allOk;
    submitBtn.classList.toggle('is-disabled', !allOk);
    return { okEmail, okBrand, okContact, okSample, okPrivacy, allOk };
  }

  function reflectConsent(id) {
    const wrap = document.getElementById(id);
    const cb   = wrap.querySelector('input[type="checkbox"]');
    wrap.classList.toggle('checked', cb.checked);
  }

  ['email', 'brand', 'contact', 'sample'].forEach((k) => {
    fields[k].addEventListener('input', validate);
    fields[k].addEventListener('blur', () => {
      const v = validate();
      const fieldEl = fields[k].closest('.field');
      const ok = { email: v.okEmail, brand: v.okBrand, contact: v.okContact, sample: v.okSample };
      fieldEl.classList.toggle('error', !ok[k] && fields[k].value.trim().length > 0);
    });
  });

  fields.privacy.addEventListener('change',   () => { reflectConsent('c-privacy');   validate(); });
  fields.marketing.addEventListener('change', () => { reflectConsent('c-marketing'); });

  function buildPayload() {
    return {
      email:            fields.email.value.trim(),
      brand_name:       fields.brand.value.trim(),
      contact_name:     fields.contact.value.trim(),
      website_url:      fields.website.value.trim() || null,
      sample_text:      fields.sample.value.trim(),
      privacy_agreed:   fields.privacy.checked,
      marketing_agreed: fields.marketing.checked,
      source:           cfg.SOURCE || 'landing_main_cta',
    };
  }

  async function submitLead(payload) {
    if (!window.supabase || !cfg.SUPABASE_URL || cfg.SUPABASE_URL.includes('YOUR-PROJECT-REF')) {
      throw new Error('Supabase config missing. Edit config.js with your project URL + anon key.');
    }
    const sb = window.supabase.createClient(cfg.SUPABASE_URL, cfg.SUPABASE_ANON_KEY);
    const { error } = await sb.from('leads').insert(payload);
    if (error) throw error;
  }

  form.addEventListener('submit', async (e) => {
    e.preventDefault();
    const v = validate();
    if (!v.allOk) return;

    if (!fields.privacy.checked) {
      submitError.textContent = '개인정보 수집·이용 동의에 체크해 주세요.';
      submitError.classList.add('is-shown');
      return;
    }

    submitBtn.classList.add('is-loading');
    submitBtn.disabled = true;
    submitError.classList.remove('is-shown');

    const labelEl = submitBtn.querySelector('.label');
    const origLabel = labelEl ? labelEl.textContent : null;
    if (labelEl) labelEl.textContent = '신청 중…';

    try {
      await submitLead(buildPayload());
      window.location.href = cfg.THANK_YOU_URL || 'thank-you.html';
    } catch (err) {
      console.error('[TRUSTA submit error]', err);
      submitError.textContent =
        (err && err.message)
          ? `신청 처리 중 오류: ${err.message}`
          : '신청 처리 중 오류가 발생했습니다. 잠시 후 다시 시도해 주세요.';
      submitError.classList.add('is-shown');
      submitBtn.classList.remove('is-loading');
      submitBtn.disabled = false;
      if (labelEl && origLabel) labelEl.textContent = origLabel;
    }
  });

  validate();
  reflectConsent('c-privacy');
  reflectConsent('c-marketing');
})();
