-- 1. Drop the old, problematic SELECT policy on the messages table.
drop policy "Users can view messages from chats they are members of." on public.messages;

-- 2. Create a new, corrected SELECT policy for messages.
-- This policy uses the is_chat_member function to check for membership and avoid recursion.
create policy "Users can view messages from chats they are members of."
  on public.messages for select
  using (
    public.is_chat_member(chat_id, auth.uid())
  );
