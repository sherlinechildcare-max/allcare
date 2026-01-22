-- 1) Create bucket
insert into storage.buckets (id, name, public)
values ('avatars', 'avatars', true)
on conflict (id) do update set public = true;

-- 2) Policies on storage.objects
-- Public read for avatars (so profile pics show)
drop policy if exists "Public can read avatars" on storage.objects;
create policy "Public can read avatars"
on storage.objects
for select
to public
using (bucket_id = 'avatars');

-- Only the owner can upload/update/delete their own files
-- Path rule: avatars/<auth.uid()>/...
drop policy if exists "Users can upload own avatar" on storage.objects;
create policy "Users can upload own avatar"
on storage.objects
for insert
to authenticated
with check (
  bucket_id = 'avatars'
  and (storage.foldername(name))[1] = auth.uid()::text
);

drop policy if exists "Users can update own avatar" on storage.objects;
create policy "Users can update own avatar"
on storage.objects
for update
to authenticated
using (
  bucket_id = 'avatars'
  and (storage.foldername(name))[1] = auth.uid()::text
)
with check (
  bucket_id = 'avatars'
  and (storage.foldername(name))[1] = auth.uid()::text
);

drop policy if exists "Users can delete own avatar" on storage.objects;
create policy "Users can delete own avatar"
on storage.objects
for delete
to authenticated
using (
  bucket_id = 'avatars'
  and (storage.foldername(name))[1] = auth.uid()::text
);