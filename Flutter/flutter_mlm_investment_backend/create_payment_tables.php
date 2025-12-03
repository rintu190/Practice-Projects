<?php
require_once __DIR__ . '/config/database.php';

try {
    $db = Database::getInstance();
    $conn = $db->getConnection();
    
    echo "Creating payment-related tables...\n\n";
    
    // Create deposits table
    $sql = "CREATE TABLE IF NOT EXISTS deposits (
        id INT PRIMARY KEY AUTO_INCREMENT,
        user_id INT NOT NULL,
        wallet_type ENUM('e_wallet', 'investment_wallet') NOT NULL,
        amount DECIMAL(15,2) NOT NULL,
        payment_method VARCHAR(50),
        gateway_order_id VARCHAR(255),
        gateway_payment_id VARCHAR(255),
        status ENUM('pending', 'success', 'failed') DEFAULT 'pending',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        completed_at TIMESTAMP NULL,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        INDEX idx_user_status (user_id, status),
        INDEX idx_gateway_order (gateway_order_id)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4";
    
    $conn->exec($sql);
    echo "✓ Created deposits table\n";
    
    // Create withdrawals table
    $sql = "CREATE TABLE IF NOT EXISTS withdrawals (
        id INT PRIMARY KEY AUTO_INCREMENT,
        user_id INT NOT NULL,
        wallet_type ENUM('e_wallet', 'investment_wallet') NOT NULL,
        amount DECIMAL(15,2) NOT NULL,
        charges DECIMAL(15,2) DEFAULT 0,
        net_amount DECIMAL(15,2) NOT NULL,
        bank_account_id INT,
        status ENUM('pending', 'approved', 'rejected', 'completed') DEFAULT 'pending',
        admin_remarks TEXT,
        requested_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        processed_at TIMESTAMP NULL,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (bank_account_id) REFERENCES bank_details(id) ON DELETE SET NULL,
        INDEX idx_user_status (user_id, status),
        INDEX idx_status_date (status, requested_at)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4";
    
    $conn->exec($sql);
    echo "✓ Created withdrawals table\n";
    
    // Check if columns already exist before adding them
    $checkColumns = $conn->query("SHOW COLUMNS FROM transactions LIKE 'reference_type'");
    if ($checkColumns->rowCount() == 0) {
        // Modify transactions table
        $sql = "ALTER TABLE transactions 
                ADD COLUMN reference_type VARCHAR(50) AFTER description,
                ADD COLUMN reference_id INT AFTER reference_type,
                ADD COLUMN balance_after DECIMAL(15,2) AFTER amount";
        
        $conn->exec($sql);
        echo "✓ Modified transactions table\n";
    } else {
        echo "✓ Transactions table already has new columns\n";
    }
    
    echo "\n✅ Database schema updated successfully!\n";
    
} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
?>
