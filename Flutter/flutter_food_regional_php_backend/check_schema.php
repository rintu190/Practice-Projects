<?php
$_ENV['DB_HOST'] = 'localhost';
$_ENV['DB_USER'] = 'root';
$_ENV['DB_PASSWORD'] = 'root';
$_ENV['DB_NAME'] = 'flutter_food_regional';
require_once __DIR__ . '/config/Database.php';

try {
    $database = new Database();
    $db = $database->getConnection();
    
    // Try to select the role column
    $stmt = $db->query("SHOW COLUMNS FROM users LIKE 'role'");
    $result = $stmt->fetch();
    
    if ($result) {
        echo "SUCCESS: Role column exists.\n";
    } else {
        echo "FAILURE: Role column does NOT exist.\n";
    }
    
} catch (Exception $e) {
    echo "ERROR: " . $e->getMessage() . "\n";
}
