<?php
/**
 * Local Profit Diagnostic Test
 * Run this directly to diagnose profit calculation issues
 */

require_once __DIR__ . '/../../config/database.php';

$db = Database::getInstance();
$conn = $db->getConnection();

echo "=== PROFIT CALCULATION DIAGNOSTIC ===\n";
echo "Date: " . date('Y-m-d H:i:s') . "\n\n";

// 1. Check active investments
echo "1. ACTIVE INVESTMENTS:\n";
echo str_repeat("-", 100) . "\n";

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
        DATEDIFF(ui.maturity_date, CURDATE()) as days_to_maturity,
        u.phone
    FROM user_investments ui
    JOIN investment_products ip ON ui.product_id = ip.id
    JOIN users u ON ui.user_id = u.id
    WHERE ui.status = 'active'
    ORDER BY ui.id
");

$investments = $stmt->fetchAll(PDO::FETCH_ASSOC);

if (empty($investments)) {
    echo "❌ NO ACTIVE INVESTMENTS FOUND!\n\n";
} else {
    $eligibleCount = 0;
    
    foreach ($investments as $inv) {
        // Calculate eligibility
        $eligible = false;
        $reason = "";
        $dailyProfit = 0;

        if ($inv['roi_frequency'] == 'daily') {
            $dailyProfit = ($inv['amount'] * $inv['roi_percentage']) / 100;
            if (!$inv['last_profit_date'] || $inv['last_profit_date'] < date('Y-m-d')) {
                $eligible = true;
                $reason = "Daily profit due";
            } else {
                $reason = "Already calculated today (" . $inv['last_profit_date'] . ")";
            }
        } elseif ($inv['roi_frequency'] == 'monthly') {
            $dailyProfit = ($inv['amount'] * $inv['roi_percentage']) / 100 / 30;
            if (!$inv['last_profit_date'] || $inv['days_since_last_profit'] >= 30) {
                $eligible = true;
                $reason = "Monthly profit due (30 days passed)";
            } else {
                $reason = "Monthly profit not due yet ({$inv['days_since_last_profit']}/30 days)";
            }
        } elseif ($inv['roi_frequency'] == 'weekly') {
            $dailyProfit = ($inv['amount'] * $inv['roi_percentage']) / 100 / 7;
            if (!$inv['last_profit_date'] || $inv['days_since_last_profit'] >= 7) {
                $eligible = true;
                $reason = "Weekly profit due (7 days passed)";
            } else {
                $reason = "Weekly profit not due yet ({$inv['days_since_last_profit']}/7 days)";
            }
        }

        if ($eligible) $eligibleCount++;

        $status = $eligible ? "✅ ELIGIBLE" : "⏳ NOT DUE";
        
        echo "\n[$status] Investment #{$inv['id']}\n";
        echo "  User: {$inv['phone']} (ID: {$inv['user_id']})\n";
        echo "  Product: {$inv['product_name']}\n";
        echo "  Amount: ₹" . number_format($inv['amount'], 2) . "\n";
        echo "  ROI: {$inv['roi_percentage']}% ({$inv['roi_frequency']})\n";
        echo "  Created: {$inv['created_at']}\n";
        echo "  Maturity: {$inv['maturity_date']} ({$inv['days_to_maturity']} days left)\n";
        echo "  Last Profit: " . ($inv['last_profit_date'] ?: 'NEVER') . "\n";
        echo "  Days Since Last: " . ($inv['days_since_last_profit'] ?: 'N/A') . "\n";
        echo "  Total Earned: ₹" . number_format($inv['total_profit_earned'], 2) . "\n";
        echo "  Daily Profit: ₹" . number_format($dailyProfit, 2) . "\n";
        echo "  Reason: $reason\n";
    }
    
    echo "\n" . str_repeat("-", 100) . "\n";
    echo "SUMMARY: " . count($investments) . " active investments, $eligibleCount eligible for profit\n\n";
}

// 2. Check recent profit distributions
echo "\n2. RECENT PROFIT DISTRIBUTIONS (Last 10):\n";
echo str_repeat("-", 100) . "\n";

$stmt = $conn->query("
    SELECT 
        ip.id,
        ip.investment_id,
        ip.user_id,
        ip.amount,
        ip.profit_date,
        ip.credited_to,
        ip.created_at,
        u.phone
    FROM investment_profits ip
    JOIN users u ON ip.user_id = u.id
    ORDER BY ip.created_at DESC
    LIMIT 10
");

$profits = $stmt->fetchAll(PDO::FETCH_ASSOC);

if (empty($profits)) {
    echo "❌ NO PROFIT DISTRIBUTIONS FOUND!\n\n";
} else {
    foreach ($profits as $profit) {
        echo "\nProfit #{$profit['id']}\n";
        echo "  Investment: #{$profit['investment_id']}\n";
        echo "  User: {$profit['phone']} (ID: {$profit['user_id']})\n";
        echo "  Amount: ₹" . number_format($profit['amount'], 2) . "\n";
        echo "  Date: {$profit['profit_date']}\n";
        echo "  Credited To: {$profit['credited_to']}\n";
        echo "  Created: {$profit['created_at']}\n";
    }
    echo "\n";
}

// 3. Check wallet balances
echo "\n3. WALLET BALANCES:\n";
echo str_repeat("-", 100) . "\n";

$stmt = $conn->query("
    SELECT 
        w.user_id,
        w.e_wallet_balance,
        w.earnings_balance,
        w.total_earned,
        u.phone
    FROM wallets w
    JOIN users u ON w.user_id = u.id
    WHERE w.total_earned > 0 OR w.earnings_balance > 0
");

$wallets = $stmt->fetchAll(PDO::FETCH_ASSOC);

if (empty($wallets)) {
    echo "No wallets with earnings found.\n\n";
} else {
    foreach ($wallets as $wallet) {
        echo "\nUser: {$wallet['phone']} (ID: {$wallet['user_id']})\n";
        echo "  E-Wallet: ₹" . number_format($wallet['e_wallet_balance'], 2) . "\n";
        echo "  Earnings: ₹" . number_format($wallet['earnings_balance'], 2) . "\n";
        echo "  Total Earned: ₹" . number_format($wallet['total_earned'], 2) . "\n";
    }
    echo "\n";
}

echo "\n=== DIAGNOSTIC COMPLETE ===\n";
?>
