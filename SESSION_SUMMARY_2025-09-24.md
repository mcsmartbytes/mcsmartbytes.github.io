Session Summary — 2025-09-24

What we set up
- Supabase backend: expenses table + migrations prepared
  - supabase/migrations/20250923_add_expenses.sql
  - supabase/migrations/20250923_expenses_user_rls.sql (adds user_id + RLS with temporary dev-open policy)
  - supabase/migrations/20250924_lockdown_expenses_rls.sql (removes dev-open; owner-only)
- Environment config: env.json (SUPABASE_URL, SUPABASE_ANON_KEY)
- App wiring
  - lib/main.dart → uses AuthGate()
  - lib/expense_app/screens/auth_gate.dart → routes login/app based on session
  - lib/expense_app/screens/login_screen.dart → email/password sign-in + sign-up
  - lib/expense_app/screens/expense_list_screen.dart → hides dev “DB test” FAB; adds Sign out
- Local run on Windows
  - Preferred path: C:\dev\expense_tracker_windows
  - Commands: flutter pub get; flutter run -d chrome --dart-define-from-file=env.json
  - UNC alternative via CMD pushd if needed
- Deployment
  - GitHub Pages workflow: .github/workflows/deploy-pages.yml
  - Cloudflare Pages workflow: .github/workflows/deploy-cloudflare.yml
  - SPA routing: web/404.html (kept in repo)

Tomorrow quick start
1) Copy the files listed in COPY_CHECKLIST.txt into your Windows repo
2) Supabase SQL → run migrations in order:
   - 20250923_add_expenses.sql
   - 20250923_expenses_user_rls.sql
   - 20250924_lockdown_expenses_rls.sql
3) Run locally:
   - cd C:\dev\expense_tracker_windows
   - flutter pub get
   - flutter run -d chrome --dart-define-from-file=env.json
4) Deploy (GitHub Pages):
   - git add -A && git commit -m "Auth + RLS + deploy"
   - git push
   - Repo Settings → Pages → ensure GitHub Actions
5) Or deploy (Cloudflare):
   - Set GitHub secrets: CLOUDFLARE_API_TOKEN, CLOUDFLARE_ACCOUNT_ID
   - Set variable: CF_PAGES_PROJECT_NAME
   - Push to main

Notes
- Old rows without user_id aren’t visible after RLS lockdown; backfill if needed.
- Avoid committing secrets; env.json is used at build time only.

