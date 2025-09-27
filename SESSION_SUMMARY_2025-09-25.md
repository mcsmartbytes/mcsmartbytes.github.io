Session Plan — 2025-09-25

Focus
- Finish live deployment (GitHub Pages or Cloudflare)
- Enable/verify Supabase Auth + RLS end‑to‑end
- Optional: first analytics widget; Android Studio run

Carry‑over Context
- Frontend: Flutter web app with email/password auth (AuthGate/Login).
- Backend: Supabase expenses table; migrations prepared for RLS lockdown.
- Deploy: GitHub Pages and Cloudflare Pages CI workflows added.

Pre‑flight Checklist
- [ ] env.json has SUPABASE_URL and SUPABASE_ANON_KEY
- [ ] Migrations run in order (in SQL Editor):
      1) 20250923_add_expenses.sql
      2) 20250923_expenses_user_rls.sql
      3) 20250924_lockdown_expenses_rls.sql
- [ ] web/404.html is committed for SPA routing

GitHub Pages
1) Push main to trigger CI
   - git add -A && git commit -m "Deploy Pages" && git push
2) Repo → Settings → Pages → ensure GitHub Actions is selected
3) Open the URL (Pages settings). Sign up/in and verify CRUD.

Cloudflare Pages (optional CI)
1) Repo secrets (Settings → Actions → Secrets):
   - CLOUDFLARE_API_TOKEN, CLOUDFLARE_ACCOUNT_ID
   - Variable: CF_PAGES_PROJECT_NAME
2) Push to main → workflow publishes build/web
3) Open Pages URL; sign in and verify CRUD.

Auth + RLS Validation
- [ ] Sign up/in from the live site
- [ ] Create expense → verify row has user_id in Supabase
- [ ] Sign out → rows hidden
- [ ] (Optional) Backfill legacy rows with your user_id if needed

Android (optional)
1) Android Studio → open project
2) Run args: --dart-define-from-file=env.json
3) Build & test CRUD on emulator/device

Stretch Goals
- [ ] Add a simple bar chart on Analytics tab (spend by category)
- [ ] Add receipt upload (Supabase Storage) placeholder
- [ ] Export CSV draft (current month)

Handy Commands
- flutter pub get
- flutter run -d chrome --dart-define-from-file=env.json
- flutter build web --release --dart-define-from-file=env.json

Key Files
- lib/main.dart, lib/expense_app/screens/(auth_gate.dart, login_screen.dart, expense_list_screen.dart)
- supabase/migrations/* (including lockdown)
- .github/workflows/(deploy-pages.yml, deploy-cloudflare.yml)
- web/404.html

