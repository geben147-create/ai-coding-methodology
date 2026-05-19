import { createServerClient } from '@supabase/ssr'
import { NextResponse } from 'next/server'
import type { NextRequest } from 'next/server'

const PROTECTED_PATHS = ['/dashboard', '/scanner']
const ADMIN_PATHS     = ['/admin']
const AUTH_PATHS      = ['/auth/login', '/auth/signup']

export async function middleware(request: NextRequest) {
  let supabaseResponse = NextResponse.next({ request })

  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() { return request.cookies.getAll() },
        setAll(cookiesToSet) {
          cookiesToSet.forEach(({ name, value }) => request.cookies.set(name, value))
          supabaseResponse = NextResponse.next({ request })
          cookiesToSet.forEach(({ name, value, options }) =>
            supabaseResponse.cookies.set(name, value, options))
        },
      },
    },
  )

  // 세션 갱신 (중요: getUser 사용)
  const { data: { user } } = await supabase.auth.getUser()
  const path = request.nextUrl.pathname

  // 이미 로그인 상태에서 auth 페이지 접근 → 대시보드로
  if (AUTH_PATHS.some(p => path.startsWith(p)) && user) {
    return NextResponse.redirect(new URL('/dashboard', request.url))
  }

  // 보호된 페이지: 비로그인 → 로그인으로
  if (PROTECTED_PATHS.some(p => path.startsWith(p)) && !user) {
    const redirectUrl = new URL('/auth/login', request.url)
    redirectUrl.searchParams.set('next', path)
    return NextResponse.redirect(redirectUrl)
  }

  // 어드민 전용 페이지
  if (ADMIN_PATHS.some(p => path.startsWith(p))) {
    if (!user) {
      return NextResponse.redirect(new URL('/auth/login', request.url))
    }
    const { data: profile } = await supabase
      .from('profiles')
      .select('plan')
      .eq('id', user.id)
      .single()
    if (!profile || profile.plan !== 'admin') {
      return NextResponse.redirect(new URL('/dashboard', request.url))
    }
  }

  return supabaseResponse
}

export const config = {
  matcher: ['/((?!_next/static|_next/image|favicon.ico|.*\\.(?:svg|png|jpg|jpeg|gif|webp)$).*)'],
}
