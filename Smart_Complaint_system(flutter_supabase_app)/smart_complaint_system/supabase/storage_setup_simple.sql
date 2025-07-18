-- Simple storage setup for profile pictures (no RLS restrictions)
-- Run this in your Supabase SQL Editor

-- Create storage bucket for avatars
INSERT INTO storage.buckets (id, name, public)
VALUES ('avatars', 'avatars', true)
ON CONFLICT (id) DO NOTHING;

-- Disable RLS for the avatars bucket (simplest approach)
ALTER TABLE storage.objects DISABLE ROW LEVEL SECURITY;

-- Or if you want to keep RLS enabled but make it very permissive:
-- CREATE POLICY "Allow all authenticated operations on avatars" ON storage.objects
-- FOR ALL USING (bucket_id = 'avatars' AND auth.role() = 'authenticated'); 