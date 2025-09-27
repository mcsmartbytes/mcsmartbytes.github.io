-- Lock down expenses RLS: remove dev open access and require ownership

-- Ensure RLS is enabled
ALTER TABLE public.expenses ENABLE ROW LEVEL SECURITY;

-- Drop dev-only open policy (if present)
DROP POLICY IF EXISTS dev_open_access ON public.expenses;

-- Ensure owner policy exists
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE schemaname = 'public' AND tablename = 'expenses' AND policyname = 'expenses_user_rw'
  ) THEN
    CREATE POLICY expenses_user_rw
      ON public.expenses
      FOR ALL
      TO authenticated
      USING (user_id = auth.uid())
      WITH CHECK (user_id = auth.uid());
  END IF;
END $$;

-- Helpful index (idempotent)
CREATE INDEX IF NOT EXISTS idx_expenses_user_date ON public.expenses (user_id, date DESC);

