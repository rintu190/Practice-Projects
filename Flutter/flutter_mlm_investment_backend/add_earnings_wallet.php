<?php
require_once 'config/database.php';

$db = Database::getInstance();
$conn = $db->getConnection();

echo "=== Adding Earnings Wallet System ===\n\n";

try {
    // 1. Add earnings_balance column to wallets table
    echo "1. Adding earnings_balance column to wallets table...\n";
    try {
        $conn->exec("
            ALTER TABLE wallets 
            ADD COLUMN earnings_balance DECIMAL(15,2) DEFAULT 0.00 AFTER e_wallet_balance
        ");
        echo "   ✓ Added earnings_balance column\n\n";
    } catch (Exception $e) {
        if (strpos($e->getMessage(), 'Duplicate column') !== false) {
            echo "   ✓ earnings_balance column already exists\n\n";
        } else {
            throw $e;
        }
    }
    
    // 2. Migrate existing total_earned to earnings_balance
    echo "2. Migrating existing total_earned to earnings_balance...\n";
    $conn->exec("
        UPDATE wallets 
        SET earnings_balance = total_earned
        WHERE earnings_balance = 0
    ");
    echo "   ✓ Migrated total_earned to earnings_balance\n\n";
    
    // 3. Create earnings_withdrawals table to track transfers
    echo "3. Creating earnings_withdrawals table...\n";
    $conn->exec("
        CREATE TABLE IF NOT EXISTS earnings_withdrawals (
            id INT AUTO_INCREMENT PRIMARY KEY,
            user_id INT NOT NULL,
            amount DECIMAL(15,2) NOT NULL,
            earnings_before DECIMAL(15,2) NOT NULL,
            earnings_after DECIMAL(15,2) NOT NULL,
            wallet_before DECIMAL(15,2) NOT NULL,
            wallet_after DECIMAL(15,2) NOT NULL,
            status ENUM('pending', 'completed', 'failed') DEFAULT 'completed',
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
            INDEX idx_user_id (user_id),
            INDEX idx_created_at (created_at)
        )
    ");
    echo "   ✓ Created earnings_withdrawals table\n\n";
    
    echo "✅ Database schema updated successfully!\n";
    
} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
