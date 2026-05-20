// config.js — Supabase client configuration for the static HTML demo.
//
// To go live:
//   1. Open Supabase project → Settings → API
//   2. Copy "Project URL" and "anon public" key
//   3. Replace the placeholder values below.
//
// For Next.js production (trusta-preview.vercel.app), set env vars instead:
//   NEXT_PUBLIC_SUPABASE_URL      = https://YOUR-PROJECT.supabase.co
//   NEXT_PUBLIC_SUPABASE_ANON_KEY = eyJhbGciOi...

window.__TRUSTA__ = {
  // ★ REPLACE BEFORE GOING LIVE ★
  SUPABASE_URL:      "https://YOUR-PROJECT-REF.supabase.co",
  SUPABASE_ANON_KEY: "YOUR-ANON-PUBLIC-KEY",

  SOURCE:        "landing_main_cta",
  THANK_YOU_URL: "thank-you.html",
};
