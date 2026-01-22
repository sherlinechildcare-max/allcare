-- ============================================================
-- PROFILES (Production-ready, idempotent)
-- ============================================================

-- 1) Create enum safely
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_type t
    JOIN pg_namespace n ON n.oid = t.typnamespace
    WHERE t.typname = 'user_role'
      AND n.nspname = 'public'
  ) THEN
    CREATE TYPE public.user_role AS ENUM ('client', 'caregiver', 'admin');
  END IF;
END
$$;

-- 2) Create table safely
CREATE TABLE IF NOT EXISTS public.profiles (
  id uuid REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,

  role public.user_role NOT NULL DEFAULT 'client',

  full_name text,
  phone text,
  city text,

  avatar_url text,

  onboarding_completed boolean DEFAULT false,

  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- 3) Add missing columns if table already existed (safe upgrades)
ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS role public.user_role NOT NULL DEFAULT 'client',
  ADD COLUMN IF NOT EXISTS full_name text,
  ADD COLUMN IF NOT EXISTS phone text,
  ADD COLUMN IF NOT EXISTS city text,
  ADD COLUMN IF NOT EXISTS avatar_url text,
  ADD COLUMN IF NOT EXISTS onboarding_completed boolean DEFAULT false,
  ADD COLUMN IF NOT EXISTS created_at timestamptz NOT NULL DEFAULT now(),
  ADD COLUMN IF NOT EXISTS updated_at timestamptz NOT NULL DEFAULT now();

-- 4) Enable RLS
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- 5) updated_at trigger (production best practice)
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_profiles_updated_at ON public.profiles;
CREATE TRIGGER trg_profiles_updated_at
BEFORE UPDATE ON public.profiles
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();

-- 6) Policies (drop then recreate = idempotent)
DROP POLICY IF EXISTS "Users can read own profile" ON public.profiles;
CREATE POLICY "Users can read own profile"
ON public.profiles
FOR SELECT
USING (auth.uid() = id);

DROP POLICY IF EXISTS "Users can insert own profile" ON public.profiles;
CREATE POLICY "Users can insert own profile"
ON public.profiles
FOR INSERT
WITH CHECK (auth.uid() = id);

DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;
CREATE POLICY "Users can update own profile"
ON public.profiles
FOR UPDATE
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);