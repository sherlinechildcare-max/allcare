-- 1. Ensure profiles table exists correctly
CREATE TABLE IF NOT EXISTS public.profiles (
  id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  role text DEFAULT 'client',
  onboarding_completed boolean DEFAULT false,
  created_at timestamptz DEFAULT now()
);

-- 2. Make sure no column is blocking inserts
ALTER TABLE public.profiles
  ALTER COLUMN role DROP NOT NULL,
  ALTER COLUMN onboarding_completed DROP NOT NULL;

-- 3. Recreate auth trigger safely
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user();

CREATE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  INSERT INTO public.profiles (id)
  VALUES (NEW.id)
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$;

CREATE TRIGGER on_auth_user_created
AFTER INSERT ON auth.users
FOR EACH ROW
EXECUTE FUNCTION public.handle_new_user();