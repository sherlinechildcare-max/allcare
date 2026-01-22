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