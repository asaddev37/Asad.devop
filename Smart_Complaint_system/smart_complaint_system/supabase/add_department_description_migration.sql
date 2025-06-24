-- Migration to add description column to departments table
-- Run this in your Supabase SQL Editor

ALTER TABLE departments 
ADD COLUMN IF NOT EXISTS description TEXT;
 
-- Add a comment to document the column
COMMENT ON COLUMN departments.description IS 'Description of the department'; 