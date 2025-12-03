<?php
require_once __DIR__ . '/config/database.php';

try {
    $db = Database::getInstance();
    $conn = $db->getConnection();

    echo "Starting data seeding...\n";

    // 1. Get or Create Test User
    $phone = '9876543210';
    $stmt = $conn->prepare("SELECT id FROM users WHERE phone = ?");
    $stmt->execute([$phone]);
    $userId = $stmt->fetchColumn();

    if (!$userId) {
        // Create user
        $conn->exec("INSERT INTO users (phone, email, password_hash, referral_code, status, rank) 
                     VALUES ('9876543210', 'test@example.com', '" . password_hash('password123', PASSWORD_BCRYPT) . "', 'REF12345', 'active', 'Silver')");
        $userId = $conn->lastInsertId();
        
        // Create profile
        $conn->exec("INSERT INTO user_profiles (user_id, full_name) VALUES ($userId, 'Test User')");
        
        // Create wallet
        $conn->exec("INSERT INTO wallets (user_id, e_wallet_balance, total_earned) VALUES ($userId, 5000.00, 1500.00)");
        
        // Create investment wallet
        $conn->exec("INSERT INTO investment_wallets (user_id, balance, total_invested, total_profit) VALUES ($userId, 0.00, 10000.00, 2500.00)");
        
        echo "Created new test user (ID: $userId)\n";
    } else {
        echo "Using existing test user (ID: $userId)\n";
        
        // Update wallet balance if low
        $conn->exec("UPDATE wallets SET e_wallet_balance = 50000.00, total_earned = 15000.00 WHERE user_id = $userId");
        $conn->exec("UPDATE investment_wallets SET total_invested = 25000.00, total_profit = 5000.00 WHERE user_id = $userId");
        $conn->exec("UPDATE users SET `rank` = 'Silver' WHERE id = $userId");
    }

    // 2. Seed Investments
    // Clear existing for clean state? No, just add if empty.
    $stmt = $conn->prepare("SELECT COUNT(*) FROM user_investments WHERE user_id = ?");
    $stmt->execute([$userId]);
    if ($stmt->fetchColumn() == 0) {
        // Get a product
        $prodStmt = $conn->query("SELECT id, min_amount FROM investment_products LIMIT 1");
        $product = $prodStmt->fetch();
        
        if ($product) {
            $maturityDate = date('Y-m-d', strtotime('+30 days'));
            $roiPercentage = 1.5; // Default ROI
            $conn->exec("INSERT INTO user_investments (user_id, product_id, amount, roi_percentage, maturity_date, status) 
                         VALUES ($userId, {$product['id']}, 10000.00, $roiPercentage, '$maturityDate', 'active')");
            $investmentId = $conn->lastInsertId();
            echo "Seeded investment (ID: $investmentId)\n";
            
            // Seed Daily P&L for this investment
            for ($i = 10; $i >= 0; $i--) {
                $date = date('Y-m-d', strtotime("-$i days"));
                $profit = rand(50, 150);
                $conn->exec("INSERT IGNORE INTO daily_pnl (investment_id, user_id, product_id, pnl_date, profit_amount, net_pnl, investment_value_before, investment_value_after)
                             VALUES ($investmentId, $userId, {$product['id']}, '$date', $profit, $profit, 10000, 10000)");
            }
            echo "Seeded P&L history\n";
        }
    }

    // 3. Seed Transactions
    $stmt = $conn->prepare("SELECT COUNT(*) FROM transactions WHERE user_id = ?");
    $stmt->execute([$userId]);
    if ($stmt->fetchColumn() < 5) {
        $conn->exec("INSERT INTO transactions (user_id, wallet_type, type, amount, description, balance_before, balance_after, status, created_at)
                     VALUES 
                     ($userId, 'e_wallet', 'credit', 5000.00, 'Deposit via UPI', 0.00, 5000.00, 'completed', DATE_SUB(NOW(), INTERVAL 5 DAY)),
                     ($userId, 'e_wallet', 'debit', 1000.00, 'Investment in Starter Plan', 5000.00, 4000.00, 'completed', DATE_SUB(NOW(), INTERVAL 4 DAY)),
                     ($userId, 'e_wallet', 'credit', 200.00, 'Referral Bonus', 4000.00, 4200.00, 'completed', DATE_SUB(NOW(), INTERVAL 3 DAY)),
                     ($userId, 'e_wallet', 'credit', 50.00, 'Daily ROI', 4200.00, 4250.00, 'completed', DATE_SUB(NOW(), INTERVAL 2 DAY)),
                     ($userId, 'e_wallet', 'debit', 500.00, 'Withdrawal Request', 4250.00, 3750.00, 'pending', DATE_SUB(NOW(), INTERVAL 1 DAY))
                    ");
        echo "Seeded transactions\n";
    }

    // 4. Seed Team Members (Genealogy)
    $stmt = $conn->prepare("SELECT COUNT(*) FROM genealogy WHERE sponsor_id = ?");
    $stmt->execute([$userId]);
    if ($stmt->fetchColumn() < 3) {
        for ($i = 1; $i <= 3; $i++) {
            $downlinePhone = "987654321$i";
            // Check if exists
            $check = $conn->prepare("SELECT id FROM users WHERE phone = ?");
            $check->execute([$downlinePhone]);
            if (!$check->fetch()) {
                $conn->exec("INSERT INTO users (phone, email, password_hash, referral_code, status, referred_by) 
                             VALUES ('$downlinePhone', 'downline$i@test.com', 'hash', 'REF$i', 'active', $userId)");
                $downlineId = $conn->lastInsertId();
                $conn->exec("INSERT INTO user_profiles (user_id, full_name) VALUES ($downlineId, 'Downline User $i')");
                $conn->exec("INSERT INTO genealogy (user_id, sponsor_id, level) VALUES ($downlineId, $userId, 1)");
            }
        }
        echo "Seeded team members\n";
    }

    echo "Data seeding completed successfully!\n";

} catch (Exception $e) {
    echo "Error seeding data: " . $e->getMessage() . "\n";
}
?>
