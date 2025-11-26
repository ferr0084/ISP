-- Create RPC functions for expense summaries

-- Function to get pending expenses for a user across all events
CREATE OR REPLACE FUNCTION get_user_pending_expenses(user_id UUID)
RETURNS TABLE(
    other_user_id UUID,
    other_user_name TEXT,
    net_amount NUMERIC,
    event_name TEXT,
    expense_description TEXT
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
        WHERE e.creator_id = user_id
           OR EXISTS (
               SELECT 1 FROM event_invitations ei
               WHERE ei.event_id = e.id
                 AND ei.invitee_id = user_id
                 AND ei.status = 'accepted'
           )
    ),
    expense_balances AS (
        -- Calculate balances for each expense the user is involved in
        SELECT
            ee.event_id,
            ue.event_name,
            ee.description as expense_description,
            CASE
                WHEN ee.payer_id = user_id THEN eep.user_id  -- User is payer, other user owes
                ELSE ee.payer_id  -- User is participant, payer is owed money
            END as other_user_id,
            CASE
                WHEN ee.payer_id = user_id THEN eep.amount_owed  -- User is owed this amount
                ELSE -eep.amount_owed  -- User owes this amount
            END as amount
        FROM event_expenses ee
        JOIN user_events ue ON ue.id = ee.event_id
        JOIN event_expense_participants eep ON eep.expense_id = ee.id
        WHERE eep.user_id = user_id
          AND eep.is_settled = false
    ),
    settlement_adjustments AS (
        -- Get settlement adjustments
        SELECT
            CASE
                WHEN es.payer_id = user_id THEN es.payee_id
                ELSE es.payer_id
            END as other_user_id,
            CASE
                WHEN es.payer_id = user_id THEN es.amount  -- User paid, reduce what others owe user
                ELSE -es.amount  -- User received payment, reduce what user owes
            END as adjustment
        FROM event_settlements es
        JOIN user_events ue ON ue.id = es.event_id
        WHERE es.payer_id = user_id OR es.payee_id = user_id
    ),
    net_balances AS (
        -- Combine expenses and settlements
        SELECT
            eb.other_user_id,
            eb.event_name,
            eb.expense_description,
            eb.amount as balance
        FROM expense_balances eb

        UNION ALL

        SELECT
            sa.other_user_id,
            NULL as event_name,
            'Settlement' as expense_description,
            sa.adjustment as balance
        FROM settlement_adjustments sa
    )
    SELECT
        nb.other_user_id,
        p.full_name as other_user_name,
        SUM(nb.balance) as net_amount,
        COALESCE(nb.event_name, 'Multiple Events') as event_name,
        nb.expense_description
    FROM net_balances nb
    JOIN profiles p ON p.id = nb.other_user_id
    GROUP BY nb.other_user_id, p.full_name, nb.event_name, nb.expense_description
    HAVING SUM(nb.balance) != 0
    ORDER BY ABS(SUM(nb.balance)) DESC;
END;
$$;

-- Function to get expense summary for a user in a specific group
CREATE OR REPLACE FUNCTION get_group_expense_summary(user_id UUID, group_id UUID)
RETURNS NUMERIC
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    net_amount NUMERIC := 0;
BEGIN
    -- Calculate net balance for user in the group
    -- Positive = user is owed money, Negative = user owes money
    SELECT COALESCE(SUM(
        CASE
            WHEN ee.payer_id = user_id THEN eep.amount_owed  -- User paid, others owe user
            ELSE -eep.amount_owed  -- User owes to payer
        END
    ), 0) INTO net_amount
    FROM event_expenses ee
    JOIN events e ON e.id = ee.event_id AND e.group_id = group_id
    JOIN event_expense_participants eep ON eep.expense_id = ee.id
    WHERE eep.user_id = user_id
      AND eep.is_settled = false
      AND (
          e.creator_id = user_id OR
          EXISTS (
              SELECT 1 FROM event_invitations ei
              WHERE ei.event_id = e.id
                AND ei.invitee_id = user_id
                AND ei.status = 'accepted'
          )
      );

    -- Adjust for settlements in this group
    -- If user paid a settlement, reduce amount others owe user
    -- If user received a settlement, reduce amount user owes others
    net_amount := net_amount - COALESCE((
        SELECT SUM(
            CASE
                WHEN es.payer_id = user_id THEN es.amount  -- User paid settlement
                ELSE -es.amount  -- User received settlement
            END
        )
        FROM event_settlements es
        JOIN events e ON e.id = es.event_id AND e.group_id = group_id
        WHERE es.payer_id = user_id OR es.payee_id = user_id
    ), 0);

    RETURN net_amount;
END;
$$;

-- Grant execute permissions
GRANT EXECUTE ON FUNCTION get_user_pending_expenses(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION get_group_expense_summary(UUID, UUID) TO authenticated;