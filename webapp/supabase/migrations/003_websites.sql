-- Website JSON records for the builder app (not used by published static sites).
create table if not exists public.websites (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  content jsonb not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists websites_user_id_idx on public.websites (user_id);

alter table public.websites enable row level security;

create policy "Users can read own websites"
  on public.websites for select
  using (auth.uid() = user_id);

create policy "Users can insert own websites"
  on public.websites for insert
  with check (auth.uid() = user_id);

create policy "Users can update own websites"
  on public.websites for update
  using (auth.uid() = user_id);

create policy "Users can delete own websites"
  on public.websites for delete
  using (auth.uid() = user_id);
