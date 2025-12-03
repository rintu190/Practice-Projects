<?php
require_once __DIR__ . '/../config/database.php';

class ProfitCalculator {
    private $db;
    private $conn;

    public function __construct() {
        $this->db = Database::getInstance();
        $this->conn = $this->db->getConnection();
    }

    /**
     * Calculate profit for a single investment based on ROI frequency
     */
    public function calculateProfit($investmentId) {
        // Get investment details
        $stmt = $this->conn->prepare("
            SELECT ui.*, ip.roi_percentage, ip.roi_frequency, ip.compound_interest, ip.duration_days
            FROM user_investments ui
            JOIN investment_products ip ON ui.product_id = ip.id
            WHERE ui.id = ? AND ui.status = 'active'
        ");
        $stmt->execute([$investmentId]);
        $investment = $stmt->fetch(PDO::FETCH_ASSOC);

        if (!$investment) {
            return null;
        }

        $amount = $investment['amount'];
        $roiPercentage = $investment['roi_percentage'];
        $frequency = $investment['roi_frequency'];
        $compoundInterest = $investment['compound_interest'];
        $totalProfitEarned = $investment['total_profit_earned'] ?? 0;

        switch ($frequency) {
            case 'daily':
                return $this->calculateDailyProfit($amount, $roiPercentage, $totalProfitEarned, $compoundInterest);
            case 'weekly':
                return $this->calculateWeeklyProfit($amount, $roiPercentage, $totalProfitEarned, $compoundInterest);
            case 'bi-weekly':
                return $this->calculateBiWeeklyProfit($amount, $roiPercentage, $totalProfitEarned, $compoundInterest);
            case 'monthly':
                return $this->calculateMonthlyProfit($amount, $roiPercentage, $totalProfitEarned, $compoundInterest);
            case 'quarterly':
                return $this->calculateQuarterlyProfit($amount, $roiPercentage, $totalProfitEarned, $compoundInterest);
            case 'maturity':
                return $this->calculateMaturityProfit($amount, $roiPercentage, $investment['duration_days']);
            default:
                return 0;
        }
    }

    private function calculateDailyProfit($amount, $roiPercentage, $totalEarned, $compound) {
        if ($compound) {
            // Compound: profit on (principal + accumulated profit)
            $base = $amount + $totalEarned;
        } else {
            // Simple: profit only on principal
            $base = $amount;
        }
        return ($base * $roiPercentage) / 100;
    }

    private function calculateWeeklyProfit($amount, $roiPercentage, $totalEarned, $compound) {
        // Weekly ROI divided by 7 for daily distribution
        return $this->calculateDailyProfit($amount, $roiPercentage / 7, $totalEarned, $compound);
    }

    private function calculateMonthlyProfit($amount, $roiPercentage, $totalEarned, $compound) {
        // Monthly ROI divided by 30 for daily distribution
        return $this->calculateDailyProfit($amount, $roiPercentage / 30, $totalEarned, $compound);
    }

    private function calculateBiWeeklyProfit($amount, $roiPercentage, $totalEarned, $compound) {
        // Bi-weekly (14 days) ROI divided by 14 for daily distribution
        return $this->calculateDailyProfit($amount, $roiPercentage / 14, $totalEarned, $compound);
    }

    private function calculateQuarterlyProfit($amount, $roiPercentage, $totalEarned, $compound) {
        // Quarterly (90 days) ROI divided by 90 for daily distribution
        return $this->calculateDailyProfit($amount, $roiPercentage / 90, $totalEarned, $compound);
    }

    private function calculateMaturityProfit($amount, $roiPercentage, $durationDays) {
        // Total profit at maturity
        return ($amount * $roiPercentage) / 100;
    }

    /**
 * Distribute profit to user's wallet (always e_wallet now)
 */
public function distributeProfit($investmentId, $userId, $profitAmount, $creditTo = 'e_wallet') {
    try {
        $this->conn->beginTransaction();

        // Record profit
        $stmt = $this->conn->prepare("
            INSERT INTO investment_profits (investment_id, user_id, amount, profit_date, credited_to)
            VALUES (?, ?, ?, CURDATE(), 'e_wallet')
        ");
        $stmt->execute([$investmentId, $userId, $profitAmount]);

        // Update total profit earned
        $stmt = $this->conn->prepare("
            UPDATE user_investments 
            SET total_profit_earned = total_profit_earned + ?,
                last_profit_date = CURDATE()
            WHERE id = ?
        ");
        $stmt->execute([$profitAmount, $investmentId]);

        // Credit to e_wallet (only one wallet now)
    $stmt = $this->conn->prepare("
        UPDATE wallets 
        SET e_wallet_balance = e_wallet_balance + ?
        WHERE user_id = ?
    ");
    $stmt->execute([$profitAmount, $userId]);

    // Get investment product name for better description
    $productStmt = $this->conn->prepare("
        SELECT ip.name 
        FROM user_investments ui
        JOIN investment_products ip ON ui.product_id = ip.id
        WHERE ui.id = ?
    ");
    $productStmt->execute([$investmentId]);
    $productName = $productStmt->fetchColumn();
    
    $description = "📈 Investment Profit" . ($productName ? " - $productName" : " #$investmentId");

    // Create transaction record
    $stmt = $this->conn->prepare("
        INSERT INTO transactions (
            user_id, wallet_type, type, amount, 
            description, reference_type, reference_id, created_at
        ) VALUES (?, 'e_wallet', 'credit', ?, ?, 'investment_profit', ?, NOW())
    ");
    $stmt->execute([
        $userId,
        $profitAmount,
        $description,
        $investmentId
    ]);

        $this->conn->commit();
        return true;
    } catch (Exception $e) {
        $this->conn->rollBack();
        throw $e;
    }
}

    /**
     * Process matured investments
     */
    public function processMaturedInvestments() {
        $stmt = $this->conn->query("
            SELECT ui.*, ip.roi_percentage, ip.roi_frequency
            FROM user_investments ui
            JOIN investment_products ip ON ui.product_id = ip.id
            WHERE ui.status = 'active' 
            AND ui.maturity_date <= CURDATE()
        ");

        $maturedInvestments = $stmt->fetchAll(PDO::FETCH_ASSOC);
        $processed = 0;

        foreach ($maturedInvestments as $investment) {
            try {
                $this->conn->beginTransaction();

                // Calculate final profit if maturity-based
                if ($investment['roi_frequency'] === 'maturity') {
                    $profit = $this->calculateMaturityProfit(
                        $investment['amount'],
                        $investment['roi_percentage'],
                        0
                    );
                    $this->distributeProfit(
                        $investment['id'],
                        $investment['user_id'],
                        $profit,
                        'investment_wallet'
                    );
                }

                // Check auto-renew
                if ($investment['auto_renew']) {
                    // Create new investment with principal + profit
                    $newAmount = $investment['amount'] + $investment['total_profit_earned'];
                    $stmt = $this->conn->prepare("
                        INSERT INTO user_investments (user_id, product_id, amount, created_at, maturity_date, auto_renew, status)
                        SELECT user_id, product_id, ?, NOW(), 
                               DATE_ADD(NOW(), INTERVAL ? DAY), auto_renew, 'active'
                        FROM user_investments WHERE id = ?
                    ");
                    $stmt->execute([$newAmount, $investment['duration_days'], $investment['id']]);

                    // Mark old investment as renewed
                    $stmt = $this->conn->prepare("UPDATE user_investments SET status = 'renewed' WHERE id = ?");
                    $stmt->execute([$investment['id']]);
                } else {
                    // Return principal to wallet (profit already distributed)
                    $principal = $investment['amount'];
                    $stmt = $this->conn->prepare("
                        UPDATE investment_wallets 
                        SET balance = balance + ?
                        WHERE user_id = ?
                    ");
                    $stmt->execute([$principal, $investment['user_id']]);

                    // Log transaction
                    $stmt = $this->conn->prepare("
                        INSERT INTO transactions (
                            user_id, wallet_type, type, amount, 
                            description, reference_type, reference_id, created_at
                        ) VALUES (?, 'investment_wallet', 'credit', ?, 'Principal Return', 'investment_maturity', ?, NOW())
                    ");
                    $stmt->execute([$investment['user_id'], $principal, $investment['id']]);

                    // Mark as matured
                    $stmt = $this->conn->prepare("UPDATE user_investments SET status = 'matured' WHERE id = ?");
                    $stmt->execute([$investment['id']]);
                }

                $this->conn->commit();
                $processed++;
            } catch (Exception $e) {
                $this->conn->rollBack();
                error_log("Error processing matured investment {$investment['id']}: " . $e->getMessage());
            }
        }

        return $processed;
    }
}
?>
