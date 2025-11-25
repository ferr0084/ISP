-- Simplify idiot game schema and fix table names for easier use
-- This migration:
-- 1. Renames tables to match code expectations
-- 2. Simplifies participants table to directly reference user_id instead of player_id

-- Step 1: Rename idiot_game_games to idiot_games
ALTER TABLE idiot_game_games RENAME TO idiot_games;

-- Step 2: Rename idiot_game_achievements to idiot_achievements  
ALTER TABLE idiot_game_achievements RENAME TO idiot_achievements;

-- Step 3: Rename idiot_game_player_achievements to idiot_user_achievements
ALTER TABLE idiot_game_player_achievements RENAME TO idiot_user_achievements;

-- Step 4: Update idiot_game_participants to use user_id instead of player_id
-- First, drop the foreign key constraint on player_id
ALTER TABLE idiot_game_participants DROP CONSTRAINT idiot_game_participants_player_id_fkey;

-- Add user_id column
ALTER TABLE idiot_game_participants ADD COLUMN user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE;

-- Migrate data from player_id to user_id by joining with idiot_game_players
UPDATE idiot_game_participants p
SET user_id = (
    SELECT user_id 
    FROM idiot_game_players 
    WHERE id = p.player_id
);

-- Make user_id NOT NULL
ALTER TABLE idiot_game_participants ALTER COLUMN user_id SET NOT NULL;

-- Drop player_id column
ALTER TABLE idiot_game_participants DROP COLUMN player_id;

-- Update unique constraint to use user_id instead of player_id
ALTER TABLE idiot_game_participants DROP CONSTRAINT idiot_game_participants_game_id_player_id_key;
ALTER TABLE idiot_game_participants ADD CONSTRAINT idiot_game_participants_game_id_user_id_key UNIQUE(game_id, user_id);

-- Step 5: Update the RLS policies to reference the renamed tables
-- Drop old policies on idiot_game_games that reference the old table name
DROP POLICY IF EXISTS "Allow authenticated users to read games" ON idiot_games;
DROP POLICY IF EXISTS "Allow users to insert games" ON idiot_games;
DROP POLICY IF EXISTS "Allow creator to update/delete games" ON idiot_games;

-- Recreate policies with same logic but on renamed table
CREATE POLICY "Allow authenticated users to read games" ON idiot_games FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow users to insert games" ON idiot_games FOR INSERT WITH CHECK (auth.uid() = created_by);
CREATE POLICY "Allow creator to update/delete games" ON idiot_games FOR ALL USING (auth.uid() = created_by);

-- Update achievements policies
DROP POLICY IF EXISTS "Allow any user to read achievements" ON idiot_achievements;
CREATE POLICY "Allow any user to read achievements" ON idiot_achievements FOR SELECT USING (true);

-- Update user achievements policies (player_id becomes user_id in references)
DROP POLICY IF EXISTS "Allow users to view any player achievements" ON idiot_user_achievements;
CREATE POLICY "Allow users to view any user achievements" ON idiot_user_achievements FOR SELECT TO authenticated USING (true);

-- Step 6: Update foreign key references in renamed tables
-- Update idiot_user_achievements to reference updated participant structure
ALTER TABLE idiot_user_achievements DROP CONSTRAINT idiot_game_player_achievements_player_id_fkey;
ALTER TABLE idiot_user_achievements RENAME COLUMN player_id TO user_id;
ALTER TABLE idiot_user_achievements ADD CONSTRAINT idiot_user_achievements_user_id_fkey 
    FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;

-- Update unique constraint on idiot_user_achievements
ALTER TABLE idiot_user_achievements DROP CONSTRAINT idiot_game_player_achievements_player_id_achievement_id_key;
ALTER TABLE idiot_user_achievements ADD CONSTRAINT idiot_user_achievements_user_id_achievement_id_key 
    UNIQUE(user_id, achievement_id);

-- Rename achievement FK for consistency
ALTER TABLE idiot_user_achievements DROP CONSTRAINT idiot_game_player_achievements_achievement_id_fkey;
ALTER TABLE idiot_user_achievements ADD CONSTRAINT idiot_user_achievements_achievement_id_fkey
    FOREIGN KEY (achievement_id) REFERENCES idiot_achievements(id) ON DELETE CASCADE;

-- Step 7: Update index names
DROP INDEX IF EXISTS idx_idiot_game_games_group_id;
CREATE INDEX idx_idiot_games_group_id ON idiot_games(group_id);
