<?php
require_once __DIR__ . '/config/database.php';

try {
    $db = Database::getInstance();
    $conn = $db->getConnection();

    echo "Creating missing tables...\n";

    // 1. investment_wallets
    $sql1 = "CREATE TABLE IF NOT EXISTS investment_wallets (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id INT UNIQUE NOT NULL,
        balance DECIMAL(15,2) DEFAULT 0.00,
        total_invested DECIMAL(15,2) DEFAULT 0.00,
        total_profit DECIMAL(15,2) DEFAULT 0.00,
        total_withdrawn DECIMAL(15,2) DEFAULT 0.00,
        unrealized_pnl DECIMAL(15,2) DEFAULT 0.00,
        realized_pnl DECIMAL(15,2) DEFAULT 0.00,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        CHECK (balance >= 0)
    ) ENGINE=InnoDB;";
    $conn->exec($sql1);
    echo "Created investment_wallets table.\n";

    // 2. daily_pnl
    $sql2 = "CREATE TABLE IF NOT EXISTS daily_pnl (
        id INT AUTO_INCREMENT PRIMARY KEY,
        investment_id INT NOT NULL,
        user_id INT NOT NULL,
        product_id INT NOT NULL,
        pnl_date DATE NOT NULL,
        profit_amount DECIMAL(15,2) DEFAULT 0.00,
        loss_amount DECIMAL(15,2) DEFAULT 0.00,
        net_pnl DECIMAL(15,2) NOT NULL,
        pnl_percentage DECIMAL(5,2),
        investment_value_before DECIMAL(15,2) NOT NULL,
        investment_value_after DECIMAL(15,2) NOT NULL,
        notes TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (investment_id) REFERENCES user_investments(id) ON DELETE CASCADE,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (product_id) REFERENCES investment_products(id) ON DELETE CASCADE,
        UNIQUE KEY unique_investment_date (investment_id, pnl_date),
        INDEX idx_user_date (user_id, pnl_date),
        INDEX idx_date (pnl_date)
    ) ENGINE=InnoDB;";
    $conn->exec($sql2);
    echo "Created daily_pnl table.\n";

    // 3. commissions
    $sql3 = "CREATE TABLE IF NOT EXISTS commissions (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id INT NOT NULL,
        from_user_id INT COMMENT 'User who generated this commission',
        commission_type ENUM('direct_sponsor', 'level_bonus', 'matching_bonus', 'rank_bonus', 'investment_bonus', 'roi_bonus', 'global_pool') NOT NULL,
        amount DECIMAL(15,2) NOT NULL,
        percentage DECIMAL(5,2),
        level INT COMMENT 'For level-based commissions',
        reference_type ENUM('investment', 'package_purchase', 'roi', 'team_performance') NOT NULL,
        reference_id INT,
        description TEXT,
        status ENUM('pending', 'approved', 'paid', 'cancelled') DEFAULT 'approved',
        paid_at TIMESTAMP NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (from_user_id) REFERENCES users(id) ON DELETE SET NULL,
        INDEX idx_user_type (user_id, commission_type),
        INDEX idx_status (status),
        INDEX idx_created (created_at)
    ) ENGINE=InnoDB;";
    $conn->exec($sql3);
    echo "Created commissions table.\n";

    echo "Missing tables created successfully.\n";

} catch (Exception $e) {
    echo "Error creating tables: " . $e->getMessage() . "\n";
}
?>
