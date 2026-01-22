-- chat_threads
alter table public.chat_threads enable row level security;

drop policy if exists "Client can create chat thread" on public.chat_threads;
create policy "Client can create chat thread"
on public.chat_threads
for insert
to authenticated
with check (
  client_user_id = auth.uid()
);

drop policy if exists "Client can read own chat threads" on public.chat_threads;
create policy "Client can read own chat threads"
on public.chat_threads
for select
to authenticated
using (
  client_user_id = auth.uid()
  or caregiver_user_id = auth.uid()
);

-- chat_messages
alter table public.chat_messages enable row level security;

drop policy if exists "Participants can send messages" on public.chat_messages;
create policy "Participants can send messages"
on public.chat_messages
for insert
to authenticated
with check (
  sender_user_id = auth.uid()
);

drop policy if exists "Participants can read messages" on public.chat_messages;
create policy "Participants can read messages"
on public.chat_messages
for select
to authenticated
using (
  sender_user_id = auth.uid()
  or receiver_user_id = auth.uid()
);