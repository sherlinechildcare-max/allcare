-- Agency application status
create type public.application_status as enum ('pending', 'approved', 'rejected');

-- Agency applications table
create table public.agency_applications (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  agency_name text not null,
  phone text,
  email text,
  website text,
  license_number text,
  address text,
  status public.application_status not null default 'pending',
  created_at timestamptz not null default now(),
  reviewed_at timestamptz,
  reviewed_by uuid references auth.users(id)
);

alter table public.agency_applications enable row level security;

-- Applicants can insert their own application
create policy "Applicant can create application"
on public.agency_applications
for insert
with check (auth.uid() = owner_id);

-- Applicants can read their own application
create policy "Applicant can read own application"
on public.agency_applications
for select
using (auth.uid() = owner_id);

-- Applicants can update their application while pending
create policy "Applicant can update pending application"
on public.agency_applications
for update
using (auth.uid() = owner_id and status = 'pending')
with check (auth.uid() = owner_id and status = 'pending');
