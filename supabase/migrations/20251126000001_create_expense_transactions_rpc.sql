-- Function to get all expense transactions for a user across all events
CREATE OR REPLACE FUNCTION get_user_expense_transactions(user_id UUID)
RETURNS TABLE(
    expense_id UUID,
    event_name TEXT,
    expense_description TEXT,
    payer_name TEXT,
    amount NUMERIC,
    transaction_date TIMESTAMPTZ,
    is_owed BOOLEAN
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    WITH user_events AS (
        -- Get all events the user is part of
        SELECT DISTINCT e.id, e.name
        FROM events e
        WHERE e.creator_id = p_user_id
           OR EXISTS (
               SELECT 1 FROM event_invitations ei
               WHERE ei.event_id = e.id
                 AND ei.invitee_id = p_user_id
                 AND ei.status = 'accepted'
           )
    )
    SELECT
        ee.id as expense_id,
        ue.name as event_name,
        ee.description as expense_description,
        p.full_name as payer_name,
        CASE
            WHEN ee.payer_id = p_user_id THEN eep.amount_owed  -- User paid, this is money others owe user
            ELSE -eep.amount_owed  -- User owes this amount
        END as amount,
        ee.created_at as transaction_date,
        CASE
            WHEN ee.payer_id = p_user_id THEN true  -- User is owed this money
            ELSE false  -- User owes this money
        END as is_owed
    FROM event_expenses ee
    JOIN user_events ue ON ue.id = ee.event_id
    JOIN event_expense_participants eep ON eep.expense_id = ee.id
    JOIN profiles p ON p.id = ee.payer_id
    WHERE eep.user_id = p_user_id
      AND eep.is_settled = false
    ORDER BY ee.created_at DESC;
END;
$$;

-- Grant execute permissions
GRANT EXECUTE ON FUNCTION get_user_expense_transactions(UUID) TO authenticated;