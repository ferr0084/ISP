CREATE TABLE notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  type TEXT NOT NULL,
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  data JSONB,
  read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own notifications" ON notifications
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own notifications" ON notifications
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own notifications" ON notifications
  FOR UPDATE USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

COMMENT ON TABLE notifications IS 'Stores in-app notifications for users.';
COMMENT ON COLUMN notifications.user_id IS 'The ID of the user who receives the notification.';
COMMENT ON COLUMN notifications.type IS 'The type of notification (e.g., group_invite, message).';
COMMENT ON COLUMN notifications.title IS 'The title of the notification.';
COMMENT ON COLUMN notifications.message IS 'The message body of the notification.';
COMMENT ON COLUMN notifications.data IS 'Additional structured data related to the notification.';
COMMENT ON COLUMN notifications.read IS 'Whether the notification has been read by the user.';
