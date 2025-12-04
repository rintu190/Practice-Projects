<?php
require_once __DIR__ . '/../config/database.php';

class CommissionCalculator {
    private $db;
    private $conn;
    private $commissionRules = [];

    public function __construct() {
        $this->db = Database::getInstance();
        $this->conn = $this->db->getConnection();
        $this->loadCommissionRules();
    }

    private function loadCommissionRules() {
        try {
            $stmt = $this->conn->query("SELECT * FROM commission_rules WHERE is_active = 1");
            $rules = $stmt->fetchAll(PDO::FETCH_ASSOC);
            
            foreach ($rules as $rule) {
                $type = $rule['type'];
                $level = $rule['level'];
                
                if ($type === 'direct') {
                    $this->commissionRules['direct'] = floatval($rule['percentage']);
                } elseif ($type === 'level' && $level) {
                    $this->commissionRules['level'][$level] = floatval($rule['percentage']);
                } elseif ($type === 'matching') {
                    $this->commissionRules['matching'] = floatval($rule['percentage']);
                }
            }
        } catch (Exception $e) {
            error_log("Failed to load commission rules: " . $e->getMessage());
            // Fallback to default rates if database fails
            $this->commissionRules = [
                'direct' => 5.0,
                'level' => [1 => 3.0, 2 => 2.0, 3 => 1.0, 4 => 0.5, 5 => 0.5],
                'matching' => 10.0
            ];
        }
    }

    private function getDirectRate() {
        return $this->commissionRules['direct'] ?? 5.0;
    }

    private function getLevelRate($level) {
        return $this->commissionRules['level'][$level] ?? 0.0;
    }

    private function getMatchingRate() {
        return $this->commissionRules['matching'] ?? 0.0;
    }

    public function distributeCommissions($investorId, $amount, $investmentId) {
        try {
            $this->conn->beginTransaction();

            // 1. Direct Referral Commission
            $this->processDirectReferral($investorId, $amount, $investmentId);

            // 2. Level Income (Unilevel)
            $this->processLevelIncome($investorId, $amount, $investmentId);

            $this->conn->commit();
            return true;

        } catch (Exception $e) {
            $this->conn->rollBack();
            error_log("Commission distribution failed: " . $e->getMessage());
            return false;
        }
    }

    private function processDirectReferral($userId, $amount, $investmentId) {
        // Get Sponsor
        $stmt = $this->conn->prepare("SELECT sponsor_id FROM genealogy WHERE user_id = ?");
        $stmt->execute([$userId]);
        $sponsorId = $stmt->fetchColumn();

        if ($sponsorId) {
            $directRate = $this->getDirectRate();
            $commission = ($amount * $directRate) / 100;
            
            if ($commission > 0) {
                $this->creditCommission(
                    $sponsorId, 
                    $userId, 
                    $commission, 
                    'direct_sponsor', 
                    $investmentId, 
                    "Direct referral commission from user $userId"
                );
            }
        }
    }

    private function processLevelIncome($userId, $amount, $investmentId) {
        $currentUserId = $userId;
        $level = 1;
        $maxLevels = 5; // Maximum levels to process
        
        while ($level <= $maxLevels) {
            // Get Upline
            $stmt = $this->conn->prepare("SELECT sponsor_id FROM genealogy WHERE user_id = ?");
            $stmt->execute([$currentUserId]);
            $uplineId = $stmt->fetchColumn();

            if (!$uplineId) break; // No more upline

            // Skip Level 1 as it is covered by Direct Referral Bonus
            if ($level === 1) {
                $currentUserId = $uplineId;
                $level++;
                continue;
            }

            $rate = $this->getLevelRate($level);
            if ($rate <= 0) {
                $currentUserId = $uplineId;
                $level++;
                continue; // Skip if no rate defined for this level
            }

            $commission = ($amount * $rate) / 100;
            
            if ($commission > 0) {
                $this->creditCommission(
                    $uplineId, 
                    $userId, 
                    $commission, 
                    'level_bonus', 
                    $investmentId, 
                    "Level $level bonus from user $userId",
                    $level
                );
            }

            $currentUserId = $uplineId; // Move up
            $level++;
        }
    }

