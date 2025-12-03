<?php
require_once __DIR__ . '/config/database.php';

try {
    $db = Database::getInstance();
    $conn = $db->getConnection();
    
    echo "Adding category and tier columns to investment_products table...\n";
    
    // Add category column
    $checkCategory = $conn->query("SHOW COLUMNS FROM investment_products LIKE 'category'");
    if ($checkCategory->rowCount() == 0) {
        $conn->exec("ALTER TABLE investment_products ADD COLUMN category VARCHAR(50) DEFAULT 'Securities' AFTER name");
        echo "✓ Added category column\n";
    } else {
        echo "- category column already exists\n";
    }
    
    // Add tier column
    $checkTier = $conn->query("SHOW COLUMNS FROM investment_products LIKE 'tier'");
    if ($checkTier->rowCount() == 0) {
        $conn->exec("ALTER TABLE investment_products ADD COLUMN tier ENUM('Bronze', 'Silver', 'Gold') DEFAULT 'Bronze' AFTER category");
        echo "✓ Added tier column\n";
    } else {
        echo "- tier column already exists\n";
    }
    
    echo "\nMigration completed successfully!\n";
    
} catch (PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
