<?php
/**
 * Sync total_profit_earned in user_investments from daily_pnl table
 * This script aggregates all P&L data and updates the user_investments table
 */

require_once __DIR__ . '/config/database.php';

try {
    $conn = Database::getInstance()->getConnection();
    $conn->beginTransaction();
    
    echo "=== Syncing total_profit_earned from daily_pnl ===\n\n";
    
    // Get all investments
    $stmt = $conn->query("SELECT id, user_id FROM user_investments");
    $investments = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    $updated = 0;
    $skipped = 0;
    
    foreach ($investments as $investment) {
        $investmentId = $investment['id'];
        
        // Calculate total profit from daily_pnl for this investment
        $pnlStmt = $conn->prepare("
            SELECT 
                SUM(net_pnl) as total_profit,
                MAX(pnl_date) as last_profit_date
            FROM daily_pnl 
            WHERE investment_id = ?
        ");
        $pnlStmt->execute([$investmentId]);
        $pnlData = $pnlStmt->fetch(PDO::FETCH_ASSOC);
        
        $totalProfit = (float)($pnlData['total_profit'] ?? 0);
        $lastProfitDate = $pnlData['last_profit_date'];
        
        if ($totalProfit > 0 || $lastProfitDate) {
            // Update user_investments
            $updateStmt = $conn->prepare("
                UPDATE user_investments 
                SET total_profit_earned = ?,
                    last_profit_date = ?
                WHERE id = ?
            ");
            $updateStmt->execute([$totalProfit, $lastProfitDate, $investmentId]);
            
            echo "Investment ID $investmentId: Updated total_profit_earned = ₹" . number_format($totalProfit, 2) . 
                 " (last profit: $lastProfitDate)\n";
            $updated++;
        } else {
            $skipped++;
        }
    }
    
    $conn->commit();
    
    echo "\n=== Sync Complete ===\n";
    echo "Updated: $updated investments\n";
    echo "Skipped: $skipped investments (no P&L data)\n";
    
    // Show summary
    echo "\n=== Summary ===\n";
    $summaryStmt = $conn->query("
        SELECT 
            COUNT(*) as total_investments,
            SUM(amount) as total_invested,
            SUM(total_profit_earned) as total_profit
        FROM user_investments
    ");
    $summary = $summaryStmt->fetch(PDO::FETCH_ASSOC);
    
    echo "Total Investments: {$summary['total_investments']}\n";
    echo "Total Invested: ₹" . number_format($summary['total_invested'], 2) . "\n";
    echo "Total Profit Earned: ₹" . number_format($summary['total_profit'], 2) . "\n";
    
} catch (Exception $e) {
    if ($conn->inTransaction()) {
        $conn->rollBack();
    }
    echo "Error: " . $e->getMessage() . "\n";
    exit(1);
}
