<?php
$_ENV['DB_HOST'] = '127.0.0.1';
$_ENV['DB_USER'] = 'root';
$_ENV['DB_PASSWORD'] = 'root';
$_ENV['DB_NAME'] = 'flutter_food_regional';
require_once __DIR__ . '/config/Database.php';

try {
    $database = new Database();
    $db = $database->getConnection();
    
    echo "Adding address and phone columns to restaurants table...\n";
    
    // Add address and phone columns
    $sql = "ALTER TABLE restaurants 
            ADD COLUMN address TEXT NULL AFTER delivery_time,
            ADD COLUMN phone VARCHAR(20) NULL AFTER address";
    
    $db->exec($sql);
    
    echo "SUCCESS: Columns added successfully.\n";
    
} catch (Exception $e) {
    echo "ERROR: " . $e->getMessage() . "\n";
    // If columns already exist, that's okay
    if (strpos($e->getMessage(), 'Duplicate column name') !== false) {
        echo "Columns already exist, skipping...\n";
    }
}
