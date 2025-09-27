Deployment Options

Goal: host the Flutter Web app backed by Supabase, and keep Android builds for device testing.

Prerequisites
- Supabase project with tables migrated.
- Flutter SDK installed locally for manual builds.
- Update env.json with your Supabase URL and anon key.

Supabase
1) Create a project at https://app.supabase.com and copy the Project URL and anon key.
2) Apply migrations (SQL Editor):
   - supabase/migrations/20250923_add_expenses.sql
   - supabase/migrations/20250923_expenses_user_rls.sql (optional for now; enables RLS)
3) For quick testing, you can keep RLS disabled (first migration does this). Enable RLS later for production.

Local Run (Web)
- cd project/expense_tracker_windows
- flutter pub get
- flutter run -d chrome --dart-define-from-file=env.json

Local Run (Android)
- Open folder project/expense_tracker_windows in Android Studio
- Ensure an emulator or device is available
- Run with additional arguments: --dart-define-from-file=env.json

GitHub Pages (Recommended Free Hosting)
Pros: free, reliable, simple for static sites.

We’ve added a workflow that builds and deploys Flutter Web to GitHub Pages automatically.

Steps:
1) Push this repository to GitHub.
2) In GitHub → Settings → Pages:
   - Build and deployment: GitHub Actions
3) Ensure your default branch is main (or master). The workflow is at .github/workflows/deploy-pages.yml.
4) Optional: Set repository variable PAGES_BASE_HREF if needed
   - For project pages (default): leave unset; it will use "/<repo>/"
   - For custom domain or user/org pages: set to "/"
5) Push to main; the action will:
   - Install Flutter
   - Build web with env.json
   - Publish to GitHub Pages
6) The site URL will appear in the workflow output (Settings → Pages).

SPA Routing
- For GitHub Pages, web/404.html is included to redirect all routes to index.html.

Cloudflare Pages (Alternative)
Pros: generous free tier. Two approaches:
1) Prebuild and upload
   - flutter build web --dart-define-from-file=env.json
   - In Cloudflare Pages, create a project → Direct Upload → upload build/web contents.
2) Connect to Git and build on Cloudflare
   - Requires installing Flutter in the build image (custom build command). Simpler to prebuild and upload.

Vercel (Alternative)
- Possible but requires installing Flutter during build or prebuilding locally and serving static output. If you prefer Vercel, prebuild locally and deploy the build/web folder using vercel’s static project flow.

Security Notes
- Supabase anon key is public by design in browser apps.
- For production: enable RLS and add user authentication; set user_id on insert.

Troubleshooting
- Blank page after deploy: clear cache or ensure 404.html exists (for GitHub Pages) to support SPA routing.
- Supabase errors: verify env.json values match your project and that migrations created public.expenses.
