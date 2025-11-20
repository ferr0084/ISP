-- Drop custom_title column from profiles table since we're consolidating on nickname
ALTER TABLE profiles DROP COLUMN IF EXISTS custom_title;
