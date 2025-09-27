Supabase Auth + RLS Setup

Overview
The app now includes a simple email/password sign-in screen. Once signed in, all expense operations run under your Supabase session. When Row Level Security (RLS) is enabled, users can only read/write their own expenses.

Steps
1) Supabase migrations (SQL Editor):
   - Run: supabase/migrations/20250923_add_expenses.sql
   - Run: supabase/migrations/20250923_expenses_user_rls.sql
     - Adds user_id, triggers to set user_id and updated_at, enables RLS, and temporarily allows anon access.
   - Run: supabase/migrations/20250924_lockdown_expenses_rls.sql
     - Removes the temporary dev-open policy. From now on, only authenticated users can access their rows.
   - Optional: Backfill existing rows to your account
     - Open: supabase/migrations/20250925_backfill_expenses_user_id.sql
     - Replace the placeholder email with your Supabase auth email
     - Run it once to assign user_id for all previously NULL rows

2) App configuration:
   - Ensure env.json has SUPABASE_URL and SUPABASE_ANON_KEY.
   - Run the app (web or Android). You’ll see a Sign In screen.

3) Sign in / Sign up:
   - Enter email + password.
   - Sign Up will send a confirmation email if your Supabase project requires it.
   - After confirming and signing in, the app automatically routes to the expense list.

4) Data ownership:
   - New inserts automatically set user_id = auth.uid() (trigger).
   - Queries automatically filter by user_id due to RLS.

Notes
- If you previously inserted data without user_id, those rows won’t be visible after lockdown. You can backfill user_id for your account if needed.
- For testing without Auth, skip the lockdown migration; but do not deploy publicly in that state.
