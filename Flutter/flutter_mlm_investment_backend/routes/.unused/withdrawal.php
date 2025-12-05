<?php
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../utils/jwt.php';
require_once __DIR__ . '/../config/app_config.php';

class WithdrawalController {
    private $db;
    private $conn;
    private $userId;

    public function __construct() {
        $this->db = Database::getInstance();
        $this->conn = $this->db->getConnection();
    }

    public function handleRequest($action) {
        $this->userId = $this->authenticate();

        switch ($action) {
            case 'request':
                $this->requestWithdrawal();
                break;
            case 'get_history':
                $this->getWithdrawalHistory();
                break;
            case 'cancel':
                $this->cancelWithdrawal();
                break;
            default:
                $this->sendResponse(400, false, 'Invalid action');
        }
    }

    private function authenticate() {
        $headers = getallheaders();
        $authHeader = $headers['Authorization'] ?? $headers['authorization'] ?? null;
        
        if (!$authHeader || !preg_match('/Bearer\s+(.*)$/i', $authHeader, $matches)) {
            $this->sendResponse(401, false, 'Unauthorized - No token provided');
        }

        $token = $matches[1];
        $decoded = JWT::verify($token);
        
        if (!$decoded) {
            $this->sendResponse(401, false, 'Unauthorized - Invalid token');
        }

        return $decoded['id'];
    }

