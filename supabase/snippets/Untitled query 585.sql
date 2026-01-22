-- ===============================
-- FIX PROFILES PRIMARY ID LOGIC
-- ===============================

-- Ensure id exists and is primary
alter table public.profiles
add column if not exists id uuid references auth.users(id);

-- Unique index on id
create unique index if not exists profiles_id_unique
on public.profiles(id);

-- ===============================
-- FIX RLS POLICIES
-- ===============================

drop policy if exists "User can read own profile" on public.profiles;
drop policy if exists "User can create own profile" on public.profiles;
drop policy if exists "User can update own profile" on public.profiles;

alter table public.profiles enable row level security;

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