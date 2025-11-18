create or replace view public.messages_with_sender as
  select
    m.*,
    p.full_name as sender_name,
    p.avatar_url as sender_avatar
  from
    public.messages m
  join
    public.profiles p on m.sender_id = p.id;
