-- Run this ONCE in Supabase Dashboard → SQL Editor → New query → Run
-- Creates everything needed for website saving + publish username checks.

-- ── 1) Websites table (migration 003) ────────────────────────────────────────
create table if not exists public.websites (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  content jsonb not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists websites_user_id_idx on public.websites (user_id);

alter table public.websites enable row level security;

drop policy if exists "Users can read own websites" on public.websites;
create policy "Users can read own websites"
  on public.websites for select
  using (auth.uid() = user_id);

drop policy if exists "Users can insert own websites" on public.websites;
create policy "Users can insert own websites"
  on public.websites for insert
  with check (auth.uid() = user_id);

drop policy if exists "Users can update own websites" on public.websites;
create policy "Users can update own websites"
  on public.websites for update
  using (auth.uid() = user_id);

drop policy if exists "Users can delete own websites" on public.websites;
create policy "Users can delete own websites"
  on public.websites for delete
  using (auth.uid() = user_id);

-- ── 2) Deployment column (migration 004) ───────────────────────────────────
alter table public.websites
  add column if not exists deployment jsonb;

create index if not exists websites_deployment_url_idx
  on public.websites ((deployment ->> 'publishedUrl'));

-- ── 3) Publish username check (migration 005) ──────────────────────────────
create unique index if not exists websites_deployment_username_unique
  on public.websites (lower((deployment ->> 'projectName')))
  where deployment is not null
    and coalesce(deployment ->> 'projectName', '') <> '';

create or replace function public.is_publish_username_available(
  p_username text,
  p_website_id uuid default null
)
returns boolean
language sql
security definer
set search_path = public
as $$
  select not exists (
    select 1
    from public.websites
    where deployment is not null
      and lower(deployment ->> 'projectName') = lower(trim(p_username))
      and (p_website_id is null or id <> p_website_id)
  );
$$;

grant execute on function public.is_publish_username_available(text, uuid) to authenticated;

-- Public read for published sites (subdomain JSON loading)
create or replace function public.get_website_by_publish_username(p_username text)
returns jsonb
language sql
security definer
set search_path = public
as $$
  select content
  from public.websites
  where deployment is not null
    and lower(deployment ->> 'projectName') = lower(trim(p_username))
  limit 1;
$$;

grant execute on function public.get_website_by_publish_username(text) to anon;
grant execute on function public.get_website_by_publish_username(text) to authenticated;

notify pgrst, 'reload schema';
