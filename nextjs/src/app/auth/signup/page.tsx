'use client'
import { useState } from 'react'
import { useRouter } from 'next/navigation'
import { createClient } from '@/lib/supabase/client'
import Link from 'next/link'

export default function SignupPage() {
  const router = useRouter()
  const [email,     setEmail]     = useState('')
  const [password,  setPassword]  = useState('')
  const [brandName, setBrandName] = useState('')
  const [privacy,   setPrivacy]   = useState(false)
  const [marketing, setMarketing] = useState(false)
  const [loading,   setLoading]   = useState(false)
  const [error,     setError]     = useState('')
  const [done,      setDone]      = useState(false)

  const canSubmit = email && password.length >= 6 && privacy && !loading

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault()
    if (!privacy) { setError('개인정보 수집·이용 동의는 필수입니다.'); return }

    setLoading(true)
    setError('')

    const supabase = createClient()
    const siteUrl  = process.env.NEXT_PUBLIC_SITE_URL || window.location.origin

    const { data, error: signUpError } = await supabase.auth.signUp({
      email,
      password,
      options: {
        data: { brand_name: brandName, marketing_agreed: marketing },
        emailRedirectTo: `${siteUrl}/auth/callback`,
      },
    })

    if (signUpError) {
      setError(friendlyError(signUpError.message))
      setLoading(false)
      return
    }

    if (data.session) {
      router.push('/dashboard')
    } else {
      setDone(true)
    }
  }

  if (done) {
    return (
      <>
        <div className="topbar">
          <Link href="/" className="logo">TRUSTA</Link>
        </div>
        <div className="section" style={{ textAlign: 'center' }}>
          <div className="pill" style={{ background: 'var(--green)', marginBottom: 20 }}>✓ 전송 완료</div>
          <h1 style={{ fontFamily: 'var(--font-sans)', fontWeight: 900, fontSize: 32,
                       color: 'var(--ink)', marginTop: 16 }}>
            이메일을 확인해주세요
          </h1>
          <p style={{ marginTop: 16, fontSize: 15, color: 'var(--ink-2)', lineHeight: 1.7 }}>
            <strong>{email}</strong>으로 가입 확인 링크를 보냈습니다.<br />
            링크를 클릭하면 자동으로 로그인됩니다.
          </p>
          <p style={{ marginTop: 16, fontSize: 13, color: 'var(--ink-3)' }}>
            이메일이 보이지 않으면 스팸 폴더를 확인해 주세요.
          </p>
          <Link href="/auth/login" className="btn btn-ghost"
                style={{ marginTop: 32, display: 'flex' }}>
            로그인 화면으로
          </Link>
        </div>
      </>
    )
  }

  return (
    <>
      <div className="topbar">
        <Link href="/" className="logo">TRUSTA</Link>
        <span style={{ color: 'var(--ink-4)', fontSize: 12 }}>3일 무료체험</span>
      </div>

      <div className="section" style={{ textAlign: 'center', paddingBottom: 24 }}>
        <div className="pill" style={{ marginBottom: 20 }}>TRUSTA</div>
        <h1 style={{ fontFamily: 'var(--font-sans)', fontWeight: 900, fontSize: 40,
                     letterSpacing: '-0.03em', color: 'var(--ink)', lineHeight: 1.2 }}>
          3일{' '}
          <span style={{ background: 'var(--yellow)', padding: '0 8px' }}>무료</span>로<br />
          시작하세요.
        </h1>
        <p style={{ marginTop: 16, fontSize: 15, color: 'var(--ink-2)', lineHeight: 1.7 }}>
          이메일로 가입하면 즉시<br />
          K-뷰티 해외 문구 리스크 진단 서비스를 이용할 수 있습니다.
        </p>
      </div>

      <div style={{ padding: '0 32px 64px' }}>
        <form className="form-card" onSubmit={handleSubmit}>
          <p style={{ fontSize: 12, fontWeight: 600, letterSpacing: '0.06em',
                      color: 'var(--ink-3)', marginBottom: 20 }}>이메일로 가입하기</p>

          <div className="field">
            <label htmlFor="email">이메일 <span className="req">필수</span></label>
            <input id="email" type="email" autoComplete="email"
                   placeholder="brand@example.com" required
                   value={email} onChange={e => setEmail(e.target.value)} />
          </div>

          <div className="field">
            <label htmlFor="password">비밀번호 <span className="req">필수</span></label>
            <p className="hint">6자 이상</p>
            <input id="password" type="password" autoComplete="new-password"
                   placeholder="6자 이상" required minLength={6}
                   value={password} onChange={e => setPassword(e.target.value)} />
          </div>

          <div className="field" style={{ marginBottom: 28 }}>
            <label htmlFor="brand">브랜드명 <span className="opt">선택</span></label>
            <input id="brand" type="text" placeholder="예) BLOOM Skin"
                   value={brandName} onChange={e => setBrandName(e.target.value)} />
          </div>

          {/* 동의 */}
          <div style={{ borderTop: '1.5px solid var(--paper-3)', margin: '0 0 20px' }} />
          <p style={{ fontSize: 12, fontWeight: 600, letterSpacing: '0.06em',
                      color: 'var(--ink-3)', marginBottom: 14 }}>동의 항목</p>

          {/* 개인정보 (필수) */}
          <ConsentRow
            checked={privacy} onChange={setPrivacy}
            title="개인정보 수집·이용 동의" required
            body="서비스 제공을 위해 이메일을 수집·이용합니다. 보유기간: 회원 탈퇴 시까지."
          />
          <ConsentRow
            checked={marketing} onChange={setMarketing}
            title="마케팅·뉴스레터 수신 동의" required={false}
            body="화장품 해외 규제 업데이트, 신규 기능 안내를 이메일로 받습니다."
          />

          {error && <div className="alert-err">{error}</div>}

          <button type="submit" className="btn btn-ink" disabled={!canSubmit}
                  style={{ marginTop: 24 }}>
            {loading ? '처리 중…' : '3일 무료체험 시작하기 →'}
          </button>

          <p style={{ textAlign: 'center', marginTop: 20, fontSize: 14, color: 'var(--ink-3)' }}>
            이미 계정이 있으신가요?{' '}
            <Link href="/auth/login"
                  style={{ color: 'var(--ink)', fontWeight: 700, textDecoration: 'underline' }}>
              로그인
            </Link>
          </p>
        </form>
      </div>

      <footer style={{ background: '#0a0a0a', color: 'var(--ink-4)', padding: '28px 32px',
                       textAlign: 'center', fontSize: 12 }}>
        <div style={{ color: 'var(--yellow)', fontWeight: 900, fontSize: 16 }}>TRUSTA</div>
        <p style={{ marginTop: 8, color: '#555', fontSize: 11 }}>© 2026 TRUSTA.</p>
      </footer>
    </>
  )
}

