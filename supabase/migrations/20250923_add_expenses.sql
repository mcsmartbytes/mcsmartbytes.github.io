-- Expenses schema for Phase 1 (Flutter app)
-- Choose dev-friendly defaults; tighten RLS later when Auth is enabled.

-- Table: expenses
CREATE TABLE IF NOT EXISTS public.expenses (
  id TEXT PRIMARY KEY,
  description TEXT NOT NULL,
  category TEXT NOT NULL,
  amount NUMERIC(10,2) NOT NULL,
  date TIMESTAMPTZ NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending',
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Optional: simple index helpers
CREATE INDEX IF NOT EXISTS idx_expenses_date ON public.expenses (date DESC);
CREATE INDEX IF NOT EXISTS idx_expenses_status ON public.expenses (status);
CREATE INDEX IF NOT EXISTS idx_expenses_category ON public.expenses (category);

-- For development, keep RLS disabled. When ready for Auth, enable RLS and add user_id.
ALTER TABLE public.expenses DISABLE ROW LEVEL SECURITY;

-- Notes for production hardening (not executed here):
-- 1) Add user ownership
--   ALTER TABLE public.expenses ADD COLUMN user_id UUID REFERENCES auth.users(id);
--   CREATE INDEX IF NOT EXISTS idx_expenses_user_date ON public.expenses (user_id, date DESC);
-- 2) Enable RLS and policies
--   ALTER TABLE public.expenses ENABLE ROW LEVEL SECURITY;
--   CREATE POLICY expenses_user_rw ON public.expenses
--     FOR ALL TO authenticated
--     USING (user_id = auth.uid())
--     WITH CHECK (user_id = auth.uid());
-- 3) Update updated_at on row changes (optional)
--   CREATE OR REPLACE FUNCTION public.set_updated_at()
--   RETURNS TRIGGER AS $$
--   BEGIN NEW.updated_at = NOW(); RETURN NEW; END; $$ LANGUAGE plpgsql;
--   DROP TRIGGER IF EXISTS set_expenses_updated_at ON public.expenses;
--   CREATE TRIGGER set_expenses_updated_at BEFORE UPDATE ON public.expenses
--     FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

