-- =========================================
-- FIX PROFILES SCHEMA (id = auth.users.id)
-- =========================================

-- Ensure columns exist
alter table public.profiles
  add column if not exists role text check (role in ('client','caregiver','agency')),
  add column if not exists onboarding_completed boolean not null default false;

-- Ensure profiles.id is the auth user id
-- (Many templates already do this. If yours already does, these are safe.)
alter table public.profiles
  alter column id set not null;

-- Helpful index (id is usually already PK, but this is harmless)
create unique index if not exists profiles_id_unique on public.profiles(id);

-- =========================================
-- RLS
-- =========================================
alter table public.profiles enable row level security;

drop policy if exists "User can read own profile" on public.profiles;
drop policy if exists "User can create own profile" on public.profiles;
drop policy if exists "User can update own profile" on public.profiles;

create policy "User can read own profile"
on public.profiles
for select
using (auth.uid() = id);

create policy "User can create own profile"
on public.profiles
for insert
with check (auth.uid() = id);

create policy "User can update own profile"
on public.profiles
for update
using (auth.uid() = id);

-- =========================================
-- AUTO-CREATE PROFILE ON SIGNUP
-- =========================================
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
as $$
begin
  insert into public.profiles (id)
  values (new.id)
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;

create trigger on_auth_user_created
after insert on auth.users
for each row
execute procedure public.handle_new_user();
