-- Create event_expenses table
CREATE TABLE event_expenses (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
    payer_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    amount NUMERIC NOT NULL CHECK (amount > 0),
    description TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create event_expense_participants table
CREATE TABLE event_expense_participants (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    expense_id UUID NOT NULL REFERENCES event_expenses(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    amount_owed NUMERIC NOT NULL CHECK (amount_owed > 0),
    is_settled BOOLEAN DEFAULT FALSE,
    UNIQUE(expense_id, user_id)
);

-- Create event_settlements table
CREATE TABLE event_settlements (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
    payer_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    payee_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    amount NUMERIC NOT NULL CHECK (amount > 0),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE event_expenses ENABLE ROW LEVEL SECURITY;
ALTER TABLE event_expense_participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE event_settlements ENABLE ROW LEVEL SECURITY;

-- Policies for event_expenses
CREATE POLICY "Users can view expenses for events they are part of" ON event_expenses
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM events
            WHERE id = event_expenses.event_id AND (
                creator_id = auth.uid() OR
                EXISTS (
                    SELECT 1 FROM event_invitations
                    WHERE event_id = events.id AND invitee_id = auth.uid() AND status = 'accepted'
                )
            )
        )
    );

CREATE POLICY "Users can create expenses for events they are part of" ON event_expenses
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM events
            WHERE id = event_id AND (
                creator_id = auth.uid() OR
                EXISTS (
                    SELECT 1 FROM event_invitations
                    WHERE event_id = events.id AND invitee_id = auth.uid() AND status = 'accepted'
                )
            )
        ) AND payer_id = auth.uid()
    );

CREATE POLICY "Users can delete expenses they created" ON event_expenses
    FOR DELETE USING (payer_id = auth.uid());

-- Policies for event_expense_participants
CREATE POLICY "Users can view expense participants for events they are part of" ON event_expense_participants
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM event_expenses
            JOIN events ON events.id = event_expenses.event_id
            WHERE event_expenses.id = event_expense_participants.expense_id AND (
                events.creator_id = auth.uid() OR
                EXISTS (
                    SELECT 1 FROM event_invitations
                    WHERE event_id = events.id AND invitee_id = auth.uid() AND status = 'accepted'
                )
            )
        )
    );

CREATE POLICY "Users can insert expense participants when creating an expense" ON event_expense_participants
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM event_expenses
            WHERE id = expense_id AND payer_id = auth.uid()
        )
    );

-- Policies for event_settlements
CREATE POLICY "Users can view settlements for events they are part of" ON event_settlements
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM events
            WHERE id = event_settlements.event_id AND (
                creator_id = auth.uid() OR
                EXISTS (
                    SELECT 1 FROM event_invitations
                    WHERE event_id = events.id AND invitee_id = auth.uid() AND status = 'accepted'
                )
            )
        )
    );

CREATE POLICY "Users can create settlements they are involved in" ON event_settlements
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM events
            WHERE id = event_id AND (
                creator_id = auth.uid() OR
                EXISTS (
                    SELECT 1 FROM event_invitations
                    WHERE event_id = events.id AND invitee_id = auth.uid() AND status = 'accepted'
                )
            )
        ) AND (payer_id = auth.uid() OR payee_id = auth.uid())
    );
