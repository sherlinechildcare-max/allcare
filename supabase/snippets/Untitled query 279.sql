-- Enable UUID helper
create extension if not exists pgcrypto;

-- 1) Threads table
create table if not exists public.chat_threads (
  id uuid primary key default gen_random_uuid(),
  client_user_id uuid not null references auth.users(id) on delete cascade,
  caregiver_id uuid not null references public.caregivers(id) on delete cascade,
  created_at timestamptz not null default now(),
  last_message_at timestamptz
);

-- one thread per client<->caregiver pair
do $$
begin
  if not exists (
    select 1
    from pg_indexes
    where schemaname = 'public'
      and indexname = 'chat_threads_client_caregiver_unique'
  ) then
    execute 'create unique index chat_threads_client_caregiver_unique
             on public.chat_threads (client_user_id, caregiver_id)';
  end if;
end $$;

-- 2) Messages table
create table if not exists public.chat_messages (
  id uuid primary key default gen_random_uuid(),
  thread_id uuid not null references public.chat_threads(id) on delete cascade,
  sender_user_id uuid not null references auth.users(id) on delete cascade,
  body text not null,
  created_at timestamptz not null default now(),
  read_at timestamptz
);

create index if not exists chat_messages_thread_created_idx
  on public.chat_messages(thread_id, created_at);

-- 3) RLS ON
alter table public.chat_threads enable row level security;
alter table public.chat_messages enable row level security;

-- 4) Policies (idempotent with DO blocks)
do $$
begin
  -- THREADS: client can select their threads
  if not exists (
    select 1 from pg_policies
    where schemaname='public' and tablename='chat_threads' and policyname='client_select_own_threads'
  ) then
    execute $p$
      create policy client_select_own_threads
      on public.chat_threads
      for select
      to authenticated
      using (client_user_id = auth.uid())
    $p$;
  end if;

  -- THREADS: client can insert their thread rows
  if not exists (
    select 1 from pg_policies
    where schemaname='public' and tablename='chat_threads' and policyname='client_insert_own_threads'
  ) then
    execute $p$
      create policy client_insert_own_threads
      on public.chat_threads
      for insert
      to authenticated
      with check (client_user_id = auth.uid())
    $p$;
  end if;

  -- MESSAGES: client can select messages in threads they belong to
  if not exists (
    select 1 from pg_policies
    where schemaname='public' and tablename='chat_messages' and policyname='client_select_messages_in_own_threads'
  ) then
    execute $p$
      create policy client_select_messages_in_own_threads
      on public.chat_messages
      for select
      to authenticated
      using (
        exists (
          select 1 from public.chat_threads t
          where t.id = chat_messages.thread_id
            and t.client_user_id = auth.uid()
        )
      )
    $p$;
  end if;

  -- MESSAGES: client can insert messages only in their threads, and sender_user_id must be them
  if not exists (
    select 1 from pg_policies
    where schemaname='public' and tablename='chat_messages' and policyname='client_insert_messages_in_own_threads'
  ) then
    execute $p$
      create policy client_insert_messages_in_own_threads
      on public.chat_messages
      for insert
      to authenticated
      with check (
        sender_user_id = auth.uid()
        and exists (
          select 1 from public.chat_threads t
          where t.id = chat_messages.thread_id
            and t.client_user_id = auth.uid()
        )
      )
    $p$;
  end if;

  -- OPTIONAL: client can mark read_at on messages in their threads (only update read_at)
  if not exists (
    select 1 from pg_policies
    where schemaname='public' and tablename='chat_messages' and policyname='client_update_read_receipts'
  ) then
    execute $p$
      create policy client_update_read_receipts
      on public.chat_messages
      for update
      to authenticated
      using (
        exists (
          select 1 from public.chat_threads t
          where t.id = chat_messages.thread_id
            and t.client_user_id = auth.uid()
        )
      )
      with check (
        exists (
          select 1 from public.chat_threads t
          where t.id = chat_messages.thread_id
            and t.client_user_id = auth.uid()
        )
      )
    $p$;
  end if;
end $$;

-- 5) Realtime: add tables only if not already present
do $$
begin
  if not exists (
    select 1
    from pg_publication_tables
    where pubname='supabase_realtime'
      and schemaname='public'
      and tablename='chat_threads'
  ) then
    execute 'alter publication supabase_realtime add table public.chat_threads';
  end if;

  if not exists (
    select 1
    from pg_publication_tables
    where pubname='supabase_realtime'
      and schemaname='public'
      and tablename='chat_messages'
  ) then
    execute 'alter publication supabase_realtime add table public.chat_messages';
  end if;
end $$;