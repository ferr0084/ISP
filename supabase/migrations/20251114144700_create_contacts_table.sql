-- Create a table for contacts
create table contacts (
  id uuid not null primary key default gen_random_uuid(),
  user_id uuid references profiles(id) on delete cascade not null,
  contact_id uuid references profiles(id) on delete cascade not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  unique (user_id, contact_id)
);

-- Set up Row Level Security (RLS)
alter table contacts enable row level security;

create policy "Users can view their own contacts."
  on contacts for select
  using (auth.uid() = user_id);

create policy "Users can insert their own contacts."
  on contacts for insert
  with check (auth.uid() = user_id);

create policy "Users can delete their own contacts."
  on contacts for delete
  using (auth.uid() = user_id);
