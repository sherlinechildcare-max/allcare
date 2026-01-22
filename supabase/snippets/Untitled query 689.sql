-- PROFILES TABLE (safe)
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  role text not null default 'client',
  full_name text,
  phone text,
  city text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists trg_profiles_updated_at on public.profiles;
create trigger trg_profiles_updated_at
before update on public.profiles
for each row execute function public.set_updated_at();

alter table public.profiles enable row level security;

drop policy if exists "Users can read own profile" on public.profiles;
create policy "Users can read own profile"
on public.profiles
for select
to authenticated
using (id = auth.uid());

drop policy if exists "Users can upsert own profile" on public.profiles;
create policy "Users can upsert own profile"
on public.profiles
for insert
to authenticated
with check (id = auth.uid());

drop policy if exists "Users can update own profile" on public.profiles;
create policy "Users can update own profile"
on public.profiles
for update
to authenticated
using (id = auth.uid())
with check (id = auth.uid());


-- ACCOUNT DELETION REQUESTS (client-safe, production)
create table if not exists public.account_deletion_requests (
  id bigserial primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  email text,
  reason text,
  status text not null default 'pending',
  created_at timestamptz not null default now()
);

alter table public.account_deletion_requests enable row level security;

drop policy if exists "Users can create deletion request" on public.account_deletion_requests;
create policy "Users can create deletion request"
on public.account_deletion_requests
for insert
to authenticated
with check (user_id = auth.uid());

drop policy if exists "Users can read own deletion request" on public.account_deletion_requests;
create policy "Users can read own deletion request"
on public.account_deletion_requests
for select
to authenticated
using (user_id = auth.uid());