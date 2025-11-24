-- Add restaurant_id column to users table
ALTER TABLE users 
ADD COLUMN restaurant_id VARCHAR(36) NULL AFTER role,
ADD CONSTRAINT fk_users_restaurant FOREIGN KEY (restaurant_id) REFERENCES restaurants(id) ON DELETE SET NULL;
