-- Cloudflare deployment metadata stored alongside website JSON (not inside published content).
alter table public.websites
  add column if not exists deployment jsonb;

create index if not exists websites_deployment_url_idx
  on public.websites ((deployment ->> 'publishedUrl'));
