<?php
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../utils/jwt.php';

class BankController {
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
            case 'add':
                $this->addBankAccount();
                break;
            case 'get':
                $this->getBankAccounts();
                break;
            case 'update':
                $this->updateBankAccount();
                break;
            case 'delete':
                $this->deleteBankAccount();
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

    private function addBankAccount() {
        $data = json_decode(file_get_contents('php://input'), true);
        
        $accountHolder = $data['account_holder_name'] ?? null;
        $accountNumber = $data['account_number'] ?? null;
        $ifscCode = $data['ifsc_code'] ?? null;
        $bankName = $data['bank_name'] ?? null;
        $branch = $data['branch_name'] ?? null;
        $accountType = $data['account_type'] ?? 'savings';
        $upiId = $data['upi_id'] ?? null;

        if (!$accountHolder || !$accountNumber || !$ifscCode || !$bankName) {
            $this->sendResponse(400, false, 'All fields are required');
        }

        try {
            // Check if account already exists
            $stmt = $this->conn->prepare("
                SELECT id FROM bank_details 
                WHERE user_id = ? AND account_number = ?
            ");
            $stmt->execute([$this->userId, $accountNumber]);
            
            if ($stmt->fetch()) {
                $this->sendResponse(400, false, 'This account number is already added');
            }

            $stmt = $this->conn->prepare("
                INSERT INTO bank_details (user_id, account_holder_name, account_number, ifsc_code, bank_name, branch_name, account_type, upi_id)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            ");
            $stmt->execute([$this->userId, $accountHolder, $accountNumber, $ifscCode, $bankName, $branch, $accountType, $upiId]);
            
            $this->sendResponse(200, true, 'Bank account added successfully', [
                'id' => $this->conn->lastInsertId()
            ]);
        } catch (Exception $e) {
            $this->sendResponse(500, false, 'Failed to add bank account: ' . $e->getMessage());
        }
    }

    private function getBankAccounts() {
        try {
            $stmt = $this->conn->prepare("
                SELECT id, account_holder_name, account_number, ifsc_code, bank_name, branch_name, account_type, upi_id, is_verified, created_at, updated_at
                FROM bank_details
                WHERE user_id = ?
                ORDER BY created_at DESC
                LIMIT 1
            ");
            $stmt->execute([$this->userId]);
            $account = $stmt->fetch(PDO::FETCH_ASSOC);
            
            if (!$account) {
                // No bank details found, return empty response
                $this->sendResponse(200, true, 'No bank details found', ['data' => null]);
            }
            
            // Return single account in the format frontend expects
            $this->sendResponse(200, true, 'Bank details fetched', ['data' => $account]);
        } catch (Exception $e) {
            $this->sendResponse(500, false, 'Failed to fetch bank details: ' . $e->getMessage());
        }
    }

    private function deleteBankAccount() {
        $data = json_decode(file_get_contents('php://input'), true);
        $bankId = $data['bank_id'] ?? null;

        if (!$bankId) {
            $this->sendResponse(400, false, 'Bank ID required');
        }

        try {
            $stmt = $this->conn->prepare("
                DELETE FROM bank_details 
                WHERE id = ? AND user_id = ?
            ");
            $stmt->execute([$bankId, $this->userId]);
            
            if ($stmt->rowCount() > 0) {
                $this->sendResponse(200, true, 'Bank account deleted successfully');
            } else {
                $this->sendResponse(404, false, 'Bank account not found');
            }
        } catch (Exception $e) {
            $this->sendResponse(500, false, 'Failed to delete bank account: ' . $e->getMessage());
        }
    }

    private function updateBankAccount() {
        $data = json_decode(file_get_contents('php://input'), true);
        
        $accountHolder = $data['account_holder_name'] ?? null;
        $accountNumber = $data['account_number'] ?? null;
        $ifscCode = $data['ifsc_code'] ?? null;
        $bankName = $data['bank_name'] ?? null;
        $branch = $data['branch_name'] ?? null;
        $accountType = $data['account_type'] ?? 'savings';
        $upiId = $data['upi_id'] ?? null;

        // Validate required fields
        if (!$accountHolder || !$accountNumber || !$ifscCode || !$bankName) {
            $this->sendResponse(400, false, 'All fields are required');
        }

        try {
            // Check if account already exists for user
            $stmt = $this->conn->prepare("
                SELECT id FROM bank_details 
                WHERE user_id = ?
                LIMIT 1
            ");
            $stmt->execute([$this->userId]);
            $existingBank = $stmt->fetch();
            
            if (!$existingBank) {
                $this->sendResponse(404, false, 'No bank account found to update');
            }

            $bankId = $existingBank['id'];

            $stmt = $this->conn->prepare("
                UPDATE bank_details 
                SET account_holder_name = ?, 
                    account_number = ?, 
                    ifsc_code = ?, 
                    bank_name = ?, 
                    branch_name = ?,
                    account_type = ?,
                    upi_id = ?,
                    updated_at = NOW()
                WHERE id = ? AND user_id = ?
            ");
            $stmt->execute([
                $accountHolder, 
                $accountNumber, 
                $ifscCode, 
                $bankName, 
                $branch,
                $accountType,
                $upiId,
                $bankId,
                $this->userId
            ]);
            
            $this->sendResponse(200, true, 'Bank account updated successfully', [
                'id' => $bankId
            ]);
        } catch (Exception $e) {
            $this->sendResponse(500, false, 'Failed to update bank account: ' . $e->getMessage());
        }
    }

    private function sendResponse($code, $success, $message, $data = null) {
        http_response_code($code);
        echo json_encode(['success' => $success, 'message' => $message, 'data' => $data]);
        exit();
    }
}

if (isset($_GET['action'])) {
    $controller = new BankController();
    $controller->handleRequest($_GET['action']);
}
?>
