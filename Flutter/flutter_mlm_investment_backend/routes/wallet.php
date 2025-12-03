<?php
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../utils/jwt.php';

class WalletController {
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
                return;
            }
        }
        $this->sendResponse(401, false, 'Unauthorized');
    }

    public function handleRequest($action) {
        switch ($action) {
            case 'get_balance':
                $this->getBalance();
                break;
            case 'get_transactions':
                $this->getTransactions();
                break;
            case 'add_funds':
                $this->addFunds();
                break;
            case 'withdraw':
                $this->withdraw();
                break;
            default:
                $this->sendResponse(400, false, 'Invalid action');
        }
    }

    private function addFunds() {
        // Handle multipart/form-data for file upload
        $amount = $_POST['amount'] ?? 0;
        
        if ($amount <= 0) {
            $this->sendResponse(400, false, 'Invalid amount');
        }

        try {
            // Always use e_wallet (investment_wallet removed)
            $stmt = $this->conn->prepare("
                INSERT INTO deposits (user_id, amount, wallet_type, status, created_at)
                VALUES (?, ?, 'e_wallet', 'pending', NOW())
            ");
            $stmt->execute([$this->userId, $amount]);
            
            $this->sendResponse(200, true, 'Deposit request submitted for admin approval');
        } catch (Exception $e) {
            $this->sendResponse(500, false, 'Failed to submit deposit request: ' . $e->getMessage());
        }
    }

    private function withdraw() {
        $input = json_decode(file_get_contents('php://input'), true);
        $amount = $input['amount'] ?? 0;
        
        if ($amount <= 0) {
            $this->sendResponse(400, false, 'Invalid amount');
        }
        
        try {
            $this->conn->beginTransaction();
            
            // Check e_wallet balance only
            $stmt = $this->conn->prepare("SELECT e_wallet_balance FROM wallets WHERE user_id = ? FOR UPDATE");
            $stmt->execute([$this->userId]);
            $balance = $stmt->fetchColumn();
            
            if ($balance < $amount) {
                $this->conn->rollBack();
                $this->sendResponse(400, false, 'Insufficient balance');
            }
            
            // Deduct from e_wallet
            $updateStmt = $this->conn->prepare("UPDATE wallets SET e_wallet_balance = e_wallet_balance - ? WHERE user_id = ?");
            $updateStmt->execute([$amount, $this->userId]);
            
            // Create withdrawal record for admin approval
            $stmt = $this->conn->prepare("
                INSERT INTO withdrawals (user_id, amount, wallet_type, status, created_at)
                VALUES (?, ?, 'e_wallet', 'pending', NOW())
            ");
            $stmt->execute([$this->userId, $amount]);
            $withdrawalId = $this->conn->lastInsertId();
            
            // Create transaction record
            $transStmt = $this->conn->prepare("
                INSERT INTO transactions (user_id, wallet_type, type, amount, description, reference_id, reference_type, status, balance_after)
                VALUES (?, 'e_wallet', 'debit', ?, 'Withdrawal Request (Pending Approval)', ?, 'withdrawal', 'pending', ?)
            ");
            $transStmt->execute([$this->userId, $amount, $withdrawalId, $balance - $amount]);
            
            $this->conn->commit();
            $this->sendResponse(200, true, 'Withdrawal request submitted for admin approval');
            
        } catch (Exception $e) {
            $this->conn->rollBack();
            $this->sendResponse(500, false, 'Failed to submit withdrawal request: ' . $e->getMessage());
        }
    }

    private function getBalance() {
        try {
            error_log("=== GET BALANCE DEBUG ===");
            error_log("User ID: " . $this->userId);
            
            // Fetch from wallets table (only e_wallet now)
            $stmt = $this->conn->prepare("
                SELECT e_wallet_balance, total_earned, total_withdrawn 
                FROM wallets 
                WHERE user_id = ?
            ");
            $stmt->execute([$this->userId]);
            $wallet = $stmt->fetch();

            error_log("Query result: " . json_encode($wallet));

            if (!$wallet) {
                $this->sendResponse(404, false, 'Wallet not found');
            }

            $data = [
                'balance' => (float)($wallet['e_wallet_balance'] ?? 0),
                'total_earned' => (float)($wallet['total_earned'] ?? 0),
                'total_withdrawn' => (float)($wallet['total_withdrawn'] ?? 0),
            ];

            error_log("Returning data: " . json_encode($data));
            $this->sendResponse(200, true, 'Wallet balance fetched', $data);
        } catch (Exception $e) {
            error_log("Error in getBalance: " . $e->getMessage());
            $this->sendResponse(500, false, 'Failed to fetch wallet balance: ' . $e->getMessage());
        }
    }

    private function getTransactions() {
        try {
            $stmt = $this->conn->prepare("
                SELECT * FROM transactions 
                WHERE user_id = ? 
                ORDER BY created_at DESC 
                LIMIT 20
            ");
            $stmt->execute([$this->userId]);
            $transactions = $stmt->fetchAll();

            $this->sendResponse(200, true, 'Transactions fetched', $transactions);
        } catch (Exception $e) {
            $this->sendResponse(500, false, 'Failed to fetch transactions');
        }
    }

    private function transferFunds() {
        try {
            $input = json_decode(file_get_contents('php://input'), true);
            $amount = $input['amount'] ?? 0;
            $transferType = $input['transfer_type'] ?? '';

            // Validation
            if (!$amount || $amount <= 0) {
                $this->sendResponse(400, false, 'Invalid amount');
            }

            if (!in_array($transferType, ['e_to_investment', 'investment_to_e'])) {
                $this->sendResponse(400, false, 'Invalid transfer type');
            }

            // Get current wallet balance
            $walletStmt = $this->conn->prepare("
                SELECT e_wallet_balance, investment_wallet_balance 
                FROM wallets 
                WHERE user_id = ?
            ");
            $walletStmt->execute([$this->userId]);
            $wallet = $walletStmt->fetch();

            if (!$wallet) {
                $this->sendResponse(400, false, 'Wallet not found');
            }

            $eWalletBalance = (float)$wallet['e_wallet_balance'];
            $invWalletBalance = (float)$wallet['investment_wallet_balance'];

            // Check if sufficient balance
            if ($transferType === 'e_to_investment') {
                if ($amount > $eWalletBalance) {
                    $this->sendResponse(400, false, 'Insufficient E-Wallet balance');
                }
            } else {
                if ($amount > $invWalletBalance) {
                    $this->sendResponse(400, false, 'Insufficient Investment Wallet balance');
                }
            }

            // Perform transfer in transaction
            $this->conn->beginTransaction();

            try {
                error_log("=== TRANSFER DEBUG ===");
                error_log("Transfer Type: $transferType");
                error_log("Amount: $amount");
                error_log("User ID: " . $this->userId);
                error_log("E-Wallet Balance Before: $eWalletBalance");
                error_log("Inv-Wallet Balance Before: $invWalletBalance");

                if ($transferType === 'e_to_investment') {
                    // Transfer from E-Wallet to Investment Wallet
                    $updateStmt = $this->conn->prepare("
                        UPDATE wallets 
                        SET e_wallet_balance = e_wallet_balance - ?,
                            investment_wallet_balance = investment_wallet_balance + ?
                        WHERE user_id = ?
                    ");
                    $updateStmt->execute([$amount, $amount, $this->userId]);
                    error_log("Rows affected: " . $updateStmt->rowCount());
                    $description = "Transfer from E-Wallet to Investment Wallet";
                    $walletType = 'e_wallet';
                } else {
                    // Transfer from Investment Wallet to E-Wallet
                    $updateStmt = $this->conn->prepare("
                        UPDATE wallets 
                        SET e_wallet_balance = e_wallet_balance + ?,
                            investment_wallet_balance = investment_wallet_balance - ?
                        WHERE user_id = ?
                    ");
                    $updateStmt->execute([$amount, $amount, $this->userId]);
                    error_log("Rows affected: " . $updateStmt->rowCount());
                    $description = "Transfer from Investment Wallet to E-Wallet";
                    $walletType = 'investment_wallet';
                }

                // Get updated balances for transaction record
                $walletStmt = $this->conn->prepare("
                    SELECT e_wallet_balance, investment_wallet_balance 
                    FROM wallets 
                    WHERE user_id = ?
                ");
                $walletStmt->execute([$this->userId]);
                $updatedWallet = $walletStmt->fetch();

                error_log("E-Wallet Balance After: " . $updatedWallet['e_wallet_balance']);
                error_log("Inv-Wallet Balance After: " . $updatedWallet['investment_wallet_balance']);

                // Record transaction in transactions table
                $transStmt = $this->conn->prepare("
                    INSERT INTO transactions (
                        user_id, wallet_type, type, amount, 
                        balance_before, balance_after, description, 
                        reference_type, status
                    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'completed')
                ");
                
                $balanceBefore = ($transferType === 'e_to_investment') 
                    ? $eWalletBalance 
                    : $invWalletBalance;
                $balanceAfter = ($transferType === 'e_to_investment') 
                    ? ($eWalletBalance - $amount) 
                    : ($invWalletBalance - $amount);

                $transStmt->execute([
                    $this->userId,
                    $walletType,
                    'debit',  // transfer is a debit from source wallet
                    $amount,
                    $balanceBefore,
                    $balanceAfter,
                    $description,
                    'transfer'
                ]);

                $this->conn->commit();

                // Return updated wallet data
                $data = [
                    'e_wallet_balance' => (float)$updatedWallet['e_wallet_balance'],
                    'investment_wallet_balance' => (float)$updatedWallet['investment_wallet_balance'],
                    'transfer_amount' => $amount,
                    'transfer_type' => $transferType,
                ];

                $this->sendResponse(200, true, 'Transfer completed successfully', $data);

            } catch (Exception $e) {
                $this->conn->rollBack();
                throw $e;
            }

        } catch (Exception $e) {
            $this->sendResponse(500, false, 'Transfer failed: ' . $e->getMessage());
        }
    }

    private function sendResponse($code, $success, $message, $data = null) {
        http_response_code($code);
        echo json_encode(['success' => $success, 'message' => $message, 'data' => $data]);
        exit();
    }
}

if (isset($_GET['action'])) {
    $wallet = new WalletController();
    $wallet->handleRequest($_GET['action']);
}
?>
