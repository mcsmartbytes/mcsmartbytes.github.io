-- Add user ownership and basic RLS to expenses (dev-friendly)

-- 1) Add user_id for ownership (nullable for existing/dev data)
ALTER TABLE public.expenses
  ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id);

-- 2) Function to auto-set user_id on insert when missing
CREATE OR REPLACE FUNCTION public.set_expense_user_id()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.user_id IS NULL THEN
    NEW.user_id = auth.uid();
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3) Function to maintain updated_at
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 4) Triggers
DROP TRIGGER IF EXISTS trg_expenses_set_user_id ON public.expenses;
CREATE TRIGGER trg_expenses_set_user_id
  BEFORE INSERT ON public.expenses
  FOR EACH ROW EXECUTE FUNCTION public.set_expense_user_id();

DROP TRIGGER IF EXISTS trg_expenses_updated_at ON public.expenses;
CREATE TRIGGER trg_expenses_updated_at
  BEFORE UPDATE ON public.expenses
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- 5) Enable RLS and add policies
ALTER TABLE public.expenses ENABLE ROW LEVEL SECURITY;

-- Basic owner policy for authenticated users
DROP POLICY IF EXISTS expenses_user_rw ON public.expenses;
CREATE POLICY expenses_user_rw
  ON public.expenses
  FOR ALL
  TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

-- Dev-only open policy for anon to keep current flows working without Auth
-- Remove this policy once authentication is in place
DROP POLICY IF EXISTS dev_open_access ON public.expenses;
CREATE POLICY dev_open_access
  ON public.expenses
  FOR ALL
  TO anon
  USING (true)
  WITH CHECK (true);

-- Helpful composite index when user ownership is used
CREATE INDEX IF NOT EXISTS idx_expenses_user_date ON public.expenses (user_id, date DESC);

