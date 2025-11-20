-- Migration: 20251121000004_fix_group_rls.sql

-- Drop the old policy that might depend on member_ids
DROP POLICY IF EXISTS "Users can create new groups." ON public.groups;

-- Create a new policy allowing any authenticated user to create a group
-- We don't need to check member_ids anymore as that is handled by the trigger
CREATE POLICY "Users can create new groups" ON public.groups
FOR INSERT
TO authenticated
WITH CHECK (true);
