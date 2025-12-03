<?php
require_once 'config/database.php';

try {
    $db = Database::getInstance();
    $conn = $db->getConnection();
    
    // Add password_hash to users
    try {
        $conn->exec("ALTER TABLE users ADD COLUMN password_hash VARCHAR(255) AFTER email");
        echo "Added password_hash column to users table.\n";
    } catch (PDOException $e) {
        echo "Column password_hash might already exist or error: " . $e->getMessage() . "\n";
    }

} catch (Exception $e) {
    echo "Connection failed: " . $e->getMessage();
}
?>
