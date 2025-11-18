-- Update the function to handle duplicate members during group creation
create or replace function public.handle_new_group()
returns trigger as $$
declare
  new_chat_id uuid;
begin
  -- Create a new chat with the group's name
  insert into public.chats (name)
  values (new.name)
  returning id into new_chat_id;

  -- Link the new chat to the group
  update public.groups
  set chat_id = new_chat_id
  where id = new.id;

  -- Add all members from the group to the chat, ignoring duplicates
  if array_length(new.member_ids, 1) > 0 then
    insert into public.chat_members (chat_id, user_id)
    select new_chat_id, unnest(new.member_ids)
    on conflict (chat_id, user_id) do nothing;
  end if;

  return new;
end;
$$ language plpgsql security definer;
