create or replace view public.user_chats as
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
    cm.user_id = auth.uid();
