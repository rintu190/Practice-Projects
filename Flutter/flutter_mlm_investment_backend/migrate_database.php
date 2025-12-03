<?php
/**
 * Database Migration Script
 * Adds missing columns to existing tables
 */

require_once __DIR__ . '/config/config.php';
require_once __DIR__ . '/config/database.php';

try {
    $db = Database::getInstance()->getConnection();
    
    echo "Running database migrations...\n\n";
    
    // Check if balance_before column exists, if not add it
    echo "Checking transactions table...\n";
    
    $result = $db->query("SHOW COLUMNS FROM transactions LIKE 'balance_before'");
    if ($result->rowCount() == 0) {
        echo "Adding balance_before column...\n";
        $db->exec("ALTER TABLE transactions ADD COLUMN balance_before DECIMAL(15, 2) NULL");
        echo "✓ balance_before added\n";
    }
    
    $result = $db->query("SHOW COLUMNS FROM transactions LIKE 'balance_after'");
    if ($result->rowCount() == 0) {
        echo "Adding balance_after column...\n";
        $db->exec("ALTER TABLE transactions ADD COLUMN balance_after DECIMAL(15, 2) NULL");
        echo "✓ balance_after added\n";
    }
    
    $result = $db->query("SHOW COLUMNS FROM transactions LIKE 'wallet_type'");
    if ($result->rowCount() == 0) {
        echo "Adding wallet_type column...\n";
        $db->exec("ALTER TABLE transactions ADD COLUMN wallet_type ENUM('e_wallet', 'investment_wallet') NULL");
        echo "✓ wallet_type added\n";
    }
    
    $result = $db->query("SHOW COLUMNS FROM transactions LIKE 'reference_type'");
    if ($result->rowCount() == 0) {
        echo "Adding reference_type column...\n";
        $db->exec("ALTER TABLE transactions ADD COLUMN reference_type VARCHAR(50) NULL");
        echo "✓ reference_type added\n";
    }
    
    echo "\n✓ Database migration completed successfully!\n";
    
} catch (Exception $e) {
    echo "❌ Migration failed: " . $e->getMessage() . "\n";
    exit(1);
}
?>
