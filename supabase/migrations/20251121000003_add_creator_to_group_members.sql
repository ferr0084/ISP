-- Update the handle_new_group trigger to add the creator to group_members table
-- This replaces the deprecated member_ids column behavior

create or replace function public.handle_new_group()
returns trigger as $$
declare
  new_chat_id uuid;
  creator_id uuid;
begin
  -- Get the authenticated user ID (the creator)
  creator_id := auth.uid();
  
  -- Create a new chat with the group's name
  insert into public.chats (name)
  values (new.name)
  returning id into new_chat_id;

  -- Link the new chat to the group
  update public.groups
  set chat_id = new_chat_id
  where id = new.id;

  -- Add the creator to the group_members table with admin role
  if creator_id is not null then
    insert into public.group_members (group_id, user_id, role)
    values (new.id, creator_id, 'admin');
  end if;

  -- Add the creator to the chat_members table
  if creator_id is not null then
    insert into public.chat_members (chat_id, user_id)
    values (new_chat_id, creator_id)
    on conflict (chat_id, user_id) do nothing;
  end if;

  return new;
end;
$$ language plpgsql security definer;
