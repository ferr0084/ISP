create or replace function public.get_recent_chats()
returns table (
  chat_id uuid,
  chat_name text,
  last_message_content text,
  last_message_created_at timestamptz,
  sender_id uuid,
  sender_name text,
  sender_avatar_url text,
  unread_count bigint
) as $$
begin
  return query
  with ranked_messages as (
    select
      m.chat_id,
      m.content,
      m.created_at,
      m.sender_id,
      row_number() over(partition by m.chat_id order by m.created_at desc) as rn
    from
      messages m
    join
      chat_members cm on m.chat_id = cm.chat_id
    where
      cm.user_id = auth.uid()
  ),
  unread_counts as (
    select
      mr.chat_id,
      count(*) as unread_count
    from
      message_recipients mr
    where
      mr.user_id = auth.uid() and mr.read_at is null
    group by
      mr.chat_id
  )
  select
    uc.id as chat_id,
    uc.name as chat_name,
    rm.content as last_message_content,
    rm.created_at as last_message_created_at,
    p.id as sender_id,
    p.full_name as sender_name,
    p.avatar_url as sender_avatar_url,
    coalesce(ucn.unread_count, 0) as unread_count
  from
    user_chats uc
  join
    ranked_messages rm on uc.id = rm.chat_id
  join
    profiles p on rm.sender_id = p.id
  left join
    unread_counts ucn on uc.id = ucn.chat_id
  where
    rm.rn = 1
  order by
    rm.created_at desc;
end;
$$ language plpgsql stable;