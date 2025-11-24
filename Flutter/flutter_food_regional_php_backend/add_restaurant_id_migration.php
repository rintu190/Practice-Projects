<?php
$_ENV['DB_HOST'] = '127.0.0.1';
$_ENV['DB_USER'] = 'root';
$_ENV['DB_PASSWORD'] = 'root';
$_ENV['DB_NAME'] = 'flutter_food_regional';
require_once __DIR__ . '/config/Database.php';

try {
    $database = new Database();
    $db = $database->getConnection();
    
    echo "Adding restaurant_id column to users table...\n";
    
    $sql = "ALTER TABLE users 
            ADD COLUMN restaurant_id VARCHAR(36) NULL AFTER role,
            ADD CONSTRAINT fk_users_restaurant FOREIGN KEY (restaurant_id) REFERENCES restaurants(id) ON DELETE SET NULL";
    
    $db->exec($sql);
    
    echo "SUCCESS: restaurant_id column added successfully.\n";
    
} catch (Exception $e) {
    echo "ERROR: " . $e->getMessage() . "\n";
    if (strpos($e->getMessage(), 'Duplicate column name') !== false) {
        echo "Column already exists, skipping...\n";
    }
}
