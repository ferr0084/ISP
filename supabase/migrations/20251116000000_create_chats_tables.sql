-- Create a table for chats
create table chats (
  id uuid not null primary key default gen_random_uuid(),
  name text, -- Optional name for group chats
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Create a table for chat members
create table chat_members (
  id uuid not null primary key default gen_random_uuid(),
  chat_id uuid references chats(id) on delete cascade not null,
  user_id uuid references profiles(id) on delete cascade not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null,
  unique(chat_id, user_id) -- Prevent duplicate memberships
);

-- Create a table for messages
create table messages (
  id uuid not null primary key default gen_random_uuid(),
  chat_id uuid references chats(id) on delete cascade not null,
  sender_id uuid references profiles(id) on delete cascade not null,
  content text not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Add indexes for better performance
create index idx_chat_members_chat_id on chat_members(chat_id);
create index idx_chat_members_user_id on chat_members(user_id);
create index idx_messages_chat_id on messages(chat_id);
create index idx_messages_sender_id on messages(sender_id);
create index idx_messages_created_at on messages(created_at);

-- Set up Row Level Security (RLS) for chats
alter table chats enable row level security;

create policy "Users can view chats they are members of."
  on chats for select
  using (
    exists (
      select 1 from chat_members
      where chat_members.chat_id = chats.id
      and chat_members.user_id = auth.uid()
    )
  );

create policy "Users can create new chats."
  on chats for insert
  with check (true); -- Allow anyone to create chats (membership will be controlled separately)

create policy "Users can update chats they are members of."
  on chats for update
  using (
    exists (
      select 1 from chat_members
      where chat_members.chat_id = chats.id
      and chat_members.user_id = auth.uid()
    )
  );

create policy "Users can delete chats they are members of."
  on chats for delete
  using (
    exists (
      select 1 from chat_members
      where chat_members.chat_id = chats.id
      and chat_members.user_id = auth.uid()
    )
  );

-- Set up Row Level Security (RLS) for chat_members
alter table chat_members enable row level security;

create policy "Users can view chat memberships for chats they are members of."
  on chat_members for select
  using (
    exists (
      select 1 from chat_members cm2
      where cm2.chat_id = chat_members.chat_id
      and cm2.user_id = auth.uid()
    )
  );

create policy "Users can add members to chats they are members of."
  on chat_members for insert
  with check (
    exists (
      select 1 from chat_members cm2
      where cm2.chat_id = chat_members.chat_id
      and cm2.user_id = auth.uid()
    )
  );

create policy "Users can update memberships for chats they are members of."
  on chat_members for update
  using (
    exists (
      select 1 from chat_members cm2
      where cm2.chat_id = chat_members.chat_id
      and cm2.user_id = auth.uid()
    )
  );

create policy "Users can remove members from chats they are members of."
  on chat_members for delete
  using (
    exists (
      select 1 from chat_members cm2
      where cm2.chat_id = chat_members.chat_id
      and cm2.user_id = auth.uid()
    )
  );

-- Set up Row Level Security (RLS) for messages
alter table messages enable row level security;

create policy "Users can view messages from chats they are members of."
  on messages for select
  using (
    exists (
      select 1 from chat_members
      where chat_members.chat_id = messages.chat_id
      and chat_members.user_id = auth.uid()
    )
  );

create policy "Users can send messages to chats they are members of."
  on messages for insert
  with check (
    sender_id = auth.uid() and
    exists (
      select 1 from chat_members
      where chat_members.chat_id = messages.chat_id
      and chat_members.user_id = auth.uid()
    )
  );

create policy "Users can update their own messages in chats they are members of."
  on messages for update
  using (
    sender_id = auth.uid() and
    exists (
      select 1 from chat_members
      where chat_members.chat_id = messages.chat_id
      and chat_members.user_id = auth.uid()
    )
  );

create policy "Users can delete their own messages in chats they are members of."
  on messages for delete
  using (
    sender_id = auth.uid() and
    exists (
      select 1 from chat_members
      where chat_members.chat_id = messages.chat_id
      and chat_members.user_id = auth.uid()
    )
  );

-- Function to automatically add chat creator as a member
create or replace function handle_new_chat()
returns trigger as $$
begin
  insert into public.chat_members (chat_id, user_id)
  values (new.id, auth.uid());
  return new;
end;
$$ language plpgsql security definer;

-- Trigger to call handle_new_chat after a new chat is created
create trigger on_chat_created
  after insert on chats
  for each row execute function handle_new_chat();

-- Create function to update updated_at timestamp
create or replace function update_updated_at_column()
returns trigger as $$
begin
  new.updated_at = timezone('utc'::text, now());
  return new;
end;
$$ language plpgsql;

-- Create triggers to automatically update updated_at
create trigger update_chats_updated_at before update on chats
  for each row execute function update_updated_at_column();

create trigger update_chat_members_updated_at before update on chat_members
  for each row execute function update_updated_at_column();

create trigger update_messages_updated_at before update on messages
  for each row execute function update_updated_at_column();