<?php
/**
 * Insert Dummy Wallet and Transaction Data
 * 
 * This script creates test users with wallet balances and transactions
 * so you can verify the dashboard and wallet features work correctly.
 */

require_once __DIR__ . '/config/config.php';
require_once __DIR__ . '/config/database.php';

try {
    $db = Database::getInstance()->getConnection();
    
    echo "🔧 Starting wallet data insertion...\n\n";
    
    // 1. Create a test user (if not exists)
    echo "📱 Creating test user...\n";
    $phone = '9876543210';
    
    $userCheck = $db->prepare("SELECT id FROM users WHERE phone = ?");
    $userCheck->execute([$phone]);
    $existing = $userCheck->fetch();
    
    if (!$existing) {
        $db->prepare("
            INSERT INTO users (phone, password_hash, referral_code, status, kyc_status, is_admin)
            VALUES (?, ?, ?, 'active', 'approved', FALSE)
        ")->execute([
            $phone,
            password_hash('password123', PASSWORD_BCRYPT),
            'REF' . strtoupper(uniqid())
        ]);
        echo "✓ Test user created with phone: $phone\n";
    } else {
        echo "✓ Test user already exists with phone: $phone\n";
    }
    
    // Get user ID
    $userResult = $db->prepare("SELECT id FROM users WHERE phone = ?");
    $userResult->execute([$phone]);
    $userId = $userResult->fetch()['id'];
    
    // 2. Create/Update User Profile
    echo "📋 Creating user profile...\n";
    $db->prepare("
        INSERT INTO user_profiles (user_id, full_name, date_of_birth, gender, address, city, state, pincode)
        VALUES (?, 'Test User', '1990-01-15', 'male', '123 Main St', 'New York', 'NY', '10001')
        ON DUPLICATE KEY UPDATE 
            full_name = 'Test User',
            address = '123 Main St',
            city = 'New York',
            state = 'NY',
            pincode = '10001'
    ")->execute([$userId]);
    echo "✓ User profile created\n";
    
    // 3. Create/Update E-Wallet (regular wallet)
    echo "💳 Creating E-Wallet with balance 100,000...\n";
    $db->prepare("
        INSERT INTO wallets (user_id, e_wallet_balance, investment_wallet_balance, total_earned, total_withdrawn)
        VALUES (?, 100000.00, 50000.00, 125000.00, 25000.00)
        ON DUPLICATE KEY UPDATE 
            e_wallet_balance = 100000.00,
            investment_wallet_balance = 50000.00,
            total_earned = 125000.00,
            total_withdrawn = 25000.00
    ")->execute([$userId]);
    echo "✓ E-Wallet created: Balance = ₹100,000, Total Earned = ₹125,000\n";
    
    // 4. Create/Update Investment Wallet (same table, different column)
    echo "💰 Investment Wallet balance already set with E-Wallet: ₹50,000\n";
    
    // 5. Insert sample transactions
    echo "📊 Inserting sample transactions...\n";
    
    $transactions = [
        ['credit', 'commission', 'commission', 2500.00, 'Direct Sponsor Commission', 'completed'],
        ['credit', 'bonus', 'bonus', 5000.00, 'Monthly Rank Bonus', 'completed'],
        ['debit', 'withdrawal', 'withdrawal', 10000.00, 'Withdrawal to Bank', 'completed'],
        ['credit', 'profit', 'profit', 3500.00, 'Investment Profit (Daily ROI)', 'completed'],
        ['credit', 'commission', 'commission', 1500.00, 'Team Performance Bonus', 'completed'],
        ['debit', 'investment', 'investment', 15000.00, 'Investment Purchase', 'completed'],
        ['credit', 'deposit', 'deposit', 25000.00, 'Wallet Top-up', 'completed'],
        ['credit', 'commission', 'commission', 3000.00, 'Level Bonus (Level 2)', 'pending'],
    ];
    
    // Delete existing transactions for this user (optional - comment out to keep history)
    // $db->prepare("DELETE FROM transactions WHERE user_id = ?")->execute([$userId]);
    
    foreach ($transactions as $tx) {
        [$txType, $category, $refType, $amount, $description, $status] = $tx;
        
        $balanceBefore = $txType === 'credit' ? 97500.00 : 102500.00;
        $balanceAfter = $txType === 'credit' ? $balanceBefore + $amount : $balanceBefore - $amount;
        
        try {
            $db->prepare("
                INSERT INTO transactions (user_id, wallet_type, transaction_type, amount, category, description, status, balance_before, balance_after)
                VALUES (?, 'e_wallet', ?, ?, ?, ?, ?, ?, ?)
            ")->execute([
                $userId,
                $txType,
                $amount,
                $category,
                $description,
                $status,
                $balanceBefore,
                $balanceAfter
            ]);
        } catch (Exception $e) {
            echo "⚠️  Transaction insertion error (might be duplicate): " . $e->getMessage() . "\n";
        }
    }
    echo "✓ Sample transactions inserted\n";
    
    echo "\n✅ Wallet data insertion completed successfully!\n";
    echo "\n📱 Test Account Details:\n";
    echo "   Phone: $phone\n";
    echo "   Password: password123\n";
    echo "   E-Wallet Balance: ₹100,000\n";
    echo "   Investment Wallet: ₹50,000\n";
    echo "   Total Earned: ₹125,000\n\n";
    echo "🚀 You can now login with this account and see the dashboard data!\n";
    
} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
?>
