-- Drop the old, recursive policies on the chat_members table.
drop policy "Users can view chat memberships for chats they are members of." on public.chat_members;
drop policy "Users can add members to chats they are members of." on public.chat_members;
drop policy "Users can update memberships for chats they are members of." on public.chat_members;
drop policy "Users can remove members from chats they are members of." on public.chat_members;


-- Create new, corrected policies for chat_members that avoid recursion.

-- A user can see all members of a chat if they are also a member of that chat.
create policy "Users can view chat memberships for chats they are members of."
  on public.chat_members for select
  using (
    chat_id in (
      select chat_id from public.chat_members where user_id = auth.uid()
    )
  );

-- A user can add a new member to a chat if they are already a member of that chat.
create policy "Users can add members to chats they are members of."
  on public.chat_members for insert
  with check (
    chat_id in (
      select chat_id from public.chat_members where user_id = auth.uid()
    )
  );

-- A user can update a membership in a chat if they are a member of that chat.
create policy "Users can update memberships for chats they are members of."
  on public.chat_members for update
  using (
    chat_id in (
      select chat_id from public.chat_members where user_id = auth.uid()
    )
  );

-- A user can remove a member from a chat if they are a member of that chat.
create policy "Users can remove members from chats they are members of."
  on public.chat_members for delete
  using (
    chat_id in (
      select chat_id from public.chat_members where user_id = auth.uid()
    )
  );
