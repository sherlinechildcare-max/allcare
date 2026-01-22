cat > supabase/migrations/$(date +%Y%m%d%H%M%S)_fix_chat_threads_last_message.sql <<'SQL'
-- 1) Add last_message_at to chat_threads if missing
do $$
begin
  if not exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'chat_threads'
      and column_name = 'last_message_at'
  ) then
    alter table public.chat_threads
      add column last_message_at timestamptz not null default now();
  end if;
end $$;

-- 2) Ensure chat_messages has created_at (needed for trigger)
do $$
begin
  if exists (
    select 1 from information_schema.tables
    where table_schema='public' and table_name='chat_messages'
  ) then
    if not exists (
      select 1
      from information_schema.columns
      where table_schema='public'
        and table_name='chat_messages'
        and column_name='created_at'
    ) then
      alter table public.chat_messages
        add column created_at timestamptz not null default now();
    end if;
  end if;
end $$;

-- 3) Trigger: whenever a message is inserted, bump chat_threads.last_message_at
create or replace function public.bump_thread_last_message_at()
returns trigger
language plpgsql
as $$
begin
  update public.chat_threads
  set last_message_at = greatest(coalesce(last_message_at, 'epoch'::timestamptz), new.created_at)
  where id = new.thread_id;
  return new;
end;
$$;

do $$
begin
  if exists (
    select 1 from information_schema.tables
    where table_schema='public' and table_name='chat_messages'
  ) then
    if exists (select 1 from pg_trigger where tgname = 'trg_bump_thread_last_message_at') then
      drop trigger trg_bump_thread_last_message_at on public.chat_messages;
    end if;

    create trigger trg_bump_thread_last_message_at
    after insert on public.chat_messages
    for each row execute function public.bump_thread_last_message_at();
  end if;
end $$;
SQL