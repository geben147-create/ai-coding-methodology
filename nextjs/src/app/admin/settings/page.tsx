import { redirect } from 'next/navigation'
import { createClient } from '@/lib/supabase/server'
import AdminSettingsClient from './AdminSettingsClient'

export default async function AdminSettingsPage() {
  const supabase = await createClient()
  const { data: { user } } = await supabase.auth.getUser()

  if (!user) redirect('/auth/login')

  // admin 권한 확인 (middleware 에서도 막지만 이중 방어)
  const { data: profile } = await supabase
    .from('profiles')
    .select('plan')
    .eq('id', user.id)
    .single()

  if (!profile || profile.plan !== 'admin') redirect('/dashboard')

  // 현재 settings 조회
  const { data: settings } = await supabase
    .from('settings')
    .select('*')
    .order('key')

  return <AdminSettingsClient initialSettings={settings ?? []} userEmail={user.email ?? ''} />
}
