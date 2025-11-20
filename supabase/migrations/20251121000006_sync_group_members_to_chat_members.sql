-- Function to sync group_members to chat_members
CREATE OR REPLACE FUNCTION public.sync_group_members_to_chat_members()
RETURNS TRIGGER AS $$
DECLARE
  target_chat_id UUID;
BEGIN
  IF (TG_OP = 'INSERT') THEN
    -- Get the chat_id for the group
    SELECT chat_id INTO target_chat_id FROM public.groups WHERE id = NEW.group_id;

    IF target_chat_id IS NOT NULL THEN
      -- Insert into chat_members if not already there
      INSERT INTO public.chat_members (chat_id, user_id)
      VALUES (target_chat_id, NEW.user_id)
      ON CONFLICT DO NOTHING;
    END IF;
    RETURN NEW;

  ELSIF (TG_OP = 'DELETE') THEN
    -- Get the chat_id for the group
    SELECT chat_id INTO target_chat_id FROM public.groups WHERE id = OLD.group_id;

    IF target_chat_id IS NOT NULL THEN
      -- Remove from chat_members
      DELETE FROM public.chat_members
      WHERE chat_id = target_chat_id AND user_id = OLD.user_id;
    END IF;
    RETURN OLD;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger
DROP TRIGGER IF EXISTS on_group_member_change ON public.group_members;
CREATE TRIGGER on_group_member_change
AFTER INSERT OR DELETE ON public.group_members
FOR EACH ROW EXECUTE FUNCTION public.sync_group_members_to_chat_members();

-- Backfill
INSERT INTO public.chat_members (chat_id, user_id)
SELECT g.chat_id, gm.user_id
FROM public.group_members gm
JOIN public.groups g ON gm.group_id = g.id
WHERE g.chat_id IS NOT NULL
ON CONFLICT DO NOTHING;
