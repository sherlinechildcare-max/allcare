-- PROFILES: add the missing columns we want (safe to re-run)
alter table public.profiles
add column if not exists phone text,
add column if not exists address text,
add column if not exists state text,
add column if not exists country text,
add column if not exists date_of_birth date,
add column if not exists gender text,
add column if not exists emergency_contact_name text,
add column if not exists emergency_contact_phone text,
add column if not exists allergies text,
add column if not exists medical_notes text,
add column if not exists preferred_language text,
add column if not exists time_zone text,
add column if not exists updated_at timestamptz default now();

-- auto-update updated_at
create or replace function public.set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end $$;

drop trigger if exists trg_profiles_updated_at on public.profiles;
create trigger trg_profiles_updated_at
before update on public.profiles
for each row execute function public.set_updated_at();

-- reload schema cache
select pg_notify('pgrst', 'reload schema');