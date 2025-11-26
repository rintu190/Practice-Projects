-- Migration to add is_veg column to menu_items table
-- Run this if you already have an existing database

USE flutter_food_regional;

-- Add is_veg column to menu_items table
ALTER TABLE menu_items 
ADD COLUMN is_veg BOOLEAN DEFAULT TRUE AFTER image_url;

-- Update existing menu items (optional - set some items as non-veg based on name patterns)
-- You can customize this based on your actual menu items
UPDATE menu_items SET is_veg = FALSE 
WHERE LOWER(name) LIKE '%chicken%' 
   OR LOWER(name) LIKE '%mutton%' 
   OR LOWER(name) LIKE '%fish%' 
   OR LOWER(name) LIKE '%prawn%' 
   OR LOWER(name) LIKE '%egg%'
   OR LOWER(name) LIKE '%meat%'
   OR LOWER(name) LIKE '%beef%'
   OR LOWER(name) LIKE '%pork%';
