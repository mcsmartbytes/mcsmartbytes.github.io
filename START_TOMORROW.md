Start Tomorrow Plan

Goals
- Verify live deployment on GitHub Pages
- Enable Supabase RLS + basic auth (optional)
- Prepare Android build (emulator/device)

Checklist
- [ ] Push latest repo changes (workflow + SPA routing)
- [ ] GitHub → Settings → Pages → ensure GitHub Actions is selected
- [ ] Confirm Actions workflow completes successfully
- [ ] Open the live site URL and add an expense
- [ ] In Supabase, confirm the expense row is created
- [ ] (Optional) Hide dev-only features in UI (already hidden)

Security Hardening (RLS + Auth)
- [ ] In Supabase SQL Editor, run: supabase/migrations/20250923_expenses_user_rls.sql
- [ ] Add email/password sign-in UI (basic) and persist session
- [ ] On insert, set user_id from auth session
- [ ] Verify policies: users see only their rows

Android (Optional Tomorrow)
- [ ] Open project in Android Studio
- [ ] Create run config with args: --dart-define-from-file=env.json
- [ ] Run on emulator or device and test CRUD

Notes
- GitHub Pages builds from repo root via .github/workflows/deploy-pages.yml
- SPA routing: web/404.html handles deep links
- env.json must exist at repo root for CI build
