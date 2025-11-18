CREATE TABLE public.invitations (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    inviter_id uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    invitee_email text NOT NULL,
    status text DEFAULT 'pending' NOT NULL,
    token uuid UNIQUE DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    expires_at timestamp with time zone,

    CONSTRAINT chk_status CHECK (status IN ('pending', 'accepted', 'declined', 'expired'))
);

ALTER TABLE public.invitations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their sent invitations." ON public.invitations
FOR SELECT USING (auth.uid() = inviter_id);

CREATE POLICY "Users can create invitations." ON public.invitations
FOR INSERT WITH CHECK (auth.uid() = inviter_id);

CREATE POLICY "Users can update their sent invitations." ON public.invitations
FOR UPDATE USING (auth.uid() = inviter_id);

CREATE POLICY "Users can delete their sent invitations." ON public.invitations
FOR DELETE USING (auth.uid() = inviter_id);
