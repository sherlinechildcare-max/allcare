-- =========================================
-- PHASE 2 CORE TABLES: caregivers, requests, chat
-- =========================================

-- caregivers public directory (minimal MVP)
create table if not exists public.caregivers (
  id uuid primary key default gen_random_uuid(),
  user_id uuid unique, -- optional link to auth user if caregiver is a user
  full_name text not null,
  title text,
  rate_per_hour numeric,
  city text,
  verified boolean default false,
  bio text,
  created_at timestamptz default now()
);

-- requests between client and caregiver
create table if not exists public.requests (
  id uuid primary key default gen_random_uuid(),
  client_user_id uuid not null,
  caregiver_id uuid not null references public.caregivers(id) on delete cascade,
  status text not null default 'pending'
    check (status in ('pending','accepted','declined','cancelled','completed')),
  requested_date date,
  notes text,
  created_at timestamptz default now()
);

create index if not exists requests_client_idx on public.requests(client_user_id);
create index if not exists requests_caregiver_idx on public.requests(caregiver_id);

-- chat threads: 1 thread per (client_user_id, caregiver_id)
create table if not exists public.chat_threads (
  id uuid primary key default gen_random_uuid(),
  client_user_id uuid not null,
  caregiver_id uuid not null references public.caregivers(id) on delete cascade,
  created_at timestamptz default now(),
  unique (client_user_id, caregiver_id)
);

create index if not exists chat_threads_client_idx on public.chat_threads(client_user_id);
create index if not exists chat_threads_caregiver_idx on public.chat_threads(caregiver_id);

-- messages in a thread
create table if not exists public.chat_messages (
  id uuid primary key default gen_random_uuid(),
  thread_id uuid not null references public.chat_threads(id) on delete cascade,
  sender_user_id uuid not null,
  body text not null,
  created_at timestamptz default now()
);

create index if not exists chat_messages_thread_idx on public.chat_messages(thread_id);

-- =========================================
-- ROW LEVEL SECURITY
-- =========================================
alter table public.caregivers enable row level security;
alter table public.requests enable row level security;
alter table public.chat_threads enable row level security;
alter table public.chat_messages enable row level security;

-- caregivers directory is readable by everyone (app users)
drop policy if exists "Caregivers are readable" on public.caregivers;
create policy "Caregivers are readable"
on public.caregivers
for select
using (true);

-- caregiver can update their own caregiver row (if linked)
drop policy if exists "Caregiver can update own row" on public.caregivers;
create policy "Caregiver can update own row"
on public.caregivers
for update
using (auth.uid() = user_id);

-- requests:
-- client can create request for themselves
drop policy if exists "Client can create request" on public.requests;
create policy "Client can create request"
on public.requests
for insert
with check (auth.uid() = client_user_id);

-- client can read their own requests
drop policy if exists "Client can read own requests" on public.requests;
create policy "Client can read own requests"
on public.requests
for select
using (auth.uid() = client_user_id);

-- caregiver can read requests tied to them (if caregivers.user_id matches auth.uid)
drop policy if exists "Caregiver can read own requests" on public.requests;
create policy "Caregiver can read own requests"
on public.requests
for select
using (
  exists (
    select 1 from public.caregivers c
    where c.id = requests.caregiver_id
      and c.user_id = auth.uid()
  )
);

-- caregiver can update request status for their own requests
drop policy if exists "Caregiver can update request status" on public.requests;
create policy "Caregiver can update request status"
on public.requests
for update
using (
  exists (
    select 1 from public.caregivers c
    where c.id = requests.caregiver_id
      and c.user_id = auth.uid()
  )
);

-- chat threads:
-- client can create thread for themselves
drop policy if exists "Client can create thread" on public.chat_threads;
create policy "Client can create thread"
on public.chat_threads
for insert
with check (auth.uid() = client_user_id);

-- client can read own threads
drop policy if exists "Client can read own threads" on public.chat_threads;
create policy "Client can read own threads"
on public.chat_threads
for select
using (auth.uid() = client_user_id);

-- caregiver can read their threads (if linked)
drop policy if exists "Caregiver can read own threads" on public.chat_threads;
create policy "Caregiver can read own threads"
on public.chat_threads
for select
using (
  exists (
    select 1 from public.caregivers c
    where c.id = chat_threads.caregiver_id
      and c.user_id = auth.uid()
  )
);

-- chat messages:
-- Only participants can read messages
drop policy if exists "Participants can read messages" on public.chat_messages;
create policy "Participants can read messages"
on public.chat_messages
for select
using (
  exists (
    select 1 from public.chat_threads t
    left join public.caregivers c on c.id = t.caregiver_id
    where t.id = chat_messages.thread_id
      and (t.client_user_id = auth.uid() or c.user_id = auth.uid())
  )
);

-- Only participants can insert messages (sender must be auth.uid)
drop policy if exists "Participants can send messages" on public.chat_messages;
create policy "Participants can send messages"
on public.chat_messages
for insert
with check (
  sender_user_id = auth.uid()
  and exists (
    select 1 from public.chat_threads t
    left join public.caregivers c on c.id = t.caregiver_id
    where t.id = chat_messages.thread_id
      and (t.client_user_id = auth.uid() or c.user_id = auth.uid())
  )
);
