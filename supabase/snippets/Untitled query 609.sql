-- Enable RLS
alter table public.requests enable row level security;

-- Client can see their own requests
create policy "Client can read own requests"
on public.requests
for select
using (auth.uid() = client_id);

-- Client can create requests
create policy "Client can create requests"
on public.requests
for insert
with check (auth.uid() = client_id);

-- Caregiver can read requests sent to them
create policy "Caregiver can read assigned requests"
on public.requests
for select
using (auth.uid() = caregiver_id);

-- Caregiver can update status
create policy "Caregiver can update request status"
on public.requests
for update
using (auth.uid() = caregiver_id);