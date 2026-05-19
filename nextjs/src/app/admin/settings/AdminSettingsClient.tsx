'use client'
import { useState } from 'react'
import { createClient } from '@/lib/supabase/client'
import Link from 'next/link'
import LogoutButton from '@/app/dashboard/LogoutButton'

interface Setting { key: string; value: string; updated_at: string }

export default function AdminSettingsClient({
  initialSettings, userEmail,
}: { initialSettings: Setting[]; userEmail: string }) {
  const [settings, setSettings] = useState<Setting[]>(initialSettings)
  const [saving,   setSaving]   = useState(false)
  const [msg,      setMsg]      = useState('')
  const [trialDays, setTrialDays] = useState(
    initialSettings.find(s => s.key === 'trial_days')?.value ?? '3'
  )

  async function saveSetting(key: string, value: string) {
    setSaving(true)
    setMsg('')
    const supabase = createClient()
    const { error } = await supabase
      .from('settings')
      .upsert({ key, value, updated_at: new Date().toISOString() })

    if (error) {
      setMsg(`❌ 저장 실패: ${error.message}`)
    } else {
      setMsg('✅ 저장 완료')
      setSettings(prev => prev.map(s => s.key === key ? { ...s, value } : s))
      setTimeout(() => setMsg(''), 3000)
    }
    setSaving(false)
  }

  const TRIAL_OPTIONS = [
    { label: '1일 (테스트용)', value: '1' },
    { label: '3일 (기본값)',   value: '3' },
    { label: '7일',           value: '7' },
    { label: '14일',          value: '14' },
    { label: '30일',          value: '30' },
  ]

  return (
    <>
      <div className="topbar">
        <Link href="/dashboard" className="logo">TRUSTA</Link>
        <div style={{ display: 'flex', alignItems: 'center', gap: 16 }}>
          <span style={{ fontSize: 11, color: 'var(--yellow)', fontWeight: 700 }}>ADMIN</span>
          <span style={{ fontSize: 12, color: 'var(--ink-4)' }}>{userEmail}</span>
          <LogoutButton />
        </div>
      </div>

      <div className="section" style={{ textAlign: 'center', paddingBottom: 24 }}>
        <div className="pill" style={{ marginBottom: 16 }}>ADMIN</div>
        <h1 style={{ fontFamily: 'var(--font-sans)', fontWeight: 900, fontSize: 32,
                     letterSpacing: '-0.03em', color: 'var(--ink)' }}>
          서비스 설정
        </h1>
        <p style={{ marginTop: 10, fontSize: 14, color: 'var(--ink-3)' }}>
          어드민 전용 설정 페이지입니다.
        </p>
      </div>

      <div style={{ padding: '0 32px 64px' }}>

        {/* 무료체험 기간 설정 */}
        <div className="card" style={{ marginBottom: 24 }}>
          <h3 style={{ fontWeight: 900, fontSize: 20, marginBottom: 8 }}>무료체험 기간</h3>
          <p style={{ fontSize: 14, color: 'var(--ink-3)', marginBottom: 20, lineHeight: 1.5 }}>
            새로 가입하는 사용자에게 적용될 무료체험 기간을 설정합니다.<br />
            <strong>기존 사용자에게는 영향 없음.</strong>
          </p>

          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(5, 1fr)', gap: 10, marginBottom: 20 }}>
            {TRIAL_OPTIONS.map(opt => (
              <button key={opt.value} onClick={() => setTrialDays(opt.value)}
                      style={{
                        padding: '14px 8px', borderRadius: 12, fontSize: 13, fontWeight: 700,
                        border: trialDays === opt.value ? '3px solid var(--ink)' : '2px solid var(--paper-3)',
                        background: trialDays === opt.value ? 'var(--yellow)' : 'var(--paper-2)',
                        color: 'var(--ink)', cursor: 'pointer', textAlign: 'center',
                        transition: 'all 150ms ease',
                      }}>
                {opt.label}
              </button>
            ))}
          </div>

          <div style={{ display: 'flex', gap: 12, alignItems: 'center', marginBottom: 16 }}>
            <input
              type="number" min="1" max="365"
              value={trialDays}
              onChange={e => setTrialDays(e.target.value)}
              style={{ width: 80, fontFamily: 'var(--font-sans)', fontSize: 20, fontWeight: 900,
                       border: '2.5px solid var(--ink)', borderRadius: 10, padding: '10px 14px',
                       outline: 'none', textAlign: 'center' }}
            />
            <span style={{ fontSize: 16, fontWeight: 600, color: 'var(--ink)' }}>일</span>
            <button onClick={() => saveSetting('trial_days', trialDays)}
                    disabled={saving} className="btn btn-ink"
                    style={{ flex: 1, padding: '14px 20px' }}>
              {saving ? '저장 중…' : '저장하기'}
            </button>
          </div>

          {msg && (
            <div style={{ padding: '10px 14px', borderRadius: 10, fontSize: 14, fontWeight: 700,
                          background: msg.includes('✅') ? '#DAF4E3' : '#FFD9DB',
                          color: msg.includes('✅') ? 'var(--green)' : 'var(--warn-red)' }}>
              {msg}
            </div>
          )}
        </div>

        {/* 전체 settings 테이블 */}
        <div className="card">
          <h3 style={{ fontWeight: 900, fontSize: 20, marginBottom: 16 }}>전체 설정값</h3>
          <div style={{ overflowX: 'auto' }}>
            <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: 14 }}>
              <thead>
                <tr style={{ background: 'var(--ink)', color: 'var(--paper)' }}>
                  {['key', 'value', '마지막 수정'].map(h => (
                    <th key={h} style={{ padding: '12px 16px', textAlign: 'left', fontWeight: 700 }}>{h}</th>
                  ))}
                </tr>
              </thead>
              <tbody>
                {settings.map(s => (
                  <tr key={s.key} style={{ borderBottom: '1px solid var(--paper-3)' }}>
                    <td style={{ padding: '12px 16px', fontWeight: 700 }}>{s.key}</td>
                    <td style={{ padding: '12px 16px', color: 'var(--yellow-edge)', fontWeight: 700 }}>{s.value}</td>
                    <td style={{ padding: '12px 16px', color: 'var(--ink-3)', fontSize: 12 }}>
                      {new Date(s.updated_at).toLocaleString('ko-KR')}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>

        {/* 어드민 지침 */}
        <div style={{ marginTop: 24, background: 'var(--paper-2)', borderRadius: 16,
                      padding: '20px 24px', fontSize: 14, color: 'var(--ink-3)', lineHeight: 1.7 }}>
          <strong style={{ color: 'var(--ink)' }}>trial_days 변경 방법</strong><br />
          1. 위 버튼에서 선택하거나 직접 숫자 입력<br />
          2. "저장하기" 클릭<br />
          3. 이후 가입하는 신규 사용자부터 해당 기간 적용<br />
          <br />
          <strong style={{ color: 'var(--ink)' }}>SQL로도 변경 가능:</strong><br />
          <code style={{ background: '#e8e8e8', padding: '2px 6px', borderRadius: 4, fontSize: 12 }}>
            UPDATE public.settings SET value = &apos;7&apos; WHERE key = &apos;trial_days&apos;;
          </code>
        </div>
      </div>

      <footer style={{ background: '#0a0a0a', color: 'var(--ink-4)', padding: '28px 32px',
                       textAlign: 'center', fontSize: 12 }}>
        <div style={{ color: 'var(--yellow)', fontWeight: 900, fontSize: 16 }}>TRUSTA</div>
        <p style={{ marginTop: 8, color: '#555', fontSize: 11 }}>© 2026 TRUSTA. Admin Only</p>
      </footer>
    </>
  )
}
