-- Migration: 20251120000001_add_group_id_to_invitations.sql
ALTER TABLE public.invitations ADD COLUMN group_id uuid REFERENCES groups(id);
CREATE INDEX idx_invitations_group_id ON public.invitations(group_id);

-- RLS Policy for group invites on public.invitations
CREATE POLICY "Group members can create group invitations" ON public.invitations
FOR INSERT WITH CHECK (
  group_id IS NOT NULL AND
  EXISTS (
    SELECT 1 FROM public.group_members
    WHERE group_id = invitations.group_id AND
          user_id = auth.uid()
  )
);