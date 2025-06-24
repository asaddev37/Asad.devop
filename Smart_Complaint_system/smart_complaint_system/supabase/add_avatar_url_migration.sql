-- Migration to add avatar_url column to profiles table
-- Run this in your Supabase SQL editor

ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS avatar_url TEXT;
 
-- Add a comment to document the column
COMMENT ON COLUMN profiles.avatar_url IS 'URL to the user profile picture stored in Supabase Storage'; 