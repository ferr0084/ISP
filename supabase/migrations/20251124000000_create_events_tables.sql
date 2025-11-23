-- Create events table
CREATE TABLE events (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    date TIMESTAMPTZ NOT NULL,
    location TEXT,
    creator_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE events ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "Users can view events they created or are invited to" ON events
    FOR SELECT USING (
        creator_id = auth.uid() OR
        EXISTS (
            SELECT 1 FROM event_invitations
            WHERE event_id = events.id AND invitee_id = auth.uid()
        )
    );

CREATE POLICY "Users can create events" ON events
    FOR INSERT WITH CHECK (creator_id = auth.uid());

CREATE POLICY "Users can update events they created" ON events
    FOR UPDATE USING (creator_id = auth.uid());

CREATE POLICY "Users can delete events they created" ON events
    FOR DELETE USING (creator_id = auth.uid());

-- Create event_invitations table
CREATE TABLE event_invitations (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
    invitee_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    inviter_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'declined')),
    suggested_date TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(event_id, invitee_id)
);

-- Enable RLS
ALTER TABLE event_invitations ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "Users can view invitations they sent or received" ON event_invitations
    FOR SELECT USING (invitee_id = auth.uid() OR inviter_id = auth.uid());

CREATE POLICY "Users can create invitations for events they created" ON event_invitations
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM events
            WHERE id = event_id AND creator_id = auth.uid()
        ) AND inviter_id = auth.uid()
    );

CREATE POLICY "Users can update their own invitation responses" ON event_invitations
    FOR UPDATE USING (invitee_id = auth.uid());