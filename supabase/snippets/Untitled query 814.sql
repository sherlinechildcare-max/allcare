alter table public.requests
  add column if not exists client_id uuid,
  add column if not exists caregiver_id uuid,
  add column if not exists status text default 'pending',
  add column if not exists note text,
  add column if not exists created_at timestamptz default now();
