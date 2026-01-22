alter table public.requests enable row level security;

drop policy if exists "Client can create request" on public.requests;
create policy "Client can create request"
on public.requests for insert
to authenticated
with check (auth.uid() = client_id);

drop policy if exists "Client can read own requests" on public.requests;
create policy "Client can read own requests"
on public.requests for select
to authenticated
using (auth.uid() = client_id);