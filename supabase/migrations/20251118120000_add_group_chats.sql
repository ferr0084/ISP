-- 1. Add chat_id to the groups table
alter table public.groups
add column chat_id uuid references public.chats(id) on delete set null;

-- Create an index for the new column
create index idx_groups_chat_id on public.groups(chat_id);

-- 2. Create a function to handle new group creation
create or replace function public.handle_new_group()
returns trigger as $$
declare
  new_chat_id uuid;
  member_id uuid;
begin
  -- Create a new chat with the group's name
  insert into public.chats (name)
  values (new.name)
  returning id into new_chat_id;

  -- Link the new chat to the group
  update public.groups
  set chat_id = new_chat_id
  where id = new.id;

  -- Add all members from the group to the chat
  if array_length(new.member_ids, 1) > 0 then
    foreach member_id in array new.member_ids
    loop
      insert into public.chat_members (chat_id, user_id)
      values (new_chat_id, member_id);
    end loop;
  end if;

  return new;
end;
$$ language plpgsql security definer;

-- 3. Create a trigger to call the function when a group is created
create trigger on_group_created
  after insert on public.groups
  for each row execute function public.handle_new_group();

-- 4. Create a function to handle group member updates
create or replace function public.handle_group_update()
returns trigger as $$
declare
  member_id uuid;
  added_members uuid[];
  removed_members uuid[];
begin
  -- Determine who was added
  select array_agg(t.member_id) into added_members
  from (select unnest(new.member_ids) as member_id except select unnest(old.member_ids)) as t;

  -- Determine who was removed
  select array_agg(t.member_id) into removed_members
  from (select unnest(old.member_ids) as member_id except select unnest(new.member_ids)) as t;

  -- Add new members to the chat
  if added_members is not null and array_length(added_members, 1) > 0 then
    foreach member_id in array added_members
    loop
      insert into public.chat_members (chat_id, user_id)
      values (new.chat_id, member_id)
      on conflict (chat_id, user_id) do nothing; -- Safely ignore if they already exist
    end loop;
  end if;

  -- Remove old members from the chat
  if removed_members is not null and array_length(removed_members, 1) > 0 then
    delete from public.chat_members
    where chat_id = new.chat_id
    and user_id = any(removed_members);
  end if;

  return new;
end;
$$ language plpgsql security definer;

-- 5. Create a trigger to call the function when group members are updated
create trigger on_group_updated
  after update of member_ids on public.groups
  for each row
  when (old.member_ids is distinct from new.member_ids)
  execute function public.handle_group_update();
