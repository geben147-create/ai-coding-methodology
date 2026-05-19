'use client'
import { useEffect, useState } from 'react'
import { useRouter } from 'next/navigation'
import { createClient } from '@/lib/supabase/client'
import { checkTrialAccess } from '@/lib/trial'
import Link from 'next/link'

const RISK_WORDS: { word: string; level: 'HIGH' | 'MID' }[] = [
  { word: '피부 재생',   level: 'HIGH' },
  { word: '트러블 완화', level: 'HIGH' },
  { word: '항염 케어',   level: 'HIGH' },
  { word: '미백 효과',   level: 'HIGH' },
  { word: '피부 장벽 회복', level: 'HIGH' },
  { word: '즉각',       level: 'MID' },
  { word: '디톡스',     level: 'MID' },
  { word: '치료',       level: 'HIGH' },
  { word: '의학적',     level: 'HIGH' },
]

export default function ScannerPage() {
  const router = useRouter()
  const [loading,  setLoading]  = useState(true)
  const [text,     setText]     = useState('')
  const [results,  setResults]  = useState<{ word: string; level: 'HIGH' | 'MID'; indices: number[] }[]>([])
  const [scanned,  setScanned]  = useState(false)
  const [userEmail, setUserEmail] = useState('')

  useEffect(() => {
    async function checkAccess() {
      const supabase = createClient()
      const { data: { user } } = await supabase.auth.getUser()
      if (!user) { router.push('/auth/login'); return }

      const { allowed } = await checkTrialAccess(supabase, user.id)
      if (!allowed) { router.push('/trial-expired'); return }

      setUserEmail(user.email ?? '')
      setLoading(false)
    }
    checkAccess()
  }, [router])

  function scan() {
    const found = RISK_WORDS.filter(({ word }) => text.includes(word)).map(({ word, level }) => {
      const indices: number[] = []
      let idx = text.indexOf(word)
      while (idx !== -1) { indices.push(idx); idx = text.indexOf(word, idx + 1) }
      return { word, level, indices }
    })
    setResults(found)
    setScanned(true)
  }

  if (loading) {
    return (
      <div style={{ minHeight: '100vh', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
        <p style={{ color: 'var(--ink-3)' }}>접근 권한 확인 중…</p>
      </div>
    )
  }

  const riskScore = results.reduce((acc, r) => acc + (r.level === 'HIGH' ? 20 : 10), 0)
  const highlighted = text ? highlightText(text, results) : ''

  return (
    <>
      <div className="topbar">
        <Link href="/dashboard" className="logo">TRUSTA</Link>
        <span style={{ fontSize: 12, color: 'var(--ink-4)' }}>{userEmail}</span>
      </div>

      <div className="section" style={{ textAlign: 'center', paddingBottom: 24 }}>
        <div className="pill" style={{ marginBottom: 16 }}>RISK SCANNER</div>
        <h1 style={{ fontFamily: 'var(--font-sans)', fontWeight: 900, fontSize: 36,
                     letterSpacing: '-0.03em', color: 'var(--ink)', lineHeight: 1.2 }}>
          문구 리스크 진단
        </h1>
        <p style={{ marginTop: 12, fontSize: 15, color: 'var(--ink-3)' }}>
          화장품 문구를 붙여넣으면 고위험 표현을 분석합니다.
        </p>
      </div>

      <div style={{ padding: '0 32px 64px' }}>
        {/* 입력 */}
        <div className="form-card" style={{ marginBottom: 24 }}>
          <label style={{ fontWeight: 700, fontSize: 15, display: 'block', marginBottom: 10 }}>
            분석할 문구 입력
          </label>
          <textarea
            value={text}
            onChange={e => { setText(e.target.value); setScanned(false) }}
            placeholder="예) 피부 재생을 도와주는 크림. 트러블 완화 효과."
            rows={6}
            style={{ width: '100%', fontFamily: 'var(--font-sans)', fontSize: 15,
                     border: '2.5px solid var(--ink)', borderRadius: 12,
                     padding: '14px 16px', resize: 'vertical', outline: 'none' }}
          />
          <button onClick={scan} disabled={!text.trim()} className="btn btn-ink"
                  style={{ marginTop: 16 }}>
            리스크 분석하기 →
          </button>
        </div>

        {/* 결과 */}
        {scanned && (
          <div className="card">
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 16, marginBottom: 24 }}>
              <div style={{ background: 'var(--ink)', borderRadius: 16, padding: 20, textAlign: 'center' }}>
                <div style={{ fontSize: 11, color: 'var(--ink-4)', letterSpacing: '0.08em', fontWeight: 700 }}>RISK SCORE</div>
                <div style={{ fontWeight: 900, fontSize: 48, color: 'var(--yellow)', lineHeight: 1, marginTop: 4 }}>
                  {Math.min(riskScore, 100)}
                </div>
                <div style={{ fontSize: 13, color: 'var(--ink-4)', marginTop: 4 }}>/ 100</div>
              </div>
              <div style={{ border: '2.5px solid var(--ink)', borderRadius: 16, padding: 20 }}>
                <div style={{ fontSize: 13, color: 'var(--ink-3)', fontWeight: 700 }}>발견된 위험</div>
                <div style={{ fontWeight: 900, fontSize: 36, color: 'var(--warn-red)', lineHeight: 1, marginTop: 8 }}>
                  {results.filter(r => r.level === 'HIGH').length}
                </div>
                <div style={{ fontSize: 12, color: 'var(--ink-3)' }}>고위험 표현</div>
                <div style={{ fontWeight: 900, fontSize: 24, color: '#C99A00', lineHeight: 1, marginTop: 6 }}>
                  {results.filter(r => r.level === 'MID').length}
                </div>
                <div style={{ fontSize: 12, color: 'var(--ink-3)' }}>주의 표현</div>
              </div>
            </div>

            {results.length === 0 ? (
              <div style={{ textAlign: 'center', padding: '20px 0', color: 'var(--green)', fontWeight: 700 }}>
                ✓ 위험 표현이 발견되지 않았습니다.
              </div>
            ) : (
              <>
                <p style={{ fontSize: 12, fontWeight: 600, letterSpacing: '0.06em', color: 'var(--ink-3)', marginBottom: 12 }}>
                  발견된 위험 표현
                </p>
                {results.map(({ word, level }) => (
                  <div key={word} style={{
                    borderLeft: `4px solid ${level === 'HIGH' ? 'var(--warn-red)' : '#C99A00'}`,
                    background: 'var(--paper-2)', borderRadius: '0 12px 12px 0',
                    padding: '12px 16px', marginBottom: 10,
                    display: 'flex', justifyContent: 'space-between', alignItems: 'center',
                  }}>
                    <span style={{ fontWeight: 700 }}>&ldquo;{word}&rdquo;</span>
                    <span style={{
                      background: level === 'HIGH' ? 'var(--warn-red)' : '#C99A00',
                      color: 'white', fontSize: 11, fontWeight: 700,
                      padding: '3px 10px', borderRadius: 99,
                    }}>{level}</span>
                  </div>
                ))}
              </>
            )}

            {highlighted && (
              <div style={{ marginTop: 24, border: '2px solid var(--paper-3)', borderRadius: 12, padding: '16px 18px' }}>
                <p style={{ fontSize: 12, fontWeight: 600, color: 'var(--ink-3)', marginBottom: 10 }}>원문 (위험 표현 표시)</p>
                <p style={{ fontSize: 15, lineHeight: 1.7 }}
                   dangerouslySetInnerHTML={{ __html: highlighted }} />
              </div>
            )}
          </div>
        )}
      </div>

      <footer style={{ background: '#0a0a0a', color: 'var(--ink-4)', padding: '28px 32px',
                       textAlign: 'center', fontSize: 12 }}>
        <div style={{ color: 'var(--yellow)', fontWeight: 900, fontSize: 16 }}>TRUSTA</div>
        <p style={{ marginTop: 8, color: '#555', fontSize: 11 }}>© 2026 TRUSTA.</p>
      </footer>
    </>
  )
}

function highlightText(text: string, risks: { word: string; level: 'HIGH' | 'MID' }[]): string {
  let result = text.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
  for (const { word, level } of risks) {
    const color = level === 'HIGH' ? '#FFD9DB' : '#FFF0B8'
    const border = level === 'HIGH' ? '#E11D48' : '#C99A00'
    const safe = word.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')
    result = result.replace(
      new RegExp(safe, 'g'),
      `<mark style="background:${color};border-bottom:2px solid ${border};padding:0 2px;font-weight:700;">${word}</mark>`,
    )
  }
  return result
}