    private function requestWithdrawal() {
        $data = json_decode(file_get_contents('php://input'), true);
        
        $walletType = $data['wallet_type'] ?? null;
        $amount = $data['amount'] ?? null;
        $bankAccountId = $data['bank_account_id'] ?? null;

        if (!$walletType || !$amount || !$bankAccountId) {
            $this->sendResponse(400, false, 'Wallet type, amount, and bank account are required');
        }

        if (!in_array($walletType, ['e_wallet', 'investment_wallet'])) {
            $this->sendResponse(400, false, 'Invalid wallet type');
        }

        try {
            $this->conn->beginTransaction();
            
            // Validation 1: Check KYC status
            $stmt = $this->conn->prepare("SELECT kyc_status FROM users WHERE id = ?");
            $stmt->execute([$this->userId]);
            $user = $stmt->fetch(PDO::FETCH_ASSOC);
            
            if ($user['kyc_status'] !== 'approved') {
                $this->conn->rollBack();
                $this->sendResponse(403, false, 'KYC verification required for withdrawals');
            }
            
            // Validation 2: Check bank account exists and belongs to user
            $stmt = $this->conn->prepare("SELECT * FROM bank_details WHERE id = ? AND user_id = ?");
            $stmt->execute([$bankAccountId, $this->userId]);
            $bankAccount = $stmt->fetch(PDO::FETCH_ASSOC);
            
            if (!$bankAccount) {
                $this->conn->rollBack();
                $this->sendResponse(404, false, 'Bank account not found');
            }
            
            // Validation 3: Check minimum withdrawal amount
            if ($amount < AppConfig::MIN_WITHDRAWAL_AMOUNT) {
                $this->conn->rollBack();
                $this->sendResponse(400, false, 'Minimum withdrawal amount is ₹' . AppConfig::MIN_WITHDRAWAL_AMOUNT);
            }
            
            // Validation 4: Check wallet balance
            if ($walletType === 'e_wallet') {
                $stmt = $this->conn->prepare("SELECT e_wallet_balance as balance FROM wallets WHERE user_id = ?");
            } else {
                $stmt = $this->conn->prepare("SELECT balance FROM investment_wallets WHERE user_id = ?");
            }
            $stmt->execute([$this->userId]);
            $wallet = $stmt->fetch(PDO::FETCH_ASSOC);
            
            if (!$wallet || $wallet['balance'] < $amount) {
                $this->conn->rollBack();
                $this->sendResponse(400, false, 'Insufficient balance');
            }
            
            // Validation 5: Check daily withdrawal limit
            $stmt = $this->conn->prepare("
                SELECT COALESCE(SUM(amount), 0) as today_total
                FROM withdrawals
                WHERE user_id = ? 
                AND DATE(requested_at) = CURDATE()
                AND status IN ('pending', 'approved', 'completed')
            ");
            $stmt->execute([$this->userId]);
            $todayTotal = $stmt->fetch(PDO::FETCH_ASSOC)['today_total'];
            
            if (($todayTotal + $amount) > AppConfig::MAX_DAILY_WITHDRAWAL) {
                $this->conn->rollBack();
                $this->sendResponse(400, false, 'Daily withdrawal limit exceeded. Limit: ₹' . AppConfig::MAX_DAILY_WITHDRAWAL);
            }
            
            // Calculate charges
            $charges = ($amount * AppConfig::WITHDRAWAL_CHARGE_PERCENTAGE) / 100;
            $netAmount = $amount - $charges;
            
            // Determine initial status
            $initialStatus = AppConfig::REQUIRE_ADMIN_APPROVAL ? 'pending' : 'approved';
            
            // Create withdrawal request
            $stmt = $this->conn->prepare("
                INSERT INTO withdrawals (user_id, wallet_type, amount, charges, net_amount, bank_account_id, status)
                VALUES (?, ?, ?, ?, ?, ?, ?)
            ");
            $stmt->execute([$this->userId, $walletType, $amount, $charges, $netAmount, $bankAccountId, $initialStatus]);
            
            $withdrawalId = $this->conn->lastInsertId();
            
            // Deduct from wallet (lock the amount)
            if ($walletType === 'e_wallet') {
                $stmt = $this->conn->prepare("
                    UPDATE wallets 
                    SET e_wallet_balance = e_wallet_balance - ?
                    WHERE user_id = ?
                ");
            } else {
                $stmt = $this->conn->prepare("
                    UPDATE investment_wallets 
                    SET balance = balance - ?
                    WHERE user_id = ?
                ");
            }
            $stmt->execute([$amount, $this->userId]);
            
            // Create transaction record
            $stmt = $this->conn->prepare("
                INSERT INTO transactions (user_id, type, amount, description, reference_type, reference_id, created_at)
                VALUES (?, 'debit', ?, ?, 'withdrawal', ?, NOW())
            ");
            $stmt->execute([
                $this->userId,
                $amount,
                'Withdrawal request from ' . str_replace('_', ' ', $walletType),
                $withdrawalId
            ]);
            
            // If auto-approval is enabled, mark as completed immediately
            if (!AppConfig::REQUIRE_ADMIN_APPROVAL) {
                $stmt = $this->conn->prepare("
                    UPDATE withdrawals 
                    SET status = 'completed', admin_remarks = 'Auto-approved', processed_at = NOW()
                    WHERE id = ?
                ");
                $stmt->execute([$withdrawalId]);
            }
            
            $this->conn->commit();
            
            $message = AppConfig::REQUIRE_ADMIN_APPROVAL 
                ? 'Your withdrawal request is under review. You will be notified once processed.'
                : 'Withdrawal processed successfully. Amount will be transferred to your bank account.';
            
            $this->sendResponse(200, true, 'Withdrawal request submitted successfully', [
                'withdrawal_id' => $withdrawalId,
                'amount' => $amount,
                'charges' => $charges,
                'net_amount' => $netAmount,
                'status' => $initialStatus,
                'message' => $message
            ]);
        } catch (Exception $e) {
            $this->conn->rollBack();
            $this->sendResponse(500, false, 'Failed to process withdrawal: ' . $e->getMessage());
        }
    }

    private function getWithdrawalHistory() {
        try {
            $stmt = $this->conn->prepare("
                SELECT w.*, b.account_number, b.bank_name
                FROM withdrawals w
                LEFT JOIN bank_details b ON w.bank_account_id = b.id
                WHERE w.user_id = ?
                ORDER BY w.requested_at DESC
                LIMIT 50
            ");
            $stmt->execute([$this->userId]);
            $withdrawals = $stmt->fetchAll(PDO::FETCH_ASSOC);
            
            // Mask account number for security
            foreach ($withdrawals as &$withdrawal) {
                if ($withdrawal['account_number']) {
                    $withdrawal['account_number'] = 'XXXX' . substr($withdrawal['account_number'], -4);
                }
            }
            
            $this->sendResponse(200, true, 'Withdrawal history fetched', $withdrawals);
        } catch (Exception $e) {
            $this->sendResponse(500, false, 'Failed to fetch history: ' . $e->getMessage());
        }
    }

    private function cancelWithdrawal() {
        $data = json_decode(file_get_contents('php://input'), true);
        $withdrawalId = $data['withdrawal_id'] ?? null;

        if (!$withdrawalId) {
            $this->sendResponse(400, false, 'Withdrawal ID required');
        }

        try {
            $this->conn->beginTransaction();
            
            // Get withdrawal details
            $stmt = $this->conn->prepare("
                SELECT * FROM withdrawals 
                WHERE id = ? AND user_id = ? AND status = 'pending'
            ");
            $stmt->execute([$withdrawalId, $this->userId]);
            $withdrawal = $stmt->fetch(PDO::FETCH_ASSOC);
            
            if (!$withdrawal) {
                $this->conn->rollBack();
                $this->sendResponse(404, false, 'Withdrawal not found or cannot be cancelled');
            }
            
            // Update status to rejected
            $stmt = $this->conn->prepare("
                UPDATE withdrawals 
                SET status = 'rejected', admin_remarks = 'Cancelled by user', processed_at = NOW()
                WHERE id = ?
            ");
            $stmt->execute([$withdrawalId]);
            
            // Refund to wallet
            if ($withdrawal['wallet_type'] === 'e_wallet') {
                $stmt = $this->conn->prepare("
                    UPDATE wallets 
                    SET e_wallet_balance = e_wallet_balance + ?
                    WHERE user_id = ?
                ");
            } else {
                $stmt = $this->conn->prepare("
                    UPDATE investment_wallets 
                    SET balance = balance + ?
                    WHERE user_id = ?
                ");
            }
            $stmt->execute([$withdrawal['amount'], $this->userId]);
            
            $this->conn->commit();
            $this->sendResponse(200, true, 'Withdrawal cancelled and amount refunded');
        } catch (Exception $e) {
            $this->conn->rollBack();
            $this->sendResponse(500, false, 'Failed to cancel withdrawal: ' . $e->getMessage());
        }
    }

    private function sendResponse($code, $success, $message, $data = null) {
        http_response_code($code);
        echo json_encode(['success' => $success, 'message' => $message, 'data' => $data]);
        exit();
    }
}

if (isset($_GET['action'])) {
    $controller = new WithdrawalController();
    $controller->handleRequest($_GET['action']);
}
?>
