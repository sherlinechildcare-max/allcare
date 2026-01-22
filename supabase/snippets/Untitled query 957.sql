alter table public.chat_threads
add column if not exists last_message_at timestamptz;

update public.chat_threads
set last_message_at = created_at
where last_message_at is null;