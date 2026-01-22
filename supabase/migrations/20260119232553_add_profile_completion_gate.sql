-- =========================================
-- PROFILES TABLE (ROLE + ONBOARDING GATE)
-- =========================================

alter table public.profiles
add column if not exists role text
  check (role in ('client', 'caregiver', 'agency')),
add column if not exists onboarding_completed boolean default false;

-- =========================================
-- ENSURE ONE PROFILE PER AUTH USER
-- profiles.id === auth.users.id
-- =========================================

create unique index if not exists profiles_id_unique
on public.profiles(id);

-- =========================================
-- ROW LEVEL SECURITY
-- =========================================

alter table public.profiles enable row level security;

-- Users can read their own profile
create policy "User can read own profile"
on public.profiles
for select
using (auth.uid() = id);

-- Users can insert their own profile
create policy "User can create own profile"
on public.profiles
for insert
with check (auth.uid() = id);

-- Users can update their own profile
create policy "User can update own profile"
on public.profiles
for update
using (auth.uid() = id);

-- =========================================
-- AUTO-CREATE PROFILE ON SIGNUP
-- =========================================

create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id)
  values (new.id)
  on conflict do nothing;
  return new;
end;
$$ language plpgsql security definer;

drop trigger if exists on_auth_user_created on auth.users;

create trigger on_auth_user_created
after insert on auth.users
for each row
execute procedure public.handle_new_user();