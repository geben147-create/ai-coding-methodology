import { NextResponse } from 'next/server'
import { createClient } from '@/lib/supabase/server'
import { checkTrialAccess } from '@/lib/trial'

// 서버 사이드 무료체험 체크 API
// GET /api/trial/check
export async function GET() {
  const supabase = await createClient()
  const { data: { user }, error: authError } = await supabase.auth.getUser()

  if (authError || !user) {
    return NextResponse.json(
      { allowed: false, reason: 'unauthenticated' },
      { status: 401 },
    )
  }

  const result = await checkTrialAccess(supabase, user.id)
  return NextResponse.json(result, { status: result.allowed ? 200 : 403 })
}
