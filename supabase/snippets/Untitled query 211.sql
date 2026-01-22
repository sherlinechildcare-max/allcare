alter table public.profiles
add column if not exists phone text;

-- optional: keep profile updates tracked
alter table public.profiles
add column if not exists updated_at timestamptz default now();

create or replace function public.set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end $$;

drop trigger if exists trg_profiles_updated_at on public.profiles;
create trigger trg_profiles_updated_at
before update on public.profiles
for each row execute function public.set_updated_at();