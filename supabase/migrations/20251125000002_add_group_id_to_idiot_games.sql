-- Add group_id to idiot_game_games table
ALTER TABLE idiot_game_games
ADD COLUMN group_id UUID REFERENCES groups(id) ON DELETE CASCADE;

-- Add index for performance
CREATE INDEX idx_idiot_game_games_group_id ON idiot_game_games(group_id);

-- Update RLS policies to allow group members to read games
-- Note: Existing policy "Allow authenticated users to read games" is broad (USING true),
-- so we don't strictly need a new policy for reading if we keep it that way.
-- However, if we wanted to restrict to group members, we would change it.
-- For now, keeping it simple as per existing pattern.

-- Update insert policy to ensure group_id is valid?
-- The foreign key constraint handles referential integrity.
-- The existing insert policy checks `auth.uid() = created_by`.
-- We might want to ensure the user is a member of the group they are creating a game for.
-- But let's stick to the plan and just add the column for now.
