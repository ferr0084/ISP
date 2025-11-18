-- 1. Create a function to check if a user is a member of a chat.
-- This is a security definer function to avoid potential recursion issues with RLS.
create or replace function public.is_chat_member(p_chat_id uuid, p_user_id uuid)
returns boolean as $$
begin
  return exists (
    select 1 from public.chat_members
    where chat_id = p_chat_id
    and user_id = p_user_id
  );
end;
$$ language plpgsql stable security definer;

-- 2. Drop the old, problematic policy on the messages table.
drop policy "Users can send messages to chats they are members of." on public.messages;

-- 3. Create a new, corrected policy for inserting messages.
-- This policy uses the is_chat_member function to check for membership.
create policy "Users can send messages to chats they are members of."
  on public.messages for insert
  with check (
    sender_id = auth.uid() and
    public.is_chat_member(chat_id, auth.uid())
  );
