-- Create avatars storage bucket
--INSERT INTO storage.buckets (id, name, public)
--VALUES ('avatars', 'avatars', true);

-- Enable RLS on storage.objects
--ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

-- Allow public read access to avatars
CREATE POLICY "Public read access for avatars" ON storage.objects
FOR SELECT USING (bucket_id = 'avatars');

-- Allow authenticated users to upload/update their own avatars
-- Assumes avatar files are stored as {user_id}/avatar.jpg
CREATE POLICY "Users can upload avatars" ON storage.objects
FOR INSERT WITH CHECK (
  bucket_id = 'avatars'
  AND auth.uid()::text = (string_to_array(name, '/'))[1]
);

-- Allow users to update their own avatars
CREATE POLICY "Users can update their own avatars" ON storage.objects
FOR UPDATE USING (
  bucket_id = 'avatars'
  AND auth.uid()::text = (string_to_array(name, '/'))[1]
);

-- Allow users to delete their own avatars
CREATE POLICY "Users can delete their own avatars" ON storage.objects
FOR DELETE USING (
  bucket_id = 'avatars'
  AND auth.uid()::text = (string_to_array(name, '/'))[1]
);