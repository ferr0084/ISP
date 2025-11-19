-- Migration: 20251120000000_create_group_members_table.sql
CREATE TABLE public.group_members (
    group_id uuid NOT NULL REFERENCES public.groups(id) ON DELETE CASCADE,
    user_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    role TEXT NOT NULL DEFAULT 'member', -- e.g., 'admin', 'member'
    joined_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (group_id, user_id)
);

-- Indexes for performance
CREATE INDEX idx_group_members_user_id ON public.group_members(user_id);

-- RLS policies for group_members table
CREATE POLICY "Group members can view other members" ON public.group_members
FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM public.group_members gm
    WHERE gm.group_id = group_members.group_id AND gm.user_id = auth.uid()
  )
);

CREATE POLICY "Admins can manage members" ON public.group_members
FOR ALL USING (
  (SELECT role FROM public.group_members WHERE group_id = group_members.group_id AND user_id = auth.uid()) = 'admin'
);