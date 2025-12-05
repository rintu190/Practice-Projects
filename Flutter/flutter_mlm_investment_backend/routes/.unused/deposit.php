<?php
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../utils/jwt.php';
require_once __DIR__ . '/../config/app_config.php';

class DepositController {
    private $db;
    private $conn;
    private $userId;

    public function __construct() {
        $this->db = Database::getInstance();
        $this->conn = $this->db->getConnection();
    }

    public function handleRequest($action) {
        // Webhook doesn't need authentication
        if ($action === 'verify_payment') {
            $this->verifyPayment();
            return;
        }

        $this->userId = $this->authenticate();

        switch ($action) {
            case 'initiate':
                $this->initiateDeposit();
                break;
            case 'get_history':
                $this->getDepositHistory();
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

    private function initiateDeposit() {
        $data = json_decode(file_get_contents('php://input'), true);
        
        $walletType = $data['wallet_type'] ?? null;
        $amount = $data['amount'] ?? null;
        $paymentMethod = $data['payment_method'] ?? 'manual';

        if (!$walletType || !$amount) {
            $this->sendResponse(400, false, 'Wallet type and amount are required');
        }

        if (!in_array($walletType, ['e_wallet', 'investment_wallet'])) {
            $this->sendResponse(400, false, 'Invalid wallet type');
        }

        if ($amount < 100) {
            $this->sendResponse(400, false, 'Minimum deposit amount is ₹100');
        }

        try {
            $this->conn->beginTransaction();
            
            // For now, we'll create a manual deposit (no payment gateway)
            // In production, integrate with Razorpay/Paytm here
            $orderId = 'ORD' . time() . rand(1000, 9999);
            $initialStatus = 'pending';
            
            $stmt = $this->conn->prepare("
                INSERT INTO deposits (user_id, wallet_type, amount, payment_method, gateway_order_id, status)
                VALUES (?, ?, ?, ?, ?, ?)
            ");
            $stmt->execute([$this->userId, $walletType, $amount, $paymentMethod, $orderId, $initialStatus]);
            
            $depositId = $this->conn->lastInsertId();
            
            // Auto-approve if admin approval not required
            if (!AppConfig::REQUIRE_ADMIN_APPROVAL) {
                // Update deposit status to success
                $stmt = $this->conn->prepare("
                    UPDATE deposits 
                    SET status = 'success', completed_at = NOW()
                    WHERE id = ?
                ");
                $stmt->execute([$depositId]);
                
                // Credit wallet
                if ($walletType === 'e_wallet') {
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
                $stmt->execute([$amount, $this->userId]);
                
                // Create transaction record
                $stmt = $this->conn->prepare("
                    INSERT INTO transactions (user_id, type, amount, description, reference_type, reference_id, created_at)
                    VALUES (?, 'credit', ?, ?, 'deposit', ?, NOW())
                ");
                $stmt->execute([
                    $this->userId,
                    $amount,
                    'Deposit to ' . str_replace('_', ' ', $walletType),
                    $depositId
                ]);
                
                $this->conn->commit();
                
                $this->sendResponse(200, true, 'Deposit completed successfully', [
                    'deposit_id' => $depositId,
                    'order_id' => $orderId,
                    'amount' => $amount,
                    'wallet_type' => $walletType,
                    'status' => 'success',
                    'message' => 'Your wallet has been credited immediately.'
                ]);
            } else {
                $this->conn->commit();
                
                $this->sendResponse(200, true, 'Deposit initiated', [
                    'deposit_id' => $depositId,
                    'order_id' => $orderId,
                    'amount' => $amount,
                    'wallet_type' => $walletType,
                    'payment_url' => null,
                    'status' => 'pending',
                    'message' => 'Manual deposit created. Contact admin to complete payment.'
                ]);
            }
        } catch (Exception $e) {
            $this->conn->rollBack();
            $this->sendResponse(500, false, 'Failed to initiate deposit: ' . $e->getMessage());
        }
    }

    private function verifyPayment() {
        // This would be called by payment gateway webhook
        // For now, it's a placeholder for manual verification
        $data = json_decode(file_get_contents('php://input'), true);
        
        $orderId = $data['order_id'] ?? null;
        $paymentId = $data['payment_id'] ?? null;
        $status = $data['status'] ?? 'failed';

        if (!$orderId) {
            $this->sendResponse(400, false, 'Order ID required');
        }

        try {
            $this->conn->beginTransaction();
            
            // Get deposit details
            $stmt = $this->conn->prepare("SELECT * FROM deposits WHERE gateway_order_id = ? AND status = 'pending'");
            $stmt->execute([$orderId]);
            $deposit = $stmt->fetch(PDO::FETCH_ASSOC);
            
            if (!$deposit) {
                $this->conn->rollBack();
                $this->sendResponse(404, false, 'Deposit not found or already processed');
            }
            
            if ($status === 'success') {
                // Update deposit status
                $stmt = $this->conn->prepare("
                    UPDATE deposits 
                    SET status = 'success', gateway_payment_id = ?, completed_at = NOW()
                    WHERE id = ?
                ");
                $stmt->execute([$paymentId, $deposit['id']]);
                
                // Credit wallet
                if ($deposit['wallet_type'] === 'e_wallet') {
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
                $stmt->execute([$deposit['amount'], $deposit['user_id']]);
                
                // Create transaction record
                $stmt = $this->conn->prepare("
                    INSERT INTO transactions (user_id, type, amount, description, reference_type, reference_id, created_at)
                    VALUES (?, 'credit', ?, ?, 'deposit', ?, NOW())
                ");
                $stmt->execute([
                    $deposit['user_id'],
                    $deposit['amount'],
                    'Deposit to ' . str_replace('_', ' ', $deposit['wallet_type']),
                    $deposit['id']
                ]);
                
                $this->conn->commit();
                $this->sendResponse(200, true, 'Payment verified and wallet credited');
            } else {
                // Mark as failed
                $stmt = $this->conn->prepare("UPDATE deposits SET status = 'failed' WHERE id = ?");
                $stmt->execute([$deposit['id']]);
                
                $this->conn->commit();
                $this->sendResponse(200, true, 'Payment marked as failed');
            }
        } catch (Exception $e) {
            $this->conn->rollBack();
            $this->sendResponse(500, false, 'Failed to verify payment: ' . $e->getMessage());
        }
    }

    private function getDepositHistory() {
        try {
            $stmt = $this->conn->prepare("
                SELECT id, wallet_type, amount, payment_method, status, created_at, completed_at
                FROM deposits
                WHERE user_id = ?
                ORDER BY created_at DESC
                LIMIT 50
            ");
            $stmt->execute([$this->userId]);
            $deposits = $stmt->fetchAll(PDO::FETCH_ASSOC);
            
            $this->sendResponse(200, true, 'Deposit history fetched', $deposits);
        } catch (Exception $e) {
            $this->sendResponse(500, false, 'Failed to fetch history: ' . $e->getMessage());
        }
    }

    private function sendResponse($code, $success, $message, $data = null) {
        http_response_code($code);
        echo json_encode(['success' => $success, 'message' => $message, 'data' => $data]);
        exit();
    }
}

if (isset($_GET['action'])) {
    $controller = new DepositController();
    $controller->handleRequest($_GET['action']);
}
?>
