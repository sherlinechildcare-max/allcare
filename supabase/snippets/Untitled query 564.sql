alter table public.chat_threads enable row level security;
alter table public.chat_messages enable row level security;

-- CHAT_THREADS POLICIES
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

-- CHAT_MESSAGES POLICIES
drop policy if exists "Client can insert chat message" on public.chat_messages;
create policy "Client can insert chat message"
on public.chat_messages
for insert
to authenticated
with check (sender_user_id = auth.uid());

drop policy if exists "Client can read chat messages for own threads" on public.chat_messages;
create policy "Client can read chat messages for own threads"
on public.chat_messages
for select
to authenticated
using (
  exists (
    select 1
    from public.chat_threads t
    where t.id = chat_messages.thread_id
      and t.client_user_id = auth.uid()
  )
);

select pg_notify('pgrst', 'reload schema');