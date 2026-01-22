do $$
begin
  -- client_id -> auth.users(id)
  if not exists (
    select 1 from pg_constraint
    where conname = 'requests_client_id_fkey'
  ) then
    alter table public.requests
      add constraint requests_client_id_fkey
      foreign key (client_id) references auth.users(id) on delete cascade;
  end if;

  -- caregiver_id -> public.caregivers(id)
  if not exists (
    select 1 from pg_constraint
    where conname = 'requests_caregiver_id_fkey'
  ) then
    alter table public.requests
      add constraint requests_caregiver_id_fkey
      foreign key (caregiver_id) references public.caregivers(id) on delete cascade;
  end if;
end $$;