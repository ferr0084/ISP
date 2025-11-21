-- 1. Create players table
CREATE TABLE idiot_game_players (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    name TEXT NOT NULL,
    avatar_url TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- RLS for players
ALTER TABLE idiot_game_players ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow authenticated users to read players" ON idiot_game_players FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow users to insert their own player profile" ON idiot_game_players FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Allow users to update their own player profile" ON idiot_game_players FOR UPDATE USING (auth.uid() = user_id);

-- 2. Create games table
CREATE TABLE idiot_game_games (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    game_date TIMESTAMPTZ NOT NULL,
    created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- RLS for games
ALTER TABLE idiot_game_games ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow authenticated users to read games" ON idiot_game_games FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow users to insert games" ON idiot_game_games FOR INSERT WITH CHECK (auth.uid() = created_by);
CREATE POLICY "Allow creator to update/delete games" ON idiot_game_games FOR ALL USING (auth.uid() = created_by);


-- 3. Create game_participants linking table
CREATE TABLE idiot_game_participants (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    game_id UUID NOT NULL REFERENCES idiot_game_games(id) ON DELETE CASCADE,
    player_id UUID NOT NULL REFERENCES idiot_game_players(id) ON DELETE CASCADE,
    is_loser BOOLEAN NOT NULL DEFAULT false,
    UNIQUE(game_id, player_id)
);

-- RLS for participants
ALTER TABLE idiot_game_participants ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow authenticated users to read participants" ON idiot_game_participants FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow users to insert participants for games they created" ON idiot_game_participants FOR INSERT WITH CHECK (
    EXISTS (
        SELECT 1
        FROM idiot_game_games
        WHERE id = game_id AND created_by = auth.uid()
    )
);
CREATE POLICY "Allow users to update/delete participants for games they created" ON idiot_game_participants FOR ALL USING (
    EXISTS (
        SELECT 1
        FROM idiot_game_games
        WHERE id = game_id AND created_by = auth.uid()
    )
);


-- 4. Create achievements table
CREATE TABLE idiot_game_achievements (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    description TEXT NOT NULL,
    icon_name TEXT NOT NULL
);

-- RLS for achievements
ALTER TABLE idiot_game_achievements ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow any user to read achievements" ON idiot_game_achievements FOR SELECT USING (true);


-- 5. Create player_achievements table
CREATE TABLE idiot_game_player_achievements (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    player_id UUID NOT NULL REFERENCES idiot_game_players(id) ON DELETE CASCADE,
    achievement_id INTEGER NOT NULL REFERENCES idiot_game_achievements(id) ON DELETE CASCADE,
    unlocked_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(player_id, achievement_id)
);

-- RLS for player_achievements
ALTER TABLE idiot_game_player_achievements ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow users to view any player achievements" ON idiot_game_player_achievements FOR SELECT TO authenticated USING (true);

-- Seed the achievements table
INSERT INTO idiot_game_achievements (name, description, icon_name) VALUES
('Idiot King', 'Become the idiot the most times.', 'idiot_king'),
('Survivor', 'Avoid being the idiot for 10 consecutive games.', 'survivor'),
('Comeback Kid', 'Win a game immediately after being the idiot.', 'comeback_kid'),
('Flawless Victory', 'Win a game without losing a single round (if applicable).', 'flawless_victory'),
('The Collector', 'Collect all other achievements.', 'the_collector'),
('Century Club', 'Play 100 games.', 'century_club');
