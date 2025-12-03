<?php
/**
 * Verification script to check P&L consistency across all sources
 */

require_once __DIR__ . '/config/database.php';

try {
    $conn = Database::getInstance()->getConnection();
    
    echo "=== P&L CONSISTENCY VERIFICATION ===\n\n";
    
    // Get a sample user (user_id = 2)
    $userId = 2;
    
    echo "Checking User ID: $userId\n";
    echo str_repeat("=", 60) . "\n\n";
    
    // 1. Dashboard Calculation (from daily_pnl)
    $stmt = $conn->prepare("
        SELECT SUM(net_pnl) as total_unrealized_pnl 
        FROM daily_pnl 
        WHERE user_id = ?
    ");
    $stmt->execute([$userId]);
    $dashboardPnl = $stmt->fetch(PDO::FETCH_ASSOC);
    $dashboardTotal = (float)($dashboardPnl['total_unrealized_pnl'] ?? 0);
    
    echo "1. DASHBOARD (from daily_pnl table):\n";
    echo "   Total Unrealized P&L: ₹" . number_format($dashboardTotal, 2) . "\n\n";
    
    // 2. Investment Summary (from user_investments)
    $stmt = $conn->prepare("
        SELECT 
            SUM(amount) as total_invested,
            SUM(total_profit_earned) as total_profit
        FROM user_investments 
        WHERE user_id = ? AND status = 'active'
    ");
    $stmt->execute([$userId]);
    $investmentSummary = $stmt->fetch(PDO::FETCH_ASSOC);
    $totalInvested = (float)($investmentSummary['total_invested'] ?? 0);
    $totalProfit = (float)($investmentSummary['total_profit'] ?? 0);
    
    echo "2. PORTFOLIO (from user_investments table):\n";
    echo "   Total Invested: ₹" . number_format($totalInvested, 2) . "\n";
    echo "   Total Profit: ₹" . number_format($totalProfit, 2) . "\n";
    echo "   Current Value: ₹" . number_format($totalInvested + $totalProfit, 2) . "\n\n";
    
    // 3. Individual Investments
    $stmt = $conn->prepare("
        SELECT 
            ui.id,
            ui.amount,
            ui.total_profit_earned,
            ip.name as product_name
        FROM user_investments ui
        JOIN investment_products ip ON ui.product_id = ip.id
        WHERE ui.user_id = ? AND ui.status = 'active'
        ORDER BY ui.id
    ");
    $stmt->execute([$userId]);
    $investments = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    echo "3. INVESTMENT HISTORY (individual investments):\n";
    $calculatedTotal = 0;
    foreach ($investments as $inv) {
        $profit = (float)$inv['total_profit_earned'];
        $calculatedTotal += $profit;
        echo "   Investment #{$inv['id']} ({$inv['product_name']}): ";
        echo "Amount: ₹" . number_format($inv['amount'], 2) . " | ";
        echo "Profit: ₹" . number_format($profit, 2) . " | ";
        echo "Current: ₹" . number_format($inv['amount'] + $profit, 2) . "\n";
    }
    echo "   ---\n";
    echo "   Total Profit (sum): ₹" . number_format($calculatedTotal, 2) . "\n\n";
    
    // 4. Daily P&L Records
    $stmt = $conn->prepare("
        SELECT COUNT(*) as record_count, SUM(net_pnl) as total_pnl
        FROM daily_pnl 
        WHERE user_id = ?
    ");
    $stmt->execute([$userId]);
    $dailyPnlSummary = $stmt->fetch(PDO::FETCH_ASSOC);
    
    echo "4. DAILY P&L SCREEN (from daily_pnl table):\n";
    echo "   Total Records: {$dailyPnlSummary['record_count']}\n";
    echo "   Total P&L: ₹" . number_format($dailyPnlSummary['total_pnl'], 2) . "\n\n";
    
    // Consistency Check
    echo str_repeat("=", 60) . "\n";
    echo "CONSISTENCY CHECK:\n";
    echo str_repeat("=", 60) . "\n\n";
    
    $isConsistent = (
        abs($dashboardTotal - $totalProfit) < 0.01 &&
        abs($totalProfit - $calculatedTotal) < 0.01 &&
        abs($calculatedTotal - $dailyPnlSummary['total_pnl']) < 0.01
    );
    
    if ($isConsistent) {
        echo "✅ ALL VALUES ARE CONSISTENT!\n\n";
        echo "Dashboard P&L:     ₹" . number_format($dashboardTotal, 2) . "\n";
        echo "Portfolio Profit:  ₹" . number_format($totalProfit, 2) . "\n";
        echo "Investment Sum:    ₹" . number_format($calculatedTotal, 2) . "\n";
        echo "Daily P&L Total:   ₹" . number_format($dailyPnlSummary['total_pnl'], 2) . "\n";
    } else {
        echo "❌ INCONSISTENCY DETECTED!\n\n";
        echo "Dashboard P&L:     ₹" . number_format($dashboardTotal, 2) . "\n";
        echo "Portfolio Profit:  ₹" . number_format($totalProfit, 2) . "\n";
        echo "Investment Sum:    ₹" . number_format($calculatedTotal, 2) . "\n";
        echo "Daily P&L Total:   ₹" . number_format($dailyPnlSummary['total_pnl'], 2) . "\n";
        echo "\nPlease run: php sync_pnl_totals.php\n";
    }
    
} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
