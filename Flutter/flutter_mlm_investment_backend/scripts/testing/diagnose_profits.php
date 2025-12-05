<?php
/**
 * Profit Calculation Diagnostic Script
 * Checks why profits are not being generated
 */

require_once __DIR__ . '/../config/database.php';

$db = Database::getInstance();
$conn = $db->getConnection();

echo "=== PROFIT CALCULATION DIAGNOSTIC ===\n\n";

// 1. Check active investments
echo "1. ACTIVE INVESTMENTS:\n";
echo str_repeat("-", 80) . "\n";

$stmt = $conn->query("
    SELECT 
        ui.id,
        ui.user_id,
        ui.amount,
        ui.created_at,
        ui.maturity_date,
        ui.last_profit_date,
        ui.total_profit_earned,
        ui.status,
        ip.name as product_name,
        ip.roi_percentage,
        ip.roi_frequency,
        DATEDIFF(CURDATE(), ui.last_profit_date) as days_since_last_profit,
        DATEDIFF(ui.maturity_date, CURDATE()) as days_to_maturity
    FROM user_investments ui
    JOIN investment_products ip ON ui.product_id = ip.id
    WHERE ui.status = 'active'
    ORDER BY ui.id
");

$investments = $stmt->fetchAll(PDO::FETCH_ASSOC);

if (empty($investments)) {
    echo "❌ NO ACTIVE INVESTMENTS FOUND!\n\n";
} else {
    foreach ($investments as $inv) {
        echo "Investment ID: {$inv['id']}\n";
        echo "  User ID: {$inv['user_id']}\n";
        echo "  Product: {$inv['product_name']}\n";
        echo "  Amount: ₹{$inv['amount']}\n";
        echo "  ROI: {$inv['roi_percentage']}% ({$inv['roi_frequency']})\n";
        echo "  Created: {$inv['created_at']}\n";
        echo "  Maturity: {$inv['maturity_date']} ({$inv['days_to_maturity']} days left)\n";
        echo "  Last Profit: " . ($inv['last_profit_date'] ?: 'NEVER') . "\n";
        echo "  Days Since Last Profit: " . ($inv['days_since_last_profit'] ?: 'N/A') . "\n";
        echo "  Total Earned: ₹{$inv['total_profit_earned']}\n";
        
        // Check if eligible for profit
        $eligible = false;
        $reason = "";
        
        if ($inv['roi_frequency'] == 'daily') {
            if (!$inv['last_profit_date'] || $inv['last_profit_date'] < date('Y-m-d')) {
                $eligible = true;
                $reason = "Daily profit due";
            } else {
                $reason = "Already calculated today";
            }
        } elseif ($inv['roi_frequency'] == 'monthly') {
            if (!$inv['last_profit_date'] || $inv['days_since_last_profit'] >= 30) {
                $eligible = true;
                $reason = "Monthly profit due";
            } else {
                $reason = "Monthly profit not due yet (need 30 days)";
            }
        } elseif ($inv['roi_frequency'] == 'weekly') {
            if (!$inv['last_profit_date'] || $inv['days_since_last_profit'] >= 7) {
                $eligible = true;
                $reason = "Weekly profit due";
            } else {
                $reason = "Weekly profit not due yet (need 7 days)";
            }
        }
        
        echo "  ✅ ELIGIBLE: " . ($eligible ? "YES - $reason" : "NO - $reason") . "\n";
        echo "\n";
    }
}

// 2. Check recent profit distributions
echo "\n2. RECENT PROFIT DISTRIBUTIONS (Last 10):\n";
echo str_repeat("-", 80) . "\n";

$stmt = $conn->query("
    SELECT 
        ip.id,
        ip.investment_id,
        ip.user_id,
        ip.amount,
        ip.profit_date,
        ip.credited_to,
        ip.created_at
    FROM investment_profits ip
    ORDER BY ip.created_at DESC
    LIMIT 10
");

$profits = $stmt->fetchAll(PDO::FETCH_ASSOC);

if (empty($profits)) {
    echo "❌ NO PROFIT DISTRIBUTIONS FOUND!\n\n";
} else {
    foreach ($profits as $profit) {
        echo "Profit ID: {$profit['id']}\n";
        echo "  Investment: #{$profit['investment_id']}\n";
        echo "  User: #{$profit['user_id']}\n";
        echo "  Amount: ₹{$profit['amount']}\n";
        echo "  Date: {$profit['profit_date']}\n";
        echo "  Credited To: {$profit['credited_to']}\n";
        echo "  Created: {$profit['created_at']}\n\n";
    }
}

// 3. Check wallet balances
echo "\n3. WALLET BALANCES:\n";
echo str_repeat("-", 80) . "\n";

$stmt = $conn->query("
    SELECT 
        w.user_id,
        w.e_wallet_balance,
        w.earnings_balance,
        w.total_earned,
        u.phone
    FROM wallets w
    JOIN users u ON w.user_id = u.id
    WHERE w.earnings_balance > 0 OR w.total_earned > 0
");

$wallets = $stmt->fetchAll(PDO::FETCH_ASSOC);

foreach ($wallets as $wallet) {
    echo "User #{$wallet['user_id']} ({$wallet['phone']}):\n";
    echo "  E-Wallet: ₹{$wallet['e_wallet_balance']}\n";
    echo "  Earnings: ₹{$wallet['earnings_balance']}\n";
    echo "  Total Earned: ₹{$wallet['total_earned']}\n\n";
}

// 4. Simulate profit calculation
echo "\n4. SIMULATED PROFIT CALCULATION:\n";
echo str_repeat("-", 80) . "\n";

foreach ($investments as $inv) {
    $amount = $inv['amount'];
    $roiPercentage = $inv['roi_percentage'];
    $frequency = $inv['roi_frequency'];
    
    $dailyProfit = 0;
    
    switch ($frequency) {
        case 'daily':
            $dailyProfit = ($amount * $roiPercentage) / 100;
            break;
        case 'monthly':
            $dailyProfit = ($amount * $roiPercentage) / 100 / 30;
            break;
        case 'weekly':
            $dailyProfit = ($amount * $roiPercentage) / 100 / 7;
            break;
    }
    
    echo "Investment #{$inv['id']} ({$inv['product_name']}):\n";
    echo "  Principal: ₹{$amount}\n";
    echo "  ROI: {$roiPercentage}% {$frequency}\n";
    echo "  Calculated Daily Profit: ₹" . number_format($dailyProfit, 2) . "\n\n";
}

echo "\n=== DIAGNOSTIC COMPLETE ===\n";
?>
