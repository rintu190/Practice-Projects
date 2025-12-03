<?php
require_once __DIR__ . '/../config/database.php';

class CommissionCalculator {
    private $db;

    public function __construct() {
        $this->db = Database::getInstance()->getConnection();
    }

    /**
     * Calculate and distribute commissions for a new investment/transaction
     */
    public function processTransactionCommissions($userId, $amount, $transactionId = null) {
        try {
            $this->db->beginTransaction();

            // 1. Direct Sponsor Bonus
            $this->distributeDirectBonus($userId, $amount);

            // 2. Level/Unilevel Bonus
            $this->distributeLevelBonus($userId, $amount);

            // 3. Rank Bonus (Check if this transaction qualifies user for new rank)
            // $this->checkRankBonus($userId);

            $this->db->commit();
            return ['success' => true, 'message' => 'Commissions processed successfully'];
        } catch (Exception $e) {
            $this->db->rollBack();
            return ['success' => false, 'message' => $e->getMessage()];
        }
    }

    private function distributeDirectBonus($userId, $amount) {
        // Get sponsor
        $stmt = $this->db->prepare("SELECT sponsor_id FROM genealogy WHERE user_id = ?");
        $stmt->execute([$userId]);
        $sponsorId = $stmt->fetchColumn();

        if (!$sponsorId) return;

        // Get rule
        $stmt = $this->db->prepare("SELECT * FROM commission_rules WHERE type = 'direct' AND is_active = 1 LIMIT 1");
        $stmt->execute();
        $rule = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($rule) {
            $bonus = 0;
            if ($rule['percentage'] > 0) {
                $bonus = ($amount * $rule['percentage']) / 100;
            } elseif ($rule['fixed_amount'] > 0) {
                $bonus = $rule['fixed_amount'];
            }

            if ($bonus > 0) {
                $this->addCommission($sponsorId, $userId, $bonus, 'direct', "Direct Referral Bonus from User #$userId");
            }
        }
    }

    private function distributeLevelBonus($userId, $amount) {
        // Get upline up to N levels
        // For simplicity, let's fetch rules first to see max level
        $stmt = $this->db->prepare("SELECT MAX(level) FROM commission_rules WHERE type = 'level' AND is_active = 1");
        $stmt->execute();
        $maxLevel = $stmt->fetchColumn() ?: 0;

        if ($maxLevel == 0) return;

        $currentUserId = $userId;
        for ($i = 1; $i <= $maxLevel; $i++) {
            // Get sponsor of current user
            $stmt = $this->db->prepare("SELECT sponsor_id FROM genealogy WHERE user_id = ?");
            $stmt->execute([$currentUserId]);
            $sponsorId = $stmt->fetchColumn();

            if (!$sponsorId) break; // No more upline

            // Get rule for this level
            $stmt = $this->db->prepare("SELECT * FROM commission_rules WHERE type = 'level' AND level = ? AND is_active = 1");
            $stmt->execute([$i]);
            $rule = $stmt->fetch(PDO::FETCH_ASSOC);

            if ($rule) {
                $bonus = 0;
                if ($rule['percentage'] > 0) {
                    $bonus = ($amount * $rule['percentage']) / 100;
                } elseif ($rule['fixed_amount'] > 0) {
                    $bonus = $rule['fixed_amount'];
                }

                if ($bonus > 0) {
                    $this->addCommission($sponsorId, $userId, $bonus, 'level', "Level $i Bonus from User #$userId");
                }
            }

            $currentUserId = $sponsorId; // Move up
        }
    }

    public function addCommission($userId, $sourceUserId, $amount, $type, $description) {
        // 1. Log in commissions table
        $stmt = $this->db->prepare("
            INSERT INTO commissions (user_id, source_user_id, amount, type, description, status)
            VALUES (?, ?, ?, ?, ?, 'paid')
        ");
        $stmt->execute([$userId, $sourceUserId, $amount, $type, $description]);

        // 2. Update User Wallet (E-Wallet)
        $stmt = $this->db->prepare("
            UPDATE wallets SET e_wallet_balance = e_wallet_balance + ?, total_earned = total_earned + ?
            WHERE user_id = ?
        ");
        $stmt->execute([$amount, $amount, $userId]);

        // 3. Log Transaction
        $stmt = $this->db->prepare("
            INSERT INTO transactions (user_id, wallet_type, type, amount, balance_before, balance_after, description, status)
            SELECT ?, 'e_wallet', 'credit', ?, e_wallet_balance - ?, e_wallet_balance, ?, 'completed'
            FROM wallets WHERE user_id = ?
        ");
        // Note: The balance calculation in SELECT might be slightly off if concurrent, but for now it's okay. 
        // Better to fetch balance first.
        
        // Fetch new balance
        $stmtBalance = $this->db->prepare("SELECT e_wallet_balance FROM wallets WHERE user_id = ?");
        $stmtBalance->execute([$userId]);
        $newBalance = $stmtBalance->fetchColumn();
        $oldBalance = $newBalance - $amount;

        $stmtTx = $this->db->prepare("
            INSERT INTO transactions (user_id, wallet_type, type, amount, balance_before, balance_after, description, status)
            VALUES (?, 'e_wallet', 'credit', ?, ?, ?, ?, 'completed')
        ");
        $stmtTx->execute([$userId, $amount, $oldBalance, $newBalance, $description]);
    }
    
    // Placeholder for other bonus types
    public function calculateRoi() {
        // To be called by cron job
    }
}
