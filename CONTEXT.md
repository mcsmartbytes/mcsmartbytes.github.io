Project Context (Living Doc)

Current State
- Frontend: Flutter app with Supabase-backed expenses and email/password auth.
- Default screen: AuthGate → Login → Expense list after sign-in.
- RLS: Migrations provided; lockdown migration enforces owner-only access when applied.
- Deploy: GitHub Pages and Cloudflare Pages workflows ready.

Decisions
- Use Supabase as backend; anon key in env.json for web builds (RLS provides row security).
- Keep web/404.html in repo for SPA routing on GitHub Pages.
- Hide dev-only DB test button on production builds.

Key Files
- env.json (runtime configuration via --dart-define-from-file)
- lib/main.dart, lib/expense_app/screens/* (AuthGate, LoginScreen, ExpenseList)
- supabase/migrations/* (table, RLS, lockdown)
- .github/workflows/deploy-pages.yml (GitHub Pages)
- .github/workflows/deploy-cloudflare.yml (Cloudflare Pages)

Next Milestones
- Apply RLS lockdown and confirm per-user data isolation.
- Add analytics charts (fl_chart or charts_flutter) under the Analytics tab.
- Optional: receipts via Supabase Storage.

How to Continue a Session
- Use START_TOMORROW.md for immediate tasks.
- Use SESSION_SUMMARY_YYYY-MM-DD.md per day for concise logs.
- Keep this CONTEXT.md updated with major decisions/config.