function ConsentRow({ checked, onChange, title, required: isReq, body }: {
  checked: boolean; onChange: (v: boolean) => void
  title: string; required: boolean; body: string
}) {
  return (
    <div onClick={() => onChange(!checked)}
         style={{ border: '2.5px solid var(--ink)', borderRadius: 14,
                  padding: '14px 16px', marginBottom: 12, cursor: 'pointer',
                  background: checked ? 'rgba(255,230,0,0.06)' : 'var(--paper)' }}>
      <div style={{ display: 'flex', gap: 12, alignItems: 'flex-start' }}>
        <div style={{
          flexShrink: 0, width: 24, height: 24, borderRadius: 6,
          border: '2.5px solid var(--ink)',
          background: checked ? 'var(--ink)' : 'transparent',
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          color: checked ? 'var(--yellow)' : 'transparent', fontWeight: 900, fontSize: 14,
        }}>✓</div>
        <div style={{ flex: 1 }}>
          <div style={{ fontWeight: 700, fontSize: 15, display: 'flex', alignItems: 'center', gap: 8 }}>
            {title}
            {isReq
              ? <span className="req">필수</span>
              : <span className="opt">선택</span>}
          </div>
          <p style={{ fontSize: 13, color: 'var(--ink-3)', marginTop: 4, lineHeight: 1.5 }}>{body}</p>
        </div>
      </div>
    </div>
  )
}

function friendlyError(msg: string): string {
  if (msg.includes('already registered')) return '이미 가입된 이메일입니다. 로그인해 주세요.'
  if (msg.includes('Password'))          return '비밀번호는 6자 이상이어야 합니다.'
  if (msg.includes('valid email'))       return '올바른 이메일 형식을 입력해 주세요.'
  return msg || '오류가 발생했습니다. 잠시 후 다시 시도해 주세요.'
}
