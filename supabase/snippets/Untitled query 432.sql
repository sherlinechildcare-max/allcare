alter table storage.objects enable row level security;

drop policy if exists "avatars read" on storage.objects;
create policy "avatars read"
on storage.objects for select
to public
using (bucket_id = 'avatars');

drop policy if exists "avatars upload own" on storage.objects;
create policy "avatars upload own"
on storage.objects for insert
to authenticated
with check (
  bucket_id = 'avatars'
  and (storage.foldername(name))[1] = auth.uid()::text
);

drop policy if exists "avatars update own" on storage.objects;
create policy "avatars update own"
on storage.objects for update
to authenticated
using (
  bucket_id = 'avatars'
  and (storage.foldername(name))[1] = auth.uid()::text
)
with check (
  bucket_id = 'avatars'
  and (storage.foldername(name))[1] = auth.uid()::text
);