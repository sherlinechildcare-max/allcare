-- Fix: chat_threads.last_message_at missing + RLS blocks inserts

-- 1) Ensure columns exist
alter table if exists public.chat_threads
  add column if not exists last_message_at timestamptz;

update public.chat_threads
set last_message_at = coalesce(last_message_at, created_at, now())
where last_message_at is null;

alter table public.chat_threads
  alter column last_message_at set default now();

-- 2) RLS ON (safe)
alter table if exists public.chat_threads enable row level security;
alter table if exists public.chat_messages enable row level security;

-- 3) Helper function: is client in thread
create or replace function public.is_client_in_thread(tid uuid)
returns boolean
language sql
stable
as $$
  select exists(
    select 1
    from public.chat_threads t
    where t.id = tid
      and t.client_user_id = auth.uid()
  );
$$;

-- 4) Policies (drop then create so re-running is safe)

-- chat_threads
drop policy if exists "Client can create chat thread" on public.chat_threads;
create policy "Client can create chat thread"
on public.chat_threads
for insert
to authenticated
with check (client_user_id = auth.uid());

drop policy if exists "Client can read own chat threads" on public.chat_threads;
create policy "Client can read own chat threads"
on public.chat_threads
for select
to authenticated
using (client_user_id = auth.uid());

drop policy if exists "Client can update own chat threads" on public.chat_threads;
create policy "Client can update own chat threads"
on public.chat_threads
for update
to authenticated
using (client_user_id = auth.uid())
with check (client_user_id = auth.uid());

-- chat_messages
drop policy if exists "Client can read messages in own threads" on public.chat_messages;
create policy "Client can read messages in own threads"
on public.chat_messages
for select
to authenticated
using (public.is_client_in_thread(thread_id));

drop policy if exists "Client can send message in own threads" on public.chat_messages;
create policy "Client can send message in own threads"
on public.chat_messages
for insert
to authenticated
with check (
  sender_user_id = auth.uid()
  and public.is_client_in_thread(thread_id)
);

-- 5) Trigger: bump last_message_at when a message is inserted
create or replace function public.bump_thread_last_message_at()
returns trigger
language plpgsql
as $$
begin
  update public.chat_threads
  set last_message_at = now()
  where id = new.thread_id;
  return new;
end;
$$;

do $$
begin
  if exists (
    select 1 from pg_trigger where tgname = 'trg_bump_thread_last_message_at'
  ) then
    drop trigger trg_bump_thread_last_message_at on public.chat_messages;
  end if;

  create trigger trg_bump_thread_last_message_at
  after insert on public.chat_messages
  for each row execute function public.bump_thread_last_message_at();
end $$;

-- 6) Realtime (safe if already added)
alter publication supabase_realtime add table public.chat_threads;
alter publication supabase_realtime add table public.chat_messages;
