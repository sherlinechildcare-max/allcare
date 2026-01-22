alter table public.profiles
add column if not exists phone text;

-- optional but recommended: reload PostgREST schema cache
select pg_notify('pgrst', 'reload schema');