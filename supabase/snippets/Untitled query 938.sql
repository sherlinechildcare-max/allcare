cat > supabase/migrations/$(date +%Y%m%d%H%M%S)_fix_chat_threads_rls.sql <<'SQL'
-- Make sure RLS is enabled
alter table public.chat_threads enable row level security;

-- Helper: drop policy if exists (by name)
do $$
begin
  if exists (
    select 1 from pg_policies
    where schemaname='public'
      and tablename='chat_threads'
      and policyname='Client can create own chat threads'
  ) then
    drop policy "Client can create own chat threads" on public.chat_threads;
  end if;

  if exists (
    select 1 from pg_policies
    where schemaname='public'
      and tablename='chat_threads'
      and policyname='Client can read own chat threads'
  ) then
    drop policy "Client can read own chat threads" on public.chat_threads;
  end if;
end $$;

-- ✅ Assumption (matches your requests table style): chat_threads has client_user_id column
-- If your column name is different, tell me and I’ll adjust in one command.
create policy "Client can create own chat threads"
on public.chat_threads
for insert
to authenticated
with check (client_user_id = auth.uid());

create policy "Client can read own chat threads"
on public.chat_threads
for select
to authenticated
using (client_user_id = auth.uid());
SQL