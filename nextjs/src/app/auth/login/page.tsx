'use client'
import { useState } from 'react'
import { useRouter } from 'next/navigation'
import { createClient } from '@/lib/supabase/client'
import Link from 'next/link'

export default function LoginPage() {
  const router = useRouter()
  const [email,    setEmail]    = useState('')
  const [password, setPassword] = useState('')
  const [loading,  setLoading]  = useState(false)
  const [error,    setError]    = useState('')

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault()
    setLoading(true)
    setError('')

    const supabase = createClient()
    const { error: signInError } = await supabase.auth.signInWithPassword({ email, password })

    if (signInError) {
      setError('이메일 또는 비밀번호가 올바르지 않습니다.')
      setLoading(false)
      return
    }

    router.push('/dashboard')
    router.refresh()
  }

  return (
    <>
      {/* Topbar */}
      <div className="topbar">
        <Link href="/" className="logo">TRUSTA</Link>
        <span style={{ color: 'var(--ink-4)', fontSize: 12 }}>로그인</span>
      </div>

      <div className="section" style={{ textAlign: 'center', paddingBottom: 24 }}>
        <div className="pill" style={{ marginBottom: 20 }}>TRUSTA</div>
        <h1 style={{ fontFamily: 'var(--font-sans)', fontWeight: 900, fontSize: 36,
                     letterSpacing: '-0.03em', color: 'var(--ink)', lineHeight: 1.2 }}>
          로그인
        </h1>
        <p style={{ marginTop: 12, fontSize: 15, color: 'var(--ink-3)' }}>
          계정에 로그인하여 서비스를 이용하세요.
        </p>
      </div>

      <div style={{ padding: '0 32px 64px' }}>
        <form className="form-card" onSubmit={handleSubmit}>
          <div className="field">
            <label htmlFor="email">이메일</label>
            <input id="email" type="email" autoComplete="email"
                   placeholder="brand@example.com" required
                   value={email} onChange={e => setEmail(e.target.value)} />
          </div>

          <div className="field" style={{ marginBottom: 28 }}>
            <label htmlFor="password">비밀번호</label>
            <input id="password" type="password" autoComplete="current-password"
                   placeholder="비밀번호 입력" required
                   value={password} onChange={e => setPassword(e.target.value)} />
          </div>

          {error && <div className="alert-err">{error}</div>}

          <button type="submit" className="btn btn-ink" disabled={loading}
                  style={{ marginTop: 24 }}>
            {loading ? '로그인 중…' : '로그인 →'}
          </button>

          <p style={{ textAlign: 'center', marginTop: 20, fontSize: 14, color: 'var(--ink-3)' }}>
            계정이 없으신가요?{' '}
            <Link href="/auth/signup"
                  style={{ color: 'var(--ink)', fontWeight: 700, textDecoration: 'underline' }}>
              3일 무료로 시작하기
            </Link>
          </p>
        </form>
      </div>

      {/* Footer */}
      <footer style={{ background: '#0a0a0a', color: 'var(--ink-4)', padding: '28px 32px',
                       textAlign: 'center', fontSize: 12 }}>
        <div style={{ color: 'var(--yellow)', fontWeight: 900, fontSize: 16 }}>TRUSTA</div>
        <p style={{ marginTop: 8, color: '#555', fontSize: 11 }}>© 2026 TRUSTA.</p>
      </footer>
    </>
  )
}
