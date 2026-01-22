create table if not exists public.requests (
  id uuid primary key default gen_random_uuid(),
  client_id uuid not null references auth.users(id) on delete cascade,
  caregiver_id uuid not null references public.caregivers(id) on delete cascade,
  status text not null default 'pending' check (status in ('pending','accepted','declined','completed','cancelled')),
  note text,
  created_at timestamptz not null default now()
);

alter table public.requests enable row level security;

-- Client can create own request
drop policy if exists "Client can create request" on public.requests;
create policy "Client can create request"
on public.requests for insert
to authenticated
with check (auth.uid() = client_id);

-- Client can read own requests
drop policy if exists "Client can read own requests" on public.requests;
create policy "Client can read own requests"
on public.requests for select
to authenticated
using (auth.uid() = client_id);
