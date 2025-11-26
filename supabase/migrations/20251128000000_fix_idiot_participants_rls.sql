-- Fix RLS policies for idiot_game_participants to reference the correct table name after rename

-- Drop old policies that reference the old table name
DROP POLICY IF EXISTS "Allow authenticated users to read participants" ON idiot_game_participants;
DROP POLICY IF EXISTS "Allow users to insert participants for games they created" ON idiot_game_participants;
DROP POLICY IF EXISTS "Allow users to update/delete participants for games they created" ON idiot_game_participants;

-- Recreate policies with correct table reference
CREATE POLICY "Allow authenticated users to read participants" ON idiot_game_participants FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow users to insert participants for games they created" ON idiot_game_participants FOR INSERT WITH CHECK (
    EXISTS (
        SELECT 1
        FROM idiot_games
        WHERE id = game_id AND created_by = auth.uid()
    )
);
CREATE POLICY "Allow users to update/delete participants for games they created" ON idiot_game_participants FOR ALL USING (
    EXISTS (
        SELECT 1
        FROM idiot_games
        WHERE id = game_id AND created_by = auth.uid()
    )
);