    /**
     * Process Matching Bonus
     * When a user earns a commission, their sponsor gets a percentage of that commission
     * 
     * @param int $userId The user who earned the commission
     * @param float $commissionAmount The commission amount earned
     * @param int $investmentId Reference investment ID
     */
    public function processMatchingBonus($userId, $commissionAmount, $investmentId) {
        $matchingRate = $this->getMatchingRate();
        
        if ($matchingRate <= 0) {
            return; // Matching bonus not active
        }

        try {
            // Get the sponsor of the user who earned the commission
            $stmt = $this->conn->prepare("SELECT sponsor_id FROM genealogy WHERE user_id = ?");
            $stmt->execute([$userId]);
            $sponsorId = $stmt->fetchColumn();

            if ($sponsorId) {
                $matchingBonus = ($commissionAmount * $matchingRate) / 100;
                
                if ($matchingBonus > 0) {
                    $this->creditCommission(
                        $sponsorId, 
                        $userId, 
                        $matchingBonus, 
                        'matching_bonus', 
                        $investmentId, 
                        "Matching bonus on commission earned by user $userId"
                    );
                }
            }
        } catch (Exception $e) {
            error_log("Matching bonus processing failed: " . $e->getMessage());
        }
    }


    private function creditCommission($userId, $fromUserId, $amount, $type, $refId, $desc, $level = null) {
        // 1. Add to Earnings Balance (not e-wallet)
        $stmt = $this->conn->prepare("
            UPDATE wallets 
            SET earnings_balance = earnings_balance + ?, 
                total_earned = total_earned + ? 
            WHERE user_id = ?
        ");
        $stmt->execute([$amount, $amount, $userId]);

        // 2. Record Commission
        $commStmt = $this->conn->prepare("
            INSERT INTO commissions (
                user_id, from_user_id, commission_type, amount, 
                percentage, level, reference_type, reference_id, description, status
            ) VALUES (?, ?, ?, ?, ?, ?, 'investment', ?, ?, 'paid')
        ");
        // Calculate percentage for record
        $percentage = 0;
        if ($type == 'direct_sponsor') $percentage = $this->getDirectRate();
        elseif ($type == 'level_bonus' && $level) $percentage = $this->getLevelRate($level);
        elseif ($type == 'matching_bonus') $percentage = $this->getMatchingRate();

        $commStmt->execute([
            $userId, $fromUserId, $type, $amount, 
            $percentage, $level, $refId, $desc
        ]);

        // 3. Get user details for better description
        $userStmt = $this->conn->prepare("SELECT phone FROM users WHERE id = ?");
        $userStmt->execute([$fromUserId]);
        $userPhone = $userStmt->fetchColumn();
        
        // Create user-friendly description
        $transactionDesc = $desc;
        if ($type == 'direct_sponsor') {
            $transactionDesc = "💰 Referral Commission from " . ($userPhone ?: "User #$fromUserId");
        } elseif ($type == 'level_bonus' && $level) {
            $transactionDesc = "🎁 Level $level Bonus from " . ($userPhone ?: "User #$fromUserId");
        } elseif ($type == 'matching_bonus') {
            $transactionDesc = "🤝 Matching Bonus from " . ($userPhone ?: "User #$fromUserId");
        }

        // 4. Record Transaction (to earnings, not e-wallet)
        // Get current earnings balance for balance_after
        $balStmt = $this->conn->prepare("SELECT earnings_balance FROM wallets WHERE user_id = ?");
        $balStmt->execute([$userId]);
        $currentBalance = $balStmt->fetchColumn();

        $transStmt = $this->conn->prepare("
            INSERT INTO transactions (
                user_id, wallet_type, type, amount, 
                description, balance_before, balance_after, status, created_at
            ) VALUES (?, 'earnings', 'credit', ?, ?, ?, ?, 'completed', NOW())
        ");
        
        $balanceBefore = $currentBalance - $amount; // Since we already updated the wallet
        $transStmt->execute([$userId, $amount, $transactionDesc, $balanceBefore, $currentBalance]);

        // 5. Trigger Matching Bonus (Recursive but limited)
        // Only pay matching bonus on primary commissions (direct, level, roi), not on matching bonuses
        if ($type !== 'matching_bonus') {
            $this->processMatchingBonus($userId, $amount, $refId);
        }
    }
}
?>
