<?php
require_once __DIR__ . '/config/database.php';

try {
    $db = Database::getInstance();
    $conn = $db->getConnection();
    
    echo "Updating investment management schema...\n\n";
    
    // 1. Enhance investment_products table
    echo "1. Updating investment_products table...\n";
    
    // Check and add columns one by one
    $columnsToAdd = [
        "product_type ENUM('instrument', 'fund', 'fixed_plan', 'profit_sharing') DEFAULT 'fixed_plan'",
        "roi_frequency ENUM('daily', 'weekly', 'monthly', 'maturity') DEFAULT 'maturity'",
        "auto_renew_enabled TINYINT(1) DEFAULT 0",
        "compound_interest TINYINT(1) DEFAULT 0",
        "risk_level ENUM('low', 'medium', 'high') DEFAULT 'medium'",
        "early_withdrawal_penalty DECIMAL(5,2) DEFAULT 0"
    ];
    
    foreach ($columnsToAdd as $columnDef) {
        $columnName = explode(' ', $columnDef)[0];
        $checkStmt = $conn->query("SHOW COLUMNS FROM investment_products LIKE '$columnName'");
        if ($checkStmt->rowCount() == 0) {
            $conn->exec("ALTER TABLE investment_products ADD COLUMN $columnDef");
            echo "  ✓ Added column: $columnName\n";
        } else {
            echo "  - Column already exists: $columnName\n";
        }
    }
    
    // 2. Enhance user_investments table
    echo "2. Updating user_investments table...\n";
    
    $columnsToAdd = [
        "auto_renew TINYINT(1) DEFAULT 0",
        "maturity_date DATE",
        "last_profit_date DATE",
        "total_profit_earned DECIMAL(15,2) DEFAULT 0",
        "status ENUM('active', 'matured', 'withdrawn', 'renewed') DEFAULT 'active'"
    ];
    
    foreach ($columnsToAdd as $columnDef) {
        $columnName = explode(' ', $columnDef)[0];
        $checkStmt = $conn->query("SHOW COLUMNS FROM user_investments LIKE '$columnName'");
        if ($checkStmt->rowCount() == 0) {
            $conn->exec("ALTER TABLE user_investments ADD COLUMN $columnDef");
            echo "  ✓ Added column: $columnName\n";
        } else {
            echo "  - Column already exists: $columnName\n";
        }
    }
    
    // 3. Create investment_profits table
    echo "3. Creating investment_profits table...\n";
    $conn->exec("
        CREATE TABLE IF NOT EXISTS investment_profits (
            id INT PRIMARY KEY AUTO_INCREMENT,
            investment_id INT NOT NULL,
            user_id INT NOT NULL,
            amount DECIMAL(15,2) NOT NULL,
            profit_date DATE NOT NULL,
            credited_to ENUM('e_wallet', 'investment_wallet', 'reinvested') DEFAULT 'investment_wallet',
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (investment_id) REFERENCES user_investments(id) ON DELETE CASCADE,
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
            INDEX idx_investment_date (investment_id, profit_date),
            INDEX idx_user_date (user_id, profit_date)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
    ");
    echo "✓ Created investment_profits table\n";
    
    // 4. Update existing investment products with new fields
    echo "4. Updating existing investment products...\n";
    $conn->exec("
        UPDATE investment_products 
        SET 
            product_type = 'fixed_plan',
            roi_frequency = 'maturity',
            risk_level = 'medium',
            auto_renew_enabled = 0,
            compound_interest = 0
        WHERE product_type IS NULL
    ");
    echo "✓ Updated existing products\n";
    
    // 5. Calculate and set maturity dates for existing investments
    echo "5. Calculating maturity dates for existing investments...\n";
    $stmt = $conn->query("
        SELECT ui.id, ui.created_at, ip.duration_days 
        FROM user_investments ui
        JOIN investment_products ip ON ui.product_id = ip.id
        WHERE ui.maturity_date IS NULL
    ");
    
    $investments = $stmt->fetchAll(PDO::FETCH_ASSOC);
    foreach ($investments as $inv) {
        $maturityDate = date('Y-m-d', strtotime($inv['created_at'] . ' + ' . $inv['duration_days'] . ' days'));
        $updateStmt = $conn->prepare("UPDATE user_investments SET maturity_date = ? WHERE id = ?");
        $updateStmt->execute([$maturityDate, $inv['id']]);
    }
    echo "✓ Set maturity dates for " . count($investments) . " investments\n";
    
    echo "\n✅ Investment management schema updated successfully!\n";
    
} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
?>
