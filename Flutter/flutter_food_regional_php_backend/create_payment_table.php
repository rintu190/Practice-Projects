<?php
require_once __DIR__ . '/config/Database.php';
require_once __DIR__ . '/config/Env.php';

// Load environment variables
Env::load(__DIR__ . '/.env');

try {
    $database = new Database();
    $db = $database->getConnection();
    
    $sql = "
    CREATE TABLE IF NOT EXISTS payment_methods (
        id VARCHAR(36) PRIMARY KEY,
        user_id VARCHAR(36) NOT NULL,
        type VARCHAR(20) NOT NULL,
        title VARCHAR(255) NOT NULL,
        subtitle VARCHAR(255) NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
    );";
    
    $db->exec($sql);
    echo "Payment methods table created successfully.\n";
} catch(PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
