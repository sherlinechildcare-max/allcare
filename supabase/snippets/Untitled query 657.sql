-- 1) Ensure column exists
alter table if exists public.chat_threads
add column if not exists last_message_at timestamptz not null default now();

-- 2) Function to bump last_message_at when a message is inserted
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

-- 3) Trigger on chat_messages
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

-- 4) Refresh API schema cache (fixes "schema cache" errors)
select pg_notify('pgrst', 'reload schema');