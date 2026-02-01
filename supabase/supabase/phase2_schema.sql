-- USERS ERWEITERN
alter table public.users
add column if not exists username text unique,
add column if not exists birthdate date,
add column if not exists parent_email text,
add column if not exists parent_verified boolean default false,
add column if not exists profile_image_url text,
add column if not exists region text not null default 'unknown',
add column if not exists city text,
add column if not exists online_status boolean default true,
add column if not exists read_receipts boolean default true,
add column if not exists last_seen timestamptz,
add column if not exists strikes integer default 0,
add column if not exists account_status text default 'active',
add column if not exists ban_reason text,
add column if not exists last_ip text,
add column if not exists vpn_detected boolean default false,
add column if not exists last_active_at timestamptz;


-- CHATS
create table if not exists public.chats (
  id uuid primary key default gen_random_uuid(),
  user_a uuid references public.users(id) on delete cascade,
  user_b uuid references public.users(id) on delete cascade,
  created_at timestamptz default now(),
  unique (user_a, user_b)
);


-- MESSAGES
create table if not exists public.messages (
  id uuid primary key default gen_random_uuid(),
  chat_id uuid references public.chats(id) on delete cascade,
  sender_id uuid references public.users(id),
  content text,
  deleted boolean default false,
  created_at timestamptz default now()
);
