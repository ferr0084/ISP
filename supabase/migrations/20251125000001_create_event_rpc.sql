CREATE OR REPLACE FUNCTION create_event_with_invitations(
    p_name TEXT,
    p_description TEXT,
    p_date TIMESTAMPTZ,
    p_location TEXT,
    p_creator_id UUID,
    p_group_id UUID,
    p_invitee_ids UUID[]
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_event_id UUID;
    v_event_data JSONB;
    v_all_invitee_ids UUID[];
BEGIN
    -- Insert event
    INSERT INTO events (name, description, date, location, creator_id, group_id)
    VALUES (p_name, p_description, p_date, p_location, p_creator_id, p_group_id)
    RETURNING id INTO v_event_id;

    -- If group_id is provided, fetch all group members
    IF p_group_id IS NOT NULL THEN
        -- Get all group member IDs
        SELECT ARRAY_AGG(DISTINCT user_id)
        INTO v_all_invitee_ids
        FROM group_members
        WHERE group_id = p_group_id
          AND user_id != p_creator_id; -- Exclude creator from invitations
        
        -- Combine with explicitly provided invitee IDs
        IF p_invitee_ids IS NOT NULL AND array_length(p_invitee_ids, 1) > 0 THEN
            v_all_invitee_ids := ARRAY(
                SELECT DISTINCT unnest(v_all_invitee_ids || p_invitee_ids)
            );
        END IF;
    ELSE
        -- No group, just use provided invitee IDs
        v_all_invitee_ids := p_invitee_ids;
    END IF;

    -- Insert invitations for all invitees
    IF v_all_invitee_ids IS NOT NULL AND array_length(v_all_invitee_ids, 1) > 0 THEN
        INSERT INTO event_invitations (event_id, invitee_id, inviter_id, status)
        SELECT v_event_id, unnest(v_all_invitee_ids), p_creator_id, 'pending';
    END IF;

    -- Return the created event
    SELECT to_jsonb(e) INTO v_event_data FROM events e WHERE id = v_event_id;
    
    RETURN v_event_data;
END;
$$;
