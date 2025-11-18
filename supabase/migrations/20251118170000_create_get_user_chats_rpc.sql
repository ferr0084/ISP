create or replace function public.get_user_chats()
returns table (
  id uuid,
  name text,
  created_at timestamptz,
  updated_at timestamptz
) as $$
begin
  return query
  select
    c.id,
    c.name,
    c.created_at,
    c.updated_at
  from
    public.chats c
  join
    public.chat_members cm on c.id = cm.chat_id
  where
    cm.user_id = auth.uid()
  order by
    c.updated_at desc;
end;
$$ language plpgsql stable;
