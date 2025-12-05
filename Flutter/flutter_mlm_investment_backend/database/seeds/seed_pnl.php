<?php
require_once 'config/database.php';
$db = Database::getInstance();
$conn = $db->getConnection();

echo "Starting P&L Seeding...\n";

// Get user's active investments
$stmt = $conn->query('SELECT id, product_id, amount FROM user_investments WHERE user_id = 2 AND status = "active"');
$investments = $stmt->fetchAll(PDO::FETCH_ASSOC);

if (empty($investments)) {
    echo "No active investments found for user 2.\n";
    exit;
}

$totalPnl = 0;
$today = date('Y-m-d');

foreach ($investments as $inv) {
    $profit = rand(100, 300); // Random profit between 100-300
    $totalPnl += $profit;
    
    // Insert today's P&L
    // Using INSERT IGNORE to avoid duplicate key errors if run multiple times today
    $stmt = $conn->prepare("INSERT IGNORE INTO daily_pnl 
        (investment_id, user_id, product_id, pnl_date, profit_amount, net_pnl, investment_value_before, investment_value_after)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)");
    
    $stmt->execute([
        $inv['id'], 
        2, 
        $inv['product_id'], 
        $today, 
        $profit, 
        $profit, 
        $inv['amount'], 
        $inv['amount']
    ]);
    
    echo "Added P&L for investment {$inv['id']}: ₹{$profit}\n";
}

echo "Total Today's P&L: ₹{$totalPnl}\n";

// Update unrealized P&L in investment_wallets
$unrealizedPnl = rand(500, 1500); // Random unrealized P&L
$conn->exec("UPDATE investment_wallets SET unrealized_pnl = $unrealizedPnl WHERE user_id = 2");
echo "Updated Unrealized P&L: ₹{$unrealizedPnl}\n";

echo "Done!\n";
?>
