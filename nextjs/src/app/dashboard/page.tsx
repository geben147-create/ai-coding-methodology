import { redirect } from 'next/navigation'
import { createClient } from '@/lib/supabase/server'
import { checkTrialAccess, formatDate } from '@/lib/trial'
import Link from 'next/link'
import LogoutButton from './LogoutButton'

export default async function DashboardPage() {
  const supabase = await createClient()
  const { data: { user } } = await supabase.auth.getUser()

  if (!user) redirect('/auth/login')

  const { allowed, profile, reason, daysLeft } = await checkTrialAccess(supabase, user.id)

  if (!allowed) redirect('/trial-expired')

  const planLabel: Record<string, string> = {
    free_trial: '무료체험', standard: '스탠다드', growth: '그로스', admin: '관리자',
  }

  return (
    <>
      {/* Topbar */}
      <div className="topbar">
        <span className="logo">TRUSTA</span>
        <div style={{ display: 'flex', alignItems: 'center', gap: 16 }}>
          <span style={{ fontSize: 12, color: 'var(--ink-4)' }}>{user.email}</span>
          <LogoutButton />
        </div>
      </div>

      {/* Hero */}
      <div className="section" style={{ textAlign: 'center' }}>
        <div className="pill" style={{ marginBottom: 20 }}>TRUSTA</div>

        {reason === 'active' && (
          <div className={`trial-badge ${daysLeft <= 1 ? 'warn' : ''}`} style={{ marginBottom: 20 }}>
            무료체험 D-{daysLeft}
          </div>
        )}
        {reason === 'paid' && (
          <div className="trial-badge" style={{ marginBottom: 20, background: 'var(--green)', color: 'white', borderColor: 'var(--green)' }}>
            ✓ 유료 플랜 활성
          </div>
        )}

        <h1 style={{ fontFamily: 'var(--font-sans)', fontWeight: 900, fontSize: 36,
                     letterSpacing: '-0.03em', color: 'var(--ink)', lineHeight: 1.2 }}>
          안녕하세요,<br />
          <span style={{ background: 'var(--yellow)', padding: '0 8px' }}>
            {profile?.brand_name || user.email?.split('@')[0]}
          </span>님
        </h1>
        <p style={{ marginTop: 16, fontSize: 15, color: 'var(--ink-2)', lineHeight: 1.7 }}>
          K-뷰티 해외 문구 리스크 진단 서비스입니다.<br />
          {reason === 'active' ? `무료체험 기간(${daysLeft}일 남음) 동안 자유롭게 이용하세요.` : '서비스를 이용하세요.'}
        </p>
      </div>

      {/* 진단 바로가기 */}
      <div className="section soft">
        <div style={{ textAlign: 'center', marginBottom: 28 }}>
          <div className="pill" style={{ marginBottom: 16 }}>RISK SCANNER</div>
          <h2 style={{ fontWeight: 900, fontSize: 28, letterSpacing: '-0.02em' }}>
            문구 리스크 진단
          </h2>
          <p style={{ marginTop: 10, fontSize: 15, color: 'var(--ink-3)' }}>
            제품 설명·SNS 카피를 붙여넣으면 고위험 표현을 분석합니다.
          </p>
        </div>
        <Link href="/scanner" className="btn btn-ink" style={{ display: 'flex' }}>
          리스크 진단 시작하기 →
        </Link>
      </div>

      {/* 내 현황 */}
      <div className="section">
        <div className="card">
          <h3 style={{ fontWeight: 900, fontSize: 22, marginBottom: 20 }}>내 무료체험 현황</h3>
          {[
            { label: '플랜',       value: planLabel[profile?.plan ?? 'free_trial'] },
            { label: '상태',       value: profile?.trial_status === 'active' ? '✅ 활성' : profile?.trial_status },
            { label: '체험 시작일', value: profile?.trial_started_at ? formatDate(profile.trial_started_at) : '–' },
            { label: '체험 만료일', value: profile?.trial_ends_at   ? formatDate(profile.trial_ends_at)   : '–' },
            { label: '남은 기간',  value: reason === 'paid' ? '무제한' : `${daysLeft}일` },
          ].map(({ label, value }) => (
            <div key={label} style={{ display: 'flex', justifyContent: 'space-between',
                                      padding: '14px 0', borderBottom: '1px solid var(--paper-3)',
                                      fontSize: 16 }}>
              <span style={{ fontWeight: 600, color: 'var(--ink)' }}>{label}</span>
              <span style={{ fontWeight: 700 }}>{value}</span>
            </div>
          ))}
        </div>
      </div>

      {/* 플랜 업그레이드 */}
      {reason === 'active' && (
        <div className="section dark" style={{ textAlign: 'center' }}>
          <div className="pill yellow" style={{ marginBottom: 20 }}>PLAN</div>
          <h2 style={{ fontWeight: 900, fontSize: 28, color: 'var(--paper)', lineHeight: 1.3 }}>
            무료체험 이후에도<br />계속 이용하려면?
          </h2>
          <p style={{ color: 'var(--ink-4)', marginTop: 16, fontSize: 15, lineHeight: 1.7 }}>
            TRUSTA 플랜을 신청하면<br />제한 없이 문구 리스크 진단을 이용할 수 있습니다.
          </p>
          <a href="mailto:hello@trusta.ai?subject=TRUSTA 플랜 문의"
             className="btn btn-yellow" style={{ marginTop: 28, display: 'flex' }}>
            플랜 신청 문의하기 →
          </a>
        </div>
      )}

      <footer style={{ background: '#0a0a0a', color: 'var(--ink-4)', padding: '28px 32px',
                       textAlign: 'center', fontSize: 12 }}>
        <div style={{ color: 'var(--yellow)', fontWeight: 900, fontSize: 16 }}>TRUSTA</div>
        <p style={{ marginTop: 8, color: '#555', fontSize: 11 }}>© 2026 TRUSTA.</p>
      </footer>
    </>
  )
}
