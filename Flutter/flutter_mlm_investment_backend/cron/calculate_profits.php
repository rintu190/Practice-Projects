<?php
/**
 * Cron Job: Calculate and distribute daily profits
 * Run this script daily via cron: 0 1 * * * php /path/to/calculate_profits.php
 */

require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../utils/profit_calculator.php';

echo "[" . date('Y-m-d H:i:s') . "] Starting profit calculation...\n";

try {
    $calculator = new ProfitCalculator();
    $db = Database::getInstance();
    $conn = $db->getConnection();

    // Get all active investments that need profit distribution today
    $stmt = $conn->query("
        SELECT ui.*, ip.roi_frequency
        FROM user_investments ui
        JOIN investment_products ip ON ui.product_id = ip.id
        WHERE ui.status = 'active'
        AND (
            (ip.roi_frequency = 'daily' AND (ui.last_profit_date IS NULL OR ui.last_profit_date < CURDATE()))
            OR (ip.roi_frequency = 'weekly' AND (ui.last_profit_date IS NULL OR DATEDIFF(CURDATE(), ui.last_profit_date) >= 7))
            OR (ip.roi_frequency = 'bi-weekly' AND (ui.last_profit_date IS NULL OR DATEDIFF(CURDATE(), ui.last_profit_date) >= 14))
            OR (ip.roi_frequency = 'monthly' AND (ui.last_profit_date IS NULL OR DATEDIFF(CURDATE(), ui.last_profit_date) >= 30))
            OR (ip.roi_frequency = 'quarterly' AND (ui.last_profit_date IS NULL OR DATEDIFF(CURDATE(), ui.last_profit_date) >= 90))
        )
    ");

    $investments = $stmt->fetchAll(PDO::FETCH_ASSOC);
    $processed = 0;
    $totalProfit = 0;

    foreach ($investments as $investment) {
        try {
            $profit = $calculator->calculateProfit($investment['id']);
            
            if ($profit > 0) {
                // Determine where to credit profit
                $creditTo = $investment['roi_frequency'] === 'daily' ? 'investment_wallet' : 'investment_wallet';
                
                $calculator->distributeProfit(
                    $investment['id'],
                    $investment['user_id'],
                    $profit,
                    $creditTo
                );

                $processed++;
                $totalProfit += $profit;
                echo "  ✓ Processed investment #{$investment['id']}: ₹{$profit}\n";
            }
        } catch (Exception $e) {
            echo "  ✗ Error processing investment #{$investment['id']}: " . $e->getMessage() . "\n";
        }
    }

    echo "\n[" . date('Y-m-d H:i:s') . "] Profit distribution complete\n";
    echo "  Investments processed: $processed\n";
    echo "  Total profit distributed: ₹" . number_format($totalProfit, 2) . "\n\n";

    // Process matured investments
    echo "[" . date('Y-m-d H:i:s') . "] Processing matured investments...\n";
    $matured = $calculator->processMaturedInvestments();
    echo "  Matured investments processed: $matured\n";

    echo "\n✅ All done!\n";

} catch (Exception $e) {
    echo "❌ Fatal error: " . $e->getMessage() . "\n";
    exit(1);
}
?>
