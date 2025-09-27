-- Backfill user_id on existing expenses for a specific account
--
-- How to use (run in Supabase SQL editor):
-- 1) Replace the placeholder email below with the email of the account
--    you will use to sign in from the app.
-- 2) Run this script once. It will set user_id on any rows where it is NULL.
-- 3) Verify results with the SELECT at the bottom.
--
-- Notes:
-- - This script looks up the user's UUID from auth.users by email.
-- - It is idempotent (safe to re-run); only NULL user_id rows are updated.
-- - RLS is bypassed in the SQL editor, so updates will succeed even if
--   policies require ownership.

DO $$
DECLARE
  v_email text := 'replace-with-your-email@example.com'; -- TODO: set your email
  v_uid uuid;
  v_updated bigint := 0;
BEGIN
  -- Find the user's UUID by email (latest if duplicates)
  SELECT id INTO v_uid
  FROM auth.users
  WHERE email = v_email
  ORDER BY created_at DESC
  LIMIT 1;

  IF v_uid IS NULL THEN
    RAISE EXCEPTION 'No auth.users row found for email=%', v_email;
  END IF;

  -- Backfill only rows missing user_id
  UPDATE public.expenses e
  SET user_id = v_uid
  WHERE e.user_id IS NULL;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Backfilled % expenses rows with user_id=% (email=%)', v_updated, v_uid, v_email;
END $$;

-- Quick checks
-- Show a sample of remaining rows (should be zero after backfill)
SELECT id, description, date FROM public.expenses WHERE user_id IS NULL LIMIT 25;

-- Count by user after backfill
SELECT user_id, COUNT(*) AS cnt
FROM public.expenses
GROUP BY user_id
ORDER BY cnt DESC;

