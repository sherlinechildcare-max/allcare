alter table public.requests
  alter column client_id set not null,
  alter column caregiver_id set not null;