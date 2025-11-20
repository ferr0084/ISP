-- Add new fields to profiles table for enhanced profile features
-- ALTER TABLE profiles ADD COLUMN avatar_url text;
ALTER TABLE profiles ADD COLUMN about text;
ALTER TABLE profiles ADD COLUMN custom_title text;
ALTER TABLE profiles ADD COLUMN badges jsonb;
ALTER TABLE profiles ADD COLUMN stats jsonb;
ALTER TABLE profiles ADD COLUMN notification_preferences jsonb;

-- Add comments for clarity
-- COMMENT ON COLUMN profiles.avatar_url IS 'URL of the user avatar image';
COMMENT ON COLUMN profiles.about IS 'User biography or about section';
COMMENT ON COLUMN profiles.custom_title IS 'Custom user-defined title or role';
COMMENT ON COLUMN profiles.badges IS 'List of achievement badges as JSON array of strings';
COMMENT ON COLUMN profiles.stats IS 'Personal statistics as JSON object (e.g., games played, win/loss ratio)';
COMMENT ON COLUMN profiles.notification_preferences IS 'User notification settings as JSON object (e.g., email, push notifications)';