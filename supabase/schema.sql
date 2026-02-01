-- ROLES
create table if not exists public.roles (
  name text primary key
);

insert into public.roles (name) values
('owner'),
('admin'),
('moderator'),
('user'),
('parent')
on conflict do nothing;


-- USERS
create table if not exists public.users (
  id uuid primary key references auth.users(id) on delete cascade,
  email text not null unique,
  role text not null default 'user',
  banned boolean default false,
  created_at timestamptz default now()
);


-- OWNER AUTO ASSIGN
create or replace function public.assign_user_role()
returns trigger
language plpgsql
security definer
as $$
begin
  if new.email = 'pajaziti.leon97080@gmail.com' then
    insert into public.users (id, email, role)
    values (new.id, new.email, 'owner');
  else
    insert into public.users (id, email, role)
    values (new.id, new.email, 'user');
  end if;
  return new;
end;
$$;


drop trigger if exists on_auth_user_created on auth.users;

create trigger on_auth_user_created
after insert on auth.users
for each row
execute procedure public.assign_user_role();


-- RLS
alter table public.users enable row level security;


-- OWNER FULL ACCESS
create policy "owner_full_access"
on public.users
for all
using (
  exists (
    select 1 from public.users
    where id = auth.uid()
    and role = 'owner'
  )
);


-- USER SELF READ
create policy "user_self_read"
on public.users
for select
using (id = auth.uid());


-- PREVENT OWNER BAN / DOWNGRADE
create policy "prevent_owner_modification"
on public.users
for update
using (
  role != 'owner'
  or exists (
    select 1 from public.users
    where id = auth.uid()
    and role = 'owner'
  )
);
