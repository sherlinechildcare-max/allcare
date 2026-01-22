-- 1. Requests table
create table if not exists public.requests (
  id uuid primary key default gen_random_uuid(),

  client_id uuid not null references auth.users(id) on delete cascade,
  caregiver_id uuid not null references public.caregivers(id) on delete cascade,

  message text,
  status text not null default 'pending'
    check (status in ('pending', 'accepted', 'rejected', 'completed')),

  created_at timestamp with time zone default now()
);

-- 2. Indexes (performance)
create index if not exists idx_requests_client_id on public.requests(client_id);
create index if not exists idx_requests_caregiver_id on public.requests(caregiver_id);
create index if not exists idx_requests_status on public.requests(status);

-- 3. Enable realtime
alter publication supabase_realtime add table public.requests;