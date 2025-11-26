-- Allow public read access to idiot-pics
CREATE POLICY "Public read access for idiot-pics" ON storage.objects
FOR SELECT USING (bucket_id = 'idiot-pics');

-- Allow authenticated users to upload game photos
CREATE POLICY "Authenticated users can upload game photos" ON storage.objects
FOR INSERT WITH CHECK (
  bucket_id = 'idiot-pics'
  AND auth.role() = 'authenticated'
);

-- Allow authenticated users to update game photos
CREATE POLICY "Authenticated users can update game photos" ON storage.objects
FOR UPDATE USING (
  bucket_id = 'idiot-pics'
  AND auth.role() = 'authenticated'
);

-- Allow authenticated users to delete game photos
CREATE POLICY "Authenticated users can delete game photos" ON storage.objects
FOR DELETE USING (
  bucket_id = 'idiot-pics'
  AND auth.role() = 'authenticated'
);