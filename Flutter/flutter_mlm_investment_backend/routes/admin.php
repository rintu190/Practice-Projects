<?php
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../utils/jwt.php';
require_once __DIR__ . '/../utils/profit_calculator.php';

class AdminController {
    private $db;
    private $conn;
    private $userId;

    public function __construct() {
        $this->db = Database::getInstance();
        $this->conn = $this->db->getConnection();
        $this->authenticate();
    }

    private function authenticate() {
        $headers = function_exists('getallheaders') ? getallheaders() : [];
        $authHeader = $headers['Authorization'] ?? '';

        if (empty($authHeader) && isset($_SERVER['HTTP_AUTHORIZATION'])) {
            $authHeader = $_SERVER['HTTP_AUTHORIZATION'];
        }
        
        if (preg_match('/Bearer\s(\S+)/', $authHeader, $matches)) {
            $token = $matches[1];
            $payload = JWT::verify($token);
            if ($payload) {
                $this->userId = $payload['id'];
                if ($payload['role'] !== 'admin') {
                    $this->sendResponse(403, false, 'Forbidden: Admin access required');
                }
                return;
            }
        }
        $this->sendResponse(401, false, 'Unauthorized');
    }

    public function handleRequest($action) {
        switch ($action) {
            case 'trigger_profit_calculation':
                $this->triggerProfitCalculation();
                break;
            case 'approve_deposits':
                $this->approveAllDeposits();
                break;
            case 'approve_withdrawals':
                $this->approveAllWithdrawals();
                break;
            case 'approve_transfers':
                $this->approveAllTransfers();
                break;
            case 'get_pending_approvals':
                $this->getPendingApprovals();
                break;
            case 'approve_item':
                $this->approveSingleItem();
                break;
            case 'reject_item':
                $this->rejectSingleItem();
                break;
            default:
                $this->sendResponse(400, false, 'Invalid action');
        }
    }

    private function triggerProfitCalculation() {
        try {
            $calculator = new ProfitCalculator();
            
            // 1. Calculate Daily Profits
            // Logic duplicated from cron/calculate_profits.php but adapted for API response
            
            // Get all active investments that need profit distribution
            // Note: We might want to allow forcing calculation even if not due, 
            // but for safety let's stick to "due" profits or add a force flag.
            // For manual trigger, usually we want to run the daily process.
            
            $stmt = $this->conn->query("
                SELECT ui.*, ip.roi_frequency
                FROM user_investments ui
                JOIN investment_products ip ON ui.product_id = ip.id
                WHERE ui.status = 'active'
                AND (
                    (ip.roi_frequency = 'daily' AND (ui.last_profit_date IS NULL OR ui.last_profit_date < CURDATE()))
                    OR (ip.roi_frequency = 'weekly' AND (ui.last_profit_date IS NULL OR DATEDIFF(CURDATE(), ui.last_profit_date) >= 7))
                    OR (ip.roi_frequency = 'monthly' AND (ui.last_profit_date IS NULL OR DATEDIFF(CURDATE(), ui.last_profit_date) >= 30))
                )
            ");

            $investments = $stmt->fetchAll(PDO::FETCH_ASSOC);
            $processed = 0;
            $totalProfit = 0;
            $errors = [];

            foreach ($investments as $investment) {
                try {
                    $profit = $calculator->calculateProfit($investment['id']);
                    
                    if ($profit > 0) {
                        $creditTo = $investment['roi_frequency'] === 'daily' ? 'investment_wallet' : 'investment_wallet';
                        
                        $calculator->distributeProfit(
                            $investment['id'],
                            $investment['user_id'],
                            $profit,
                            $creditTo
                        );

                        $processed++;
                        $totalProfit += $profit;
                    }
                } catch (Exception $e) {
                    $errors[] = "Investment #{$investment['id']}: " . $e->getMessage();
                }
            }

            // 2. Process Matured Investments
            $matured = $calculator->processMaturedInvestments();

            $this->sendResponse(200, true, 'Profit calculation completed', [
                'processed_count' => $processed,
                'total_profit_distributed' => $totalProfit,
                'matured_investments_processed' => $matured,
                'errors' => $errors
            ]);

        } catch (Exception $e) {
            $this->sendResponse(500, false, 'Error executing profit calculation: ' . $e->getMessage());
        }
    }

    private function approveAllDeposits() {
        try {
            // Get count of pending deposits before
            $countStmt = $this->conn->query("
                SELECT COUNT(*) as count 
                FROM deposits 
                WHERE status = 'pending'
            ");
            $countBefore = $countStmt->fetch()['count'];

            // Update all pending deposits to approved
            $updateStmt = $this->conn->prepare("
                UPDATE deposits 
                SET status = 'approved', approved_at = NOW(), approved_by = ?
                WHERE status = 'pending'
            ");
            $updateStmt->execute([$this->userId]);
            $rowsAffected = $updateStmt->rowCount();

            // Get updated count
            $countStmt = $this->conn->query("
                SELECT COUNT(*) as count 
                FROM deposits 
                WHERE status = 'pending'
            ");
            $countAfter = $countStmt->fetch()['count'];

            $this->sendResponse(200, true, 'All pending deposits approved', [
                'approved_count' => $rowsAffected,
                'pending_before' => $countBefore,
                'pending_after' => $countAfter
            ]);

        } catch (Exception $e) {
            $this->sendResponse(500, false, 'Error approving deposits: ' . $e->getMessage());
        }
    }

    private function approveAllWithdrawals() {
        try {
            // Get count of pending withdrawals before
            $countStmt = $this->conn->query("
                SELECT COUNT(*) as count 
                FROM withdrawals 
                WHERE status = 'pending'
            ");
            $countBefore = $countStmt->fetch()['count'];

            // Update all pending withdrawals to approved
            $updateStmt = $this->conn->prepare("
                UPDATE withdrawals 
                SET status = 'approved', approved_at = NOW(), approved_by = ?
                WHERE status = 'pending'
            ");
            $updateStmt->execute([$this->userId]);
            $rowsAffected = $updateStmt->rowCount();

            // Get updated count
            $countStmt = $this->conn->query("
                SELECT COUNT(*) as count 
                FROM withdrawals 
                WHERE status = 'pending'
            ");
            $countAfter = $countStmt->fetch()['count'];

            $this->sendResponse(200, true, 'All pending withdrawals approved', [
                'approved_count' => $rowsAffected,
                'pending_before' => $countBefore,
                'pending_after' => $countAfter
            ]);

        } catch (Exception $e) {
            $this->sendResponse(500, false, 'Error approving withdrawals: ' . $e->getMessage());
        }
    }

    private function approveAllTransfers() {
        try {
            // Get count of pending transfers before
            $countStmt = $this->conn->query("
                SELECT COUNT(*) as count 
                FROM transactions 
                WHERE reference_type = 'transfer' AND status = 'pending'
            ");
            $countBefore = $countStmt->fetch()['count'];

            // Update all pending transfers to completed
            $updateStmt = $this->conn->prepare("
                UPDATE transactions 
                SET status = 'completed', updated_at = NOW()
                WHERE reference_type = 'transfer' AND status = 'pending'
            ");
            $updateStmt->execute();
            $rowsAffected = $updateStmt->rowCount();

            // Get updated count
            $countStmt = $this->conn->query("
                SELECT COUNT(*) as count 
                FROM transactions 
                WHERE reference_type = 'transfer' AND status = 'pending'
            ");
            $countAfter = $countStmt->fetch()['count'];

            $this->sendResponse(200, true, 'All pending transfers approved', [
                'approved_count' => $rowsAffected,
                'pending_before' => $countBefore,
                'pending_after' => $countAfter
            ]);

        } catch (Exception $e) {
            $this->sendResponse(500, false, 'Error approving transfers: ' . $e->getMessage());
        }
    }

    private function getPendingApprovals() {
        try {
            // Get pending deposits
            $depositsStmt = $this->conn->query("
                SELECT 
                    d.id,
                    'deposit' as type,
                    d.user_id,
                    u.phone as user_name,
                    d.amount,
                    d.created_at
                FROM deposits d
                LEFT JOIN users u ON d.user_id = u.id
                WHERE d.status = 'pending'
                ORDER BY d.created_at DESC
            ");
            $deposits = $depositsStmt->fetchAll(PDO::FETCH_ASSOC);

            // Get pending withdrawals
            $withdrawalsStmt = $this->conn->query("
                SELECT 
                    w.id,
                    'withdrawal' as type,
                    w.user_id,
                    u.phone as user_name,
                    w.amount,
                    w.created_at
                FROM withdrawals w
                LEFT JOIN users u ON w.user_id = u.id
                WHERE w.status = 'pending'
                ORDER BY w.created_at DESC
            ");
            $withdrawals = $withdrawalsStmt->fetchAll(PDO::FETCH_ASSOC);

            // Get pending transfers
            $transfersStmt = $this->conn->query("
                SELECT 
                    t.id,
                    'transfer' as type,
                    t.user_id,
                    u.phone as user_name,
                    t.amount,
                    t.created_at
                FROM transactions t
                LEFT JOIN users u ON t.user_id = u.id
                WHERE t.reference_type = 'transfer' AND t.status = 'pending'
                ORDER BY t.created_at DESC
            ");
            $transfers = $transfersStmt->fetchAll(PDO::FETCH_ASSOC);

            // Get pending KYC documents
            $kycStmt = $this->conn->query("
                SELECT 
                    k.id,
                    'kyc' as type,
                    k.user_id,
                    u.phone as user_name,
                    0 as amount,
                    k.created_at,
                    k.document_type,
                    k.document_number,
                    k.document_image
                FROM kyc_documents k
                LEFT JOIN users u ON k.user_id = u.id
                WHERE k.status = 'pending'
                ORDER BY k.created_at DESC
            ");
            $kycDocs = $kycStmt->fetchAll(PDO::FETCH_ASSOC);

            // Get pending Bank Details
            $bankStmt = $this->conn->query("
                SELECT 
                    b.id,
                    'bank' as type,
                    b.user_id,
                    u.phone as user_name,
                    0 as amount,
                    b.created_at,
                    b.bank_name,
                    b.account_number,
                    b.ifsc_code
                FROM bank_details b
                LEFT JOIN users u ON b.user_id = u.id
                WHERE b.is_verified = 0
                ORDER BY b.created_at DESC
            ");
            $bankDetails = $bankStmt->fetchAll(PDO::FETCH_ASSOC);

            // Merge all items
            $allItems = array_merge($deposits, $withdrawals, $transfers, $kycDocs, $bankDetails);

            // Sort by created_at descending
            usort($allItems, function ($a, $b) {
                return strtotime($b['created_at']) - strtotime($a['created_at']);
            });

            $this->sendResponse(200, true, 'Pending approvals retrieved', [
                'items' => $allItems,
                'total_count' => count($allItems)
            ]);

        } catch (Exception $e) {
            $this->sendResponse(500, false, 'Error retrieving pending approvals: ' . $e->getMessage());
        }
    }

    private function approveSingleItem() {
        try {
            // Get POST data
            $input = json_decode(file_get_contents('php://input'), true);
            $type = $input['type'] ?? null;
            $itemId = $input['item_id'] ?? null;

            if (!$type || !$itemId) {
                $this->sendResponse(400, false, 'Missing required fields: type and item_id');
            }

            $type = strtolower($type);

            if ($type === 'deposit') {
                $this->conn->beginTransaction();

                // 1. Get deposit details
                $stmt = $this->conn->prepare("SELECT * FROM deposits WHERE id = ? AND status = 'pending'");
                $stmt->execute([$itemId]);
                $deposit = $stmt->fetch(PDO::FETCH_ASSOC);

                if (!$deposit) {
                    $this->conn->rollBack();
                    $this->sendResponse(404, false, 'Deposit not found or already processed');
                }

                // 2. Update deposit status
                $updateStmt = $this->conn->prepare("
                    UPDATE deposits 
                    SET status = 'approved', approved_at = NOW(), approved_by = ?
                    WHERE id = ?
                ");
                $updateStmt->execute([$this->userId, $itemId]);

                // 3. Credit User E-Wallet (only one wallet now)
                $balanceStmt = $this->conn->prepare("
                    UPDATE wallets 
                    SET e_wallet_balance = e_wallet_balance + ? 
                    WHERE user_id = ?
                ");
                $balanceStmt->execute([$deposit['amount'], $deposit['user_id']]);

                // 4. Create Transaction Record
                $transStmt = $this->conn->prepare("
                    INSERT INTO transactions 
                    (user_id, wallet_type, type, amount, description, reference_id, reference_type, status, balance_after) 
                    VALUES (?, 'e_wallet', 'credit', ?, 'Deposit Approved', ?, 'deposit', 'completed', 
                        (SELECT e_wallet_balance FROM wallets WHERE user_id = ?)
                    )
                ");
                $transStmt->execute([
                    $deposit['user_id'], 
                    $deposit['amount'], 
                    $itemId, 
                    $deposit['user_id']
                ]);

                $this->conn->commit();

                $this->sendResponse(200, true, 'Deposit approved and wallet credited', [
                    'item_id' => $itemId,
                    'type' => 'deposit'
                ]);

            } elseif ($type === 'withdrawal') {
                $this->conn->beginTransaction();

                // 1. Check withdrawal exists
                $stmt = $this->conn->prepare("SELECT id FROM withdrawals WHERE id = ? AND status = 'pending'");
                $stmt->execute([$itemId]);
                if (!$stmt->fetch()) {
                    $this->conn->rollBack();
                    $this->sendResponse(404, false, 'Withdrawal not found or already processed');
                }

                // 2. Update withdrawal status
                $updateStmt = $this->conn->prepare("
                    UPDATE withdrawals 
                    SET status = 'approved', approved_at = NOW(), approved_by = ?
                    WHERE id = ?
                ");
                $updateStmt->execute([$this->userId, $itemId]);

                $this->conn->commit();

                $this->sendResponse(200, true, 'Withdrawal approved successfully', [
                    'item_id' => $itemId,
                    'type' => 'withdrawal'
                ]);

            } elseif ($type === 'transfer') {
                $this->conn->beginTransaction();

                // 1. Check transfer exists
                $stmt = $this->conn->prepare("SELECT id FROM transactions WHERE id = ? AND reference_type = 'transfer' AND status = 'pending'");
                $stmt->execute([$itemId]);
                if (!$stmt->fetch()) {
                    $this->conn->rollBack();
                    $this->sendResponse(404, false, 'Transfer not found or already processed');
                }

                // 2. Update transfer status
                $updateStmt = $this->conn->prepare("
                    UPDATE transactions 
                    SET status = 'completed', updated_at = NOW()
                    WHERE id = ?
                ");
                $updateStmt->execute([$itemId]);

                $this->conn->commit();

                $this->sendResponse(200, true, 'Transfer approved successfully', [
                    'item_id' => $itemId,
                    'type' => 'transfer'
                ]);

            } elseif ($type === 'kyc') {
                // Update KYC status
                $updateStmt = $this->conn->prepare("
                    UPDATE kyc_documents 
                    SET status = 'approved', verified_at = NOW()
                    WHERE id = ?
                ");
                $updateStmt->execute([$itemId]);

                if ($updateStmt->rowCount() === 0) {
                    $this->sendResponse(404, false, 'KYC document not found or already processed');
                }

                // Update user KYC status if all docs approved (simplified logic: just set user to approved if this one is approved)
                // Ideally check if all required docs are approved
                $stmt = $this->conn->prepare("SELECT user_id FROM kyc_documents WHERE id = ?");
                $stmt->execute([$itemId]);
                $userId = $stmt->fetchColumn();

                $this->conn->prepare("UPDATE users SET kyc_status = 'approved' WHERE id = ?")->execute([$userId]);

                $this->sendResponse(200, true, 'KYC approved successfully', [
                    'item_id' => $itemId,
                    'type' => 'kyc'
                ]);

            } elseif ($type === 'bank') {
                // Update Bank verification status
                $updateStmt = $this->conn->prepare("
                    UPDATE bank_details 
                    SET is_verified = 1, updated_at = NOW()
                    WHERE id = ?
                ");
                $updateStmt->execute([$itemId]);

                if ($updateStmt->rowCount() === 0) {
                    $this->sendResponse(404, false, 'Bank details not found or already verified');
                }

                $this->sendResponse(200, true, 'Bank details verified successfully', [
                    'item_id' => $itemId,
                    'type' => 'bank'
                ]);

            } else {
                $this->sendResponse(400, false, 'Invalid type');
            }

        } catch (Exception $e) {
            if ($this->conn->inTransaction()) {
                $this->conn->rollBack();
            }
            $this->sendResponse(500, false, 'Error approving item: ' . $e->getMessage());
        }
    }

    private function rejectSingleItem() {
        try {
            // Get POST data
            $input = json_decode(file_get_contents('php://input'), true);
            $type = $input['type'] ?? null;
            $itemId = $input['item_id'] ?? null;
            $reason = $input['reason'] ?? 'No reason provided';

            if (!$type || !$itemId) {
                $this->sendResponse(400, false, 'Missing required fields: type and item_id');
            }

            $type = strtolower($type);

            if ($type === 'deposit') {
                $stmt = $this->conn->prepare("
                    UPDATE deposits 
                    SET status = 'rejected', rejection_reason = ?, rejected_at = NOW(), rejected_by = ?
                    WHERE id = ? AND status = 'pending'
                ");
                $stmt->execute([$reason, $this->userId, $itemId]);
                
                if ($stmt->rowCount() === 0) {
                    $this->sendResponse(404, false, 'Deposit not found or already processed');
                }

                $this->sendResponse(200, true, 'Deposit rejected successfully', [
                    'item_id' => $itemId,
                    'type' => 'deposit'
                ]);

            } elseif ($type === 'withdrawal') {
                $this->conn->beginTransaction();

                // 1. Get withdrawal details
                $stmt = $this->conn->prepare("SELECT * FROM withdrawals WHERE id = ? AND status = 'pending'");
                $stmt->execute([$itemId]);
                $withdrawal = $stmt->fetch(PDO::FETCH_ASSOC);

                if (!$withdrawal) {
                    $this->conn->rollBack();
                    $this->sendResponse(404, false, 'Withdrawal not found or already processed');
                }

                // 2. Update withdrawal status
                $updateStmt = $this->conn->prepare("
                    UPDATE withdrawals 
                    SET status = 'rejected', rejection_reason = ?, rejected_at = NOW(), rejected_by = ?
                    WHERE id = ?
                ");
                $updateStmt->execute([$reason, $this->userId, $itemId]);

                // 3. Refund User E-Wallet (only one wallet now)
                $balanceStmt = $this->conn->prepare("
                    UPDATE wallets 
                    SET e_wallet_balance = e_wallet_balance + ? 
                    WHERE user_id = ?
                ");
                $balanceStmt->execute([$withdrawal['amount'], $withdrawal['user_id']]);

                // 4. Create Refund Transaction
                $transStmt = $this->conn->prepare("
                    INSERT INTO transactions 
                    (user_id, wallet_type, type, amount, description, reference_id, reference_type, status, balance_after) 
                    VALUES (?, 'e_wallet', 'credit', ?, 'Withdrawal Rejected - Refund', ?, 'withdrawal_refund', 'completed', 
                        (SELECT e_wallet_balance FROM wallets WHERE user_id = ?)
                    )
                ");
                $transStmt->execute([
                    $withdrawal['user_id'], 
                    $withdrawal['amount'], 
                    $itemId, 
                    $withdrawal['user_id']
                ]);

                $this->conn->commit();

                $this->sendResponse(200, true, 'Withdrawal rejected and refunded', [
                    'item_id' => $itemId,
                    'type' => 'withdrawal'
                ]);

            } elseif ($type === 'transfer') {
                $this->conn->beginTransaction();
                
                // 1. Get transfer details
                $stmt = $this->conn->prepare("SELECT * FROM transactions WHERE id = ? AND reference_type = 'transfer' AND status = 'pending'");
                $stmt->execute([$itemId]);
                $transfer = $stmt->fetch(PDO::FETCH_ASSOC);
                
                if (!$transfer) {
                    $this->conn->rollBack();
                    $this->sendResponse(404, false, 'Transfer not found or already processed');
                }

                // 2. Update transfer status
                $updateStmt = $this->conn->prepare("
                    UPDATE transactions 
                    SET status = 'rejected', rejection_reason = ?, rejected_at = NOW(), rejected_by = ?
                    WHERE id = ?
                ");
                $updateStmt->execute([$reason, $this->userId, $itemId]);
                
                // 3. Refund Sender Wallet
                $walletCol = $transfer['wallet_type'] === 'investment_wallet' ? 'investment_wallet_balance' : 'e_wallet_balance';
                $balanceStmt = $this->conn->prepare("
                    UPDATE wallets 
                    SET $walletCol = $walletCol + ? 
                    WHERE user_id = ?
                ");
                $balanceStmt->execute([$transfer['amount'], $transfer['user_id']]);
                
                // 4. Create Refund Transaction
                $transStmt = $this->conn->prepare("
                    INSERT INTO transactions 
                    (user_id, wallet_type, type, amount, description, reference_id, reference_type, status, balance_after) 
                    VALUES (?, ?, 'credit', ?, 'Transfer Rejected - Refund', ?, 'transfer_refund', 'completed', 
                        (SELECT $walletCol FROM wallets WHERE user_id = ?)
                    )
                ");
                $transStmt->execute([
                    $transfer['user_id'], 
                    $transfer['wallet_type'], 
                    $transfer['amount'], 
                    $itemId, 
                    $transfer['user_id']
                ]);

                $this->conn->commit();

                $this->sendResponse(200, true, 'Transfer rejected and refunded', [
                    'item_id' => $itemId,
                    'type' => 'transfer'
                ]);

            } elseif ($type === 'kyc') {
                // Update KYC status
                $updateStmt = $this->conn->prepare("
                    UPDATE kyc_documents 
                    SET status = 'rejected', rejection_reason = ?
                    WHERE id = ?
                ");
                $updateStmt->execute([$reason, $itemId]);

                if ($updateStmt->rowCount() === 0) {
                    $this->sendResponse(404, false, 'KYC document not found or already processed');
                }

                // Update user KYC status
                $stmt = $this->conn->prepare("SELECT user_id FROM kyc_documents WHERE id = ?");
                $stmt->execute([$itemId]);
                $userId = $stmt->fetchColumn();

                $this->conn->prepare("UPDATE users SET kyc_status = 'rejected' WHERE id = ?")->execute([$userId]);

                $this->sendResponse(200, true, 'KYC rejected successfully', [
                    'item_id' => $itemId,
                    'type' => 'kyc'
                ]);

            } elseif ($type === 'bank') {
                // We don't really 'reject' bank details in the schema, just maybe delete or mark unverified?
                // For now, let's just leave it unverified but maybe log it? 
                // Or we can add a 'rejected' status to bank_details if we modify schema.
                // Assuming we just want to keep it unverified.
                
                $this->sendResponse(200, true, 'Bank details rejection noted (remains unverified)', [
                    'item_id' => $itemId,
                    'type' => 'bank'
                ]);

            } else {
                $this->sendResponse(400, false, 'Invalid type');
            }

        } catch (Exception $e) {
            if ($this->conn->inTransaction()) {
                $this->conn->rollBack();
            }
            $this->sendResponse(500, false, 'Error rejecting item: ' . $e->getMessage());
        }
    }

    private function sendResponse($code, $success, $message, $data = null) {
        http_response_code($code);
        echo json_encode([
            'success' => $success,
            'message' => $message,
            'data' => $data
        ]);
        exit;
    }
}

if (isset($_GET['action'])) {
    $controller = new AdminController();
    $controller->handleRequest($_GET['action']);
}
?>
