# Profile Picture Setup Guide

To enable profile picture functionality in the Smart Complaint System, you need to run the following database migrations in your Supabase project.

## Step 1: Add avatar_url column to profiles table

Run this SQL in your Supabase SQL Editor:

```sql
-- Migration to add avatar_url column to profiles table
ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS avatar_url TEXT;

-- Add a comment to document the column
COMMENT ON COLUMN profiles.avatar_url IS 'URL to the user profile picture stored in Supabase Storage';
```

## Step 2: Create storage bucket and policies (FIXED VERSION)

Run this SQL in your Supabase SQL Editor:

```sql
-- Fixed storage setup for profile pictures
-- Create storage bucket for avatars
INSERT INTO storage.buckets (id, name, public)
VALUES ('avatars', 'avatars', true)
ON CONFLICT (id) DO NOTHING;

-- Drop any existing policies for avatars
DROP POLICY IF EXISTS "Users can upload their own avatar" ON storage.objects;
DROP POLICY IF EXISTS "Public read access to avatars" ON storage.objects;
DROP POLICY IF EXISTS "Users can update their own avatar" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete their own avatar" ON storage.objects;
DROP POLICY IF EXISTS "Allow authenticated uploads to avatars" ON storage.objects;
DROP POLICY IF EXISTS "Allow authenticated updates to avatars" ON storage.objects;
DROP POLICY IF EXISTS "Allow authenticated deletes to avatars" ON storage.objects;

-- Create a single, very permissive policy for avatars bucket
CREATE POLICY "Allow all authenticated operations on avatars" ON storage.objects
FOR ALL USING (bucket_id = 'avatars' AND auth.role() = 'authenticated')
WITH CHECK (bucket_id = 'avatars' AND auth.role() = 'authenticated');
```

## Step 3: Test the feature

1. Run the Flutter app
2. Log in as an admin
3. Navigate to "My Profile" from the drawer
4. Try uploading a profile picture
5. Check that the picture appears in the drawer header and dashboard header

## Troubleshooting

If you encounter issues:

1. **Storage bucket not found**: Make sure you've run the storage setup SQL
2. **Upload permission denied (403 error)**: Run the fixed storage setup above to resolve RLS policy issues
3. **Profile not updating**: Verify the avatar_url column was added to the profiles table
4. **Image not displaying**: Check the browser console for any CORS or network errors

## Files Modified

- `lib/services/supabase_service.dart` - Added upload functionality
- `lib/screens/admin_dashboard/controllers/admin_dashboard_controller.dart` - Added profile update logic
- `lib/screens/admin_dashboard/screens/admin_profile_screen.dart` - Created profile management UI
- `lib/screens/admin_dashboard/widgets/navigation_menu.dart` - Added dynamic profile display
- `lib/screens/admin_dashboard/widgets/dashboard_header.dart` - Added dynamic profile display
- `supabase/schema.sql` - Updated schema to include avatar_url column 