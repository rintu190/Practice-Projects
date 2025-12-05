<?php
/**
 * Migration: Add missing columns to bank_details table
 * This script adds the account_type column that was missing
 */

require_once __DIR__ . '/config/database.php';

try {
    $db = Database::getInstance();
    $conn = $db->getConnection();

    echo "Adding missing columns to bank_details table...\n\n";

    // 1. Add account_type column if it doesn't exist
    try {
        $conn->exec("ALTER TABLE bank_details ADD COLUMN `account_type` VARCHAR(20) DEFAULT 'savings' AFTER `branch_name`");
        echo "✓ Added account_type column to bank_details table.\n";
    } catch (PDOException $e) {
        if (strpos($e->getMessage(), 'Duplicate column name') !== false) {
            echo "✓ account_type column already exists.\n";
        } else {
            throw $e;
        }
    }

    // 2. Verify the bank_details table structure
    echo "\nVerifying bank_details table structure...\n";
    $stmt = $conn->query("DESCRIBE bank_details");
    $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    echo "\nbank_details table columns:\n";
    foreach ($columns as $column) {
        echo "  ✓ " . $column['Field'] . " (" . $column['Type'] . ")\n";
    }

    echo "\n✅ Migration completed successfully!\n";

} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
?>
