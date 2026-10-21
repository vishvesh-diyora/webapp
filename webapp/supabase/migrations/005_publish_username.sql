-- Globally unique publish usernames (stored in deployment.projectName).
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
