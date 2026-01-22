-- Conversations (1 per client-caregiver pair)
create table if not exists conversations (
  id uuid primary key default gen_random_uuid(),
  client_user_id uuid not null references auth.users(id) on delete cascade,
  caregiver_id uuid not null,
  created_at timestamptz default now(),
  unique (client_user_id, caregiver_id)
);

-- Messages
create table if not exists messages (
  id uuid primary key default gen_random_uuid(),
  conversation_id uuid not null references conversations(id) on delete cascade,
  sender_id uuid not null,
  body text not null,
  read boolean default false,
  created_at timestamptz default now()
);