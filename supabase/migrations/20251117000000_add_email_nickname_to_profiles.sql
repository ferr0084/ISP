-- Add email and nickname columns to profiles table
ALTER TABLE profiles ADD COLUMN email text;
ALTER TABLE profiles ADD COLUMN nickname text;

-- Update RLS policies to allow users to update their email and nickname
-- (The existing policies should already cover this since they allow updates to own profile)

-- Optionally, you could populate existing profiles with email from auth.users
-- But this would require a more complex migration with a function