alter table conversations enable row level security;
alter table messages enable row level security;

-- Conversations
create policy "Users access own conversations"
on conversations
for select
using (
  auth.uid() = client_user_id
  or auth.uid() = caregiver_id
);

-- Messages read
create policy "Users read messages"
on messages
for select
using (
  exists (
    select 1 from conversations c
    where c.id = messages.conversation_id
    and (c.client_user_id = auth.uid() or c.caregiver_id = auth.uid())
  )
);

-- Messages send
create policy "Users send messages"
on messages
for insert
with check (
  sender_id = auth.uid()
);