<?php
$_ENV['DB_HOST'] = '127.0.0.1';
$_ENV['DB_USER'] = 'root';
$_ENV['DB_PASSWORD'] = 'root';
$_ENV['DB_NAME'] = 'flutter_food_regional';
require_once __DIR__ . '/config/Database.php';

try {
    $database = new Database();
    $db = $database->getConnection();
    
    echo "Applying rider_id column migration...\n";
    
    // Add rider_id column
    $sql = "ALTER TABLE orders 
            ADD COLUMN rider_id VARCHAR(36) NULL AFTER address_id,
            ADD CONSTRAINT fk_orders_rider FOREIGN KEY (rider_id) REFERENCES users(id) ON DELETE SET NULL";
    
    $db->exec($sql);
    
    echo "SUCCESS: rider_id column added successfully.\n";
    
} catch (Exception $e) {
    echo "ERROR: " . $e->getMessage() . "\n";
}
