import Link from 'next/link'
import LogoutButton from '../dashboard/LogoutButton'

export default function TrialExpiredPage() {
  return (
    <>
      <div className="topbar">
        <Link href="/" className="logo">TRUSTA</Link>
        <LogoutButton />
      </div>

      {/* 메인 메시지 */}
      <div className="section dark" style={{
        minHeight: '70vh', display: 'flex', flexDirection: 'column',
        alignItems: 'center', justifyContent: 'center', textAlign: 'center',
      }}>
        <div className="pill yellow" style={{ marginBottom: 24 }}>EXPIRED</div>

        <h1 style={{ fontFamily: 'var(--font-sans)', fontWeight: 900, fontSize: 36,
                     color: 'var(--paper)', lineHeight: 1.3 }}>
          무료 진단 기간이<br />
          <span style={{ color: 'var(--yellow)' }}>종료</span>되었습니다.
        </h1>

        <p style={{ color: 'var(--ink-4)', marginTop: 24, fontSize: 16,
                    lineHeight: 1.75, maxWidth: 380 }}>
          계속 이용하려면<br />
          <strong style={{ color: 'var(--paper)' }}>TRUSTA 리포트 플랜을 신청</strong>해주세요.
        </p>

        {/* 플랜 혜택 */}
        <div style={{
          marginTop: 40, width: '100%', maxWidth: 400,
          background: 'rgba(255,255,255,0.06)',
          border: '1.5px solid rgba(255,255,255,0.15)',
          borderRadius: 18, padding: 24, textAlign: 'left',
        }}>
          <p style={{ fontSize: 11, fontWeight: 600, letterSpacing: '0.08em',
                      color: 'var(--yellow)', marginBottom: 16 }}>TRUSTA 리포트 플랜 혜택</p>
          {[
            'K-뷰티 해외 문구 리스크 진단 (무제한)',
            'EN · JP · CN 현지어 콘텐츠 변환',
            'Threads 중심 콘텐츠 이정 지원',
            '월간 성과 리포트 + 다음 개선안 제안',
            '발행 전 문구 무제한 사전 점검',
          ].map(item => (
            <div key={item} style={{ display: 'flex', gap: 12, alignItems: 'flex-start',
                                     color: 'var(--paper)', fontSize: 14, marginBottom: 10 }}>
              <span style={{ color: 'var(--yellow)', fontWeight: 900, flexShrink: 0 }}>✓</span>
              {item}
            </div>
          ))}
        </div>

        {/* CTA */}
        <a href="mailto:hello@trusta.ai?subject=TRUSTA 리포트 플랜 신청"
           className="btn btn-yellow"
           style={{ marginTop: 36, width: '100%', maxWidth: 400, display: 'flex' }}>
          플랜 신청 문의하기 →
        </a>

        <Link href="/auth/login"
              style={{ marginTop: 16, fontSize: 14, color: 'var(--ink-4)',
                       textDecoration: 'underline' }}>
          다른 계정으로 로그인
        </Link>
      </div>

      <footer style={{ background: '#0a0a0a', color: 'var(--ink-4)', padding: '28px 32px',
                       textAlign: 'center', fontSize: 12 }}>
        <div style={{ color: 'var(--yellow)', fontWeight: 900, fontSize: 16 }}>TRUSTA</div>
        <p style={{ marginTop: 8, color: '#555', fontSize: 11 }}>© 2026 TRUSTA.</p>
      </footer>
    </>
  )
}
