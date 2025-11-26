-- Add foreign key from idiot_game_participants.user_id to profiles.id
-- This allows PostgREST to properly join participants with their profiles

-- Since profiles.id already references auth.users.id, and participants.user_id
-- references auth.users.id, we can safely add this constraint since they're
-- logically equivalent (every user in auth.users has a profile due to the trigger)

ALTER TABLE idiot_game_participants 
ADD CONSTRAINT idiot_game_participants_user_id_profiles_fkey 
FOREIGN KEY (user_id) REFERENCES profiles(id) ON DELETE CASCADE;
