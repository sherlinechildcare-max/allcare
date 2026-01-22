drop trigger if exists trg_bump_thread_last_message_at on public.chat_messages;

create trigger trg_bump_thread_last_message_at
after insert on public.chat_messages
for each row
execute function public.bump_thread_last_message_at();