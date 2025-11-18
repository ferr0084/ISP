create or replace function public.get_latest_messages_with_sender(p_chat_id uuid)
returns table (
  id uuid,
  chat_id uuid,
  sender_id uuid,
  content text,
  created_at timestamptz,
  updated_at timestamptz,
  sender_name text,
  sender_avatar text
) as $$
begin
  return query
  select
    m.id,
    m.chat_id,
    m.sender_id,
    m.content,
    m.created_at,
    m.updated_at,
    m.sender_name,
    m.sender_avatar
  from
    public.messages_with_sender m
  where
    m.chat_id = p_chat_id
  order by
    m.created_at desc
  limit 3;
end;
$$ language plpgsql stable;
