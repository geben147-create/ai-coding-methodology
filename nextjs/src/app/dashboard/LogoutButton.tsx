'use client'
import { createClient } from '@/lib/supabase/client'
import { useRouter } from 'next/navigation'

export default function LogoutButton() {
  const router = useRouter()

  async function handleLogout() {
    const supabase = createClient()
    await supabase.auth.signOut()
    router.push('/auth/login')
    router.refresh()
  }

  return (
    <button onClick={handleLogout}
            style={{ background: 'none', border: 'none', color: 'var(--yellow)',
                     fontWeight: 700, fontSize: 12, cursor: 'pointer', padding: 0 }}>
      로그아웃
    </button>
  )
}
