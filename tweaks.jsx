// tweaks.jsx — TRUSTA Wadiz landing page tweaks
// Mounts in #tweaks-root and exposes a small set of design knobs.

const TWEAK_DEFAULTS = /*EDITMODE-BEGIN*/{
  "accent": "#FFE600",
  "accentEdge": "#F5C400",
  "heroStyle": "stacked",
  "stickyCTA": true,
  "density": "regular"
}/*EDITMODE-END*/;

const ACCENT_OPTIONS = [
  ["#FFE600", "#F5C400"], // 시그니처 옐로 (월천 그대로)
  ["#FFE600", "#000000"]  // 블랙 엣지 (조금 더 RegTech)
];

const ACCENT_NAMED = {
  yellow:  ["#FFE600", "#F5C400"],
  lime:    ["#D7FF3B", "#9BC700"],
  coral:   ["#FF8A65", "#D9532E"],
  mint:    ["#7BE3CB", "#1F8E78"]
};

function App() {
  const [t, setTweak] = useTweaks(TWEAK_DEFAULTS);

  // Apply tweaks to CSS variables on :root
  React.useEffect(() => {
    const root = document.documentElement;
    const acc = ACCENT_NAMED[t.accent] || [t.accent, t.accentEdge];
    root.style.setProperty('--yellow', acc[0]);
    root.style.setProperty('--yellow-edge', acc[1]);
    root.style.setProperty('--accent', acc[0]);
    root.style.setProperty('--accent-edge', acc[1]);

    // Density: tweak section padding
    if (t.density === 'compact') {
      root.style.setProperty('--s-80', '56px');
      root.style.setProperty('--s-64', '44px');
    } else if (t.density === 'spacious') {
      root.style.setProperty('--s-80', '104px');
      root.style.setProperty('--s-64', '80px');
    } else {
      root.style.setProperty('--s-80', '80px');
      root.style.setProperty('--s-64', '64px');
    }
  }, [t.accent, t.accentEdge, t.density]);

  // Hero style variants — toggle classes on the hero
  React.useEffect(() => {
    const hero = document.querySelector('#hero');
    if (!hero) return;
    hero.dataset.heroStyle = t.heroStyle;
  }, [t.heroStyle]);

  // Sticky bottom CTA
  if (t.stickyCTA && !document.querySelector('#sticky-cta')) {
    const el = document.createElement('div');
    el.id = 'sticky-cta';
    el.innerHTML = `
      <a href="/auth/signup.html" class="cta yellow"
         style="border-radius: 16px; padding: 16px 22px; box-shadow: 0 8px 24px rgba(0,0,0,0.25); text-decoration: none;">
        문구 10개 무료 진단 신청 <span class="arrow" style="color: var(--ink);">→</span>
      </a>`;
    el.style.cssText = `
      position: fixed; left: 50%; bottom: 16px; transform: translateX(-50%);
      width: min(640px, calc(100vw - 32px)); z-index: 100; pointer-events: auto;
    `;
    document.body.appendChild(el);
  } else if (!t.stickyCTA) {
    const el = document.querySelector('#sticky-cta');
    if (el) el.remove();
  }

  return (
    <TweaksPanel title="Tweaks">
      <TweakSection label="브랜드 컬러" />
      <TweakRadio
        label="포인트 컬러"
        value={t.accent}
        options={["yellow", "lime", "coral", "mint"]}
        onChange={(v) => setTweak('accent', v)}
      />

      <TweakSection label="레이아웃" />
      <TweakRadio
        label="여백 밀도"
        value={t.density}
        options={["compact", "regular", "spacious"]}
        onChange={(v) => setTweak('density', v)}
      />
      <TweakRadio
        label="히어로 스타일"
        value={t.heroStyle}
        options={["stacked", "compact"]}
        onChange={(v) => setTweak('heroStyle', v)}
      />

      <TweakSection label="고정 CTA" />
      <TweakToggle
        label="하단 고정 버튼"
        value={t.stickyCTA}
        onChange={(v) => setTweak('stickyCTA', v)}
      />
    </TweaksPanel>
  );
}

// Mount
const root = ReactDOM.createRoot(document.getElementById('tweaks-root'));
root.render(<App />);
