import { SupabaseClient } from '@supabase/supabase-js'

export type PlanType       = 'free_trial' | 'standard' | 'growth' | 'admin'
export type TrialStatusType = 'active' | 'expired' | 'paid'

export interface Profile {
  id: string
  email: string
  brand_name: string | null
  plan: PlanType
  trial_started_at: string
  trial_ends_at: string
  trial_status: TrialStatusType
  created_at: string
}

export interface TrialCheckResult {
  allowed: boolean
  profile: Profile | null
  reason: 'active' | 'expired' | 'paid' | 'no_profile' | 'unauthenticated'
  daysLeft: number
}

export async function checkTrialAccess(
  supabase: SupabaseClient,
  userId: string,
): Promise<TrialCheckResult> {
  const { data: profile, error } = await supabase
    .from('profiles')
    .select('*')
    .eq('id', userId)
    .single()

  if (error || !profile) {
    return { allowed: false, profile: null, reason: 'no_profile', daysLeft: 0 }
  }

  // 유료 플랜: 무조건 허용
  if (['standard', 'growth', 'admin'].includes(profile.plan)) {
    return { allowed: true, profile, reason: 'paid', daysLeft: 0 }
  }

  // 무료 체험: 만료 여부 확인
  const now      = new Date()
  const trialEnd = new Date(profile.trial_ends_at)
  const isExpired = profile.trial_status === 'expired' || now > trialEnd

  if (isExpired) {
    if (profile.trial_status !== 'expired') {
      await supabase
        .from('profiles')
        .update({ trial_status: 'expired' })
        .eq('id', userId)
    }
    return {
      allowed: false,
      profile: { ...profile, trial_status: 'expired' },
      reason: 'expired',
      daysLeft: 0,
    }
  }

  const daysLeft = Math.max(0, Math.ceil((trialEnd.getTime() - now.getTime()) / 86_400_000))
  return { allowed: true, profile, reason: 'active', daysLeft }
}

export function formatDate(iso: string): string {
  return new Date(iso).toLocaleDateString('ko-KR', {
    year: 'numeric', month: 'long', day: 'numeric',
  })
}
