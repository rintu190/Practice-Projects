<?php
require_once 'config/database.php';
require_once 'utils/commission_calculator.php';

$db = Database::getInstance();
$conn = $db->getConnection();

echo "=== Testing Commission Flow with Matching Bonus ===\n";

// 1. Setup Test Users
// User A (Top) -> User B (Middle) -> User C (Investor)
$userA = 1001;
$userB = 1002;
$userC = 1003;

try {
    $conn->beginTransaction();

    // Clean up previous test data
    $conn->exec("DELETE FROM commissions WHERE user_id IN ($userA, $userB, $userC)");
    $conn->exec("DELETE FROM transactions WHERE user_id IN ($userA, $userB, $userC)");
    $conn->exec("DELETE FROM genealogy WHERE user_id IN ($userA, $userB, $userC)");
    $conn->exec("DELETE FROM wallets WHERE user_id IN ($userA, $userB, $userC)");
    $conn->exec("DELETE FROM users WHERE id IN ($userA, $userB, $userC)");

    // Create Users
    $stmt = $conn->prepare("INSERT INTO users (id, email, phone, password_hash, referral_code) VALUES (?, ?, ?, 'hash', ?)");
    $stmt->execute([$userA, 'a@test.com', '1111111111', 'REF_A']);
    $stmt->execute([$userB, 'b@test.com', '2222222222', 'REF_B']);
    $stmt->execute([$userC, 'c@test.com', '3333333333', 'REF_C']);

    // Create Wallets
    $stmt = $conn->prepare("INSERT INTO wallets (user_id, e_wallet_balance) VALUES (?, 0)");
    $stmt->execute([$userA]);
    $stmt->execute([$userB]);
    $stmt->execute([$userC]);

    // Create Genealogy
    $stmt = $conn->prepare("INSERT INTO genealogy (user_id, sponsor_id) VALUES (?, ?)");
    $stmt->execute([$userB, $userA]); // B sponsored by A
    $stmt->execute([$userC, $userB]); // C sponsored by B

    $conn->commit();
    echo "Test users created successfully.\n";

    // 2. Simulate Investment
    $investmentAmount = 10000;
    $investmentId = 999; // Dummy ID

    echo "\nSimulating investment of ₹$investmentAmount by User C...\n";
    
    $calculator = new CommissionCalculator();
    $calculator->distributeCommissions($userC, $investmentAmount, $investmentId);

    // 3. Verify Commissions
    echo "\n=== Verifying Commissions ===\n";

    // Check User B (Direct Sponsor)
    // Should get 10% Direct Referral = 1000
    $stmt = $conn->query("SELECT * FROM commissions WHERE user_id = $userB");
    $commissionsB = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "\nUser B Commissions (Expected: Direct 10% = 1000):\n";
    foreach ($commissionsB as $c) {
        echo "- {$c['commission_type']}: ₹{$c['amount']} ({$c['description']})\n";
    }

    // Check User A (Upline & Matching)
    // Should get Level 2 Bonus (3% = 300)
    // Should get Matching Bonus on B's commission (10% of 1000 = 100)
    $stmt = $conn->query("SELECT * FROM commissions WHERE user_id = $userA ORDER BY id");
    $commissionsA = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "\nUser A Commissions (Expected: Level 2 = 300, Matching = 100):\n";
    foreach ($commissionsA as $c) {
        echo "- {$c['commission_type']}: ₹{$c['amount']} ({$c['description']})\n";
    }

} catch (Exception $e) {
    $conn->rollBack();
    echo "Error: " . $e->getMessage() . "\n";
}
