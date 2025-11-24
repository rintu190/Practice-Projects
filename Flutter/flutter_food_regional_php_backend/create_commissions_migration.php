<?php
$_ENV['DB_HOST'] = '127.0.0.1';
$_ENV['DB_USER'] = 'root';
$_ENV['DB_PASSWORD'] = 'root';
$_ENV['DB_NAME'] = 'flutter_food_regional';
require_once __DIR__ . '/config/Database.php';

try {
    $database = new Database();
    $db = $database->getConnection();
    
    echo "Creating commissions table...\n";
    
    $sql = "CREATE TABLE IF NOT EXISTS commissions (
        id VARCHAR(36) PRIMARY KEY,
        user_id VARCHAR(36) NOT NULL,
        order_id VARCHAR(36) NOT NULL,
        amount DECIMAL(10,2) NOT NULL,
        percentage DECIMAL(5,2) NOT NULL,
        status VARCHAR(20) DEFAULT 'pending',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE
    )";
    
    $db->exec($sql);
    
    echo "SUCCESS: Commissions table created successfully.\n";
    
} catch (Exception $e) {
    echo "ERROR: " . $e->getMessage() . "\n";
}
