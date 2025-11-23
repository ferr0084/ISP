-- Add group_id to events table
ALTER TABLE events ADD COLUMN group_id UUID REFERENCES groups(id) ON DELETE CASCADE;

-- Update policies to allow group members to view events
DROP POLICY IF EXISTS "Users can view events they created or are invited to" ON events;
CREATE POLICY "Users can view events they created, are invited to, or belong to their groups" ON events
    FOR SELECT USING (
        creator_id = auth.uid() OR
        EXISTS (
            SELECT 1 FROM event_invitations
            WHERE event_id = events.id AND invitee_id = auth.uid()
        ) OR
        EXISTS (
            SELECT 1 FROM group_members
            WHERE group_id = events.group_id AND user_id = auth.uid()
        )
    );

-- Update create policy to ensure creator is member of the group (if group is selected)
DROP POLICY IF EXISTS "Users can create events" ON events;
CREATE POLICY "Users can create events" ON events
    FOR INSERT WITH CHECK (
        creator_id = auth.uid() AND
        (group_id IS NULL OR EXISTS (
            SELECT 1 FROM group_members
            WHERE group_id = events.group_id AND user_id = auth.uid()
        ))
    );

-- Update update policy
DROP POLICY IF EXISTS "Users can update events they created" ON events;
CREATE POLICY "Users can update events they created" ON events
    FOR UPDATE USING (
        creator_id = auth.uid() AND
        (group_id IS NULL OR EXISTS (
            SELECT 1 FROM group_members
            WHERE group_id = events.group_id AND user_id = auth.uid()
        ))
    );

-- Update delete policy
DROP POLICY IF EXISTS "Users can delete events they created" ON events;
CREATE POLICY "Users can delete events they created" ON events
    FOR DELETE USING (
        creator_id = auth.uid() AND
        (group_id IS NULL OR EXISTS (
            SELECT 1 FROM group_members
            WHERE group_id = events.group_id AND user_id = auth.uid()
        ))
    );