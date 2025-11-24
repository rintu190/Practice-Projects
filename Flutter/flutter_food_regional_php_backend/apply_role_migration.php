<?php
$_ENV['DB_HOST'] = '127.0.0.1';
$_ENV['DB_USER'] = 'root';
$_ENV['DB_PASSWORD'] = 'root';
$_ENV['DB_NAME'] = 'flutter_food_regional';
require_once __DIR__ . '/config/Database.php';

try {
    $database = new Database();
    $db = $database->getConnection();
    
    echo "Applying role column migration...\n";
    
    // Add role column
    $sql = "ALTER TABLE users ADD COLUMN role ENUM('admin', 'customer', 'rider', 'restaurant') DEFAULT 'customer' AFTER email";
    
    $db->exec($sql);
    
    echo "SUCCESS: Role column added successfully.\n";
    
    // Verify
    $stmt = $db->query("SHOW COLUMNS FROM users LIKE 'role'");
    $result = $stmt->fetch();
    
    if ($result) {
        echo "VERIFIED: Role column exists.\n";
    }
    
} catch (Exception $e) {
    echo "ERROR: " . $e->getMessage() . "\n";
}
