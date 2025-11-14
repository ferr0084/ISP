-- Create a table for groups
create table groups (
  id uuid not null primary key,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  name text not null,
  avatar_url text,
  member_ids uuid[] not null,
  last_message text,
  "time" timestamp with time zone not null,
  unread_count integer
);

-- Set up Row Level Security (RLS)
alter table groups enable row level security;

create policy "Users can view groups they are a member of."
  on groups for select
  using (auth.uid() = ANY(member_ids));

create policy "Users can create new groups."
  on groups for insert
  with check (auth.uid() = ANY(member_ids)); -- The creator must be a member

create policy "Users can update groups they are a member of."
  on groups for update
  using (auth.uid() = ANY(member_ids));

create policy "Users can delete groups they are a member of."
  on groups for delete
  using (auth.uid() = ANY(member_ids));
