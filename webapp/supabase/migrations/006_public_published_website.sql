-- Public read of published website JSON by username (for subdomain loading).
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
