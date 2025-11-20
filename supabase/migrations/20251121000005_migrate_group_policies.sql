-- Migration: 20251121000005_migrate_group_policies.sql

-- 1. Drop old policies that depend on member_ids
DROP POLICY IF EXISTS "Users can view groups they are a member of." ON public.groups;
DROP POLICY IF EXISTS "Users can update groups they are a member of." ON public.groups;
DROP POLICY IF EXISTS "Users can delete groups they are a member of." ON public.groups;

-- 2. Drop the trigger that depends on member_ids
DROP TRIGGER IF EXISTS on_group_updated ON public.groups;
-- Also drop the function if it's no longer needed, or update it?
-- The function handle_group_update() uses member_ids. We should probably drop it or update it.
-- For now, let's just drop the trigger.

-- 3. Drop the member_ids column
ALTER TABLE public.groups DROP COLUMN IF EXISTS member_ids;

-- 4. Create new policies using group_members table

CREATE POLICY "Users can view groups they are a member of" ON public.groups
FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM public.group_members gm
    WHERE gm.group_id = groups.id AND gm.user_id = auth.uid()
  )
);

CREATE POLICY "Users can update groups they are a member of" ON public.groups
FOR UPDATE
USING (
  EXISTS (
    SELECT 1 FROM public.group_members gm
    WHERE gm.group_id = groups.id AND gm.user_id = auth.uid()
  )
);

CREATE POLICY "Users can delete groups they are a member of" ON public.groups
FOR DELETE
USING (
  EXISTS (
    SELECT 1 FROM public.group_members gm
    WHERE gm.group_id = groups.id AND gm.user_id = auth.uid()
  )
);
