<?php
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../utils/jwt.php';
require_once __DIR__ . '/../utils/profit_calculator.php';

class InvestmentActionsController {
    private $db;
    private $conn;
    private $userId;
    private $calculator;

    public function __construct() {
        $this->db = Database::getInstance();
        $this->conn = $this->db->getConnection();
        $this->calculator = new ProfitCalculator();
    }

    public function handleRequest($action) {
        $this->userId = $this->authenticate();

        switch ($action) {
            case 'sell':
                $this->sellInvestment();
                break;
            case 'renew':
                $this->renewInvestment();
                break;
            case 'toggle_auto_renew':
                $this->toggleAutoRenew();
                break;
            case 'upgrade':
                $this->upgradeInvestment();
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

    private function sellInvestment() {
        $data = json_decode(file_get_contents('php://input'), true);
        $investmentId = $data['investment_id'] ?? null;

        if (!$investmentId) {
            $this->sendResponse(400, false, 'Investment ID required');
        }

        try {
            $this->conn->beginTransaction();

            // Get investment details
            $stmt = $this->conn->prepare("
                SELECT ui.*, ip.early_withdrawal_penalty
                FROM user_investments ui
                JOIN investment_products ip ON ui.product_id = ip.id
                WHERE ui.id = ? AND ui.user_id = ? AND ui.status = 'active'
            ");
            $stmt->execute([$investmentId, $this->userId]);
            $investment = $stmt->fetch(PDO::FETCH_ASSOC);

            if (!$investment) {
                $this->conn->rollBack();
                $this->sendResponse(404, false, 'Investment not found or already closed');
            }

            // Calculate return amount with penalty
            $principal = $investment['amount'];
            $profit = $investment['total_profit_earned'];
            $penalty = ($principal * $investment['early_withdrawal_penalty']) / 100;
            $returnAmount = $principal + $profit - $penalty;

            // Credit to investment wallet
            $stmt = $this->conn->prepare("
                UPDATE investment_wallets 
                SET balance = balance + ?
                WHERE user_id = ?
            ");
            $stmt->execute([$returnAmount, $this->userId]);

            // Mark investment as withdrawn
            $stmt = $this->conn->prepare("
                UPDATE user_investments 
                SET status = 'withdrawn'
                WHERE id = ?
            ");
            $stmt->execute([$investmentId]);

            // Create transaction record
            $stmt = $this->conn->prepare("
                INSERT INTO transactions (user_id, type, amount, description, reference_type, reference_id, created_at)
                VALUES (?, 'credit', ?, ?, 'investment_withdrawal', ?, NOW())
            ");
            $stmt->execute([
                $this->userId,
                $returnAmount,
                "Investment withdrawal (Penalty: ₹$penalty)",
                $investmentId
            ]);

            $this->conn->commit();

            $this->sendResponse(200, true, 'Investment sold successfully', [
                'principal' => $principal,
                'profit' => $profit,
                'penalty' => $penalty,
                'return_amount' => $returnAmount
            ]);
        } catch (Exception $e) {
            $this->conn->rollBack();
            $this->sendResponse(500, false, 'Failed to sell investment: ' . $e->getMessage());
        }
    }

    private function renewInvestment() {
        $data = json_decode(file_get_contents('php://input'), true);
        $investmentId = $data['investment_id'] ?? null;

        if (!$investmentId) {
            $this->sendResponse(400, false, 'Investment ID required');
        }

        try {
            $this->conn->beginTransaction();

            // Get investment details
            $stmt = $this->conn->prepare("
                SELECT ui.*, ip.duration_days
                FROM user_investments ui
                JOIN investment_products ip ON ui.product_id = ip.id
                WHERE ui.id = ? AND ui.user_id = ? AND ui.status = 'matured'
            ");
            $stmt->execute([$investmentId, $this->userId]);
            $investment = $stmt->fetch(PDO::FETCH_ASSOC);

            if (!$investment) {
                $this->conn->rollBack();
                $this->sendResponse(404, false, 'Investment not found or not matured');
            }

            // Create new investment with principal + profit
            $newAmount = $investment['amount'] + $investment['total_profit_earned'];
            $maturityDate = date('Y-m-d', strtotime('+' . $investment['duration_days'] . ' days'));

            $stmt = $this->conn->prepare("
                INSERT INTO user_investments (user_id, product_id, amount, created_at, maturity_date, auto_renew, status)
                VALUES (?, ?, ?, NOW(), ?, ?, 'active')
            ");
            $stmt->execute([
                $this->userId,
                $investment['product_id'],
                $newAmount,
                $maturityDate,
                $investment['auto_renew']
            ]);

            $newInvestmentId = $this->conn->lastInsertId();

            // Mark old investment as renewed
            $stmt = $this->conn->prepare("UPDATE user_investments SET status = 'renewed' WHERE id = ?");
            $stmt->execute([$investmentId]);

            $this->conn->commit();

            $this->sendResponse(200, true, 'Investment renewed successfully', [
                'new_investment_id' => $newInvestmentId,
                'amount' => $newAmount,
                'maturity_date' => $maturityDate
            ]);
        } catch (Exception $e) {
            $this->conn->rollBack();
            $this->sendResponse(500, false, 'Failed to renew investment: ' . $e->getMessage());
        }
    }

    private function toggleAutoRenew() {
        $data = json_decode(file_get_contents('php://input'), true);
        $investmentId = $data['investment_id'] ?? null;
        $autoRenew = $data['auto_renew'] ?? false;

        if (!$investmentId) {
            $this->sendResponse(400, false, 'Investment ID required');
        }

        try {
            $stmt = $this->conn->prepare("
                UPDATE user_investments 
                SET auto_renew = ?
                WHERE id = ? AND user_id = ? AND status = 'active'
            ");
            $stmt->execute([$autoRenew ? 1 : 0, $investmentId, $this->userId]);

            if ($stmt->rowCount() > 0) {
                $this->sendResponse(200, true, 'Auto-renew updated', [
                    'auto_renew' => $autoRenew
                ]);
            } else {
                $this->sendResponse(404, false, 'Investment not found');
            }
        } catch (Exception $e) {
            $this->sendResponse(500, false, 'Failed to update auto-renew: ' . $e->getMessage());
        }
    }

    private function upgradeInvestment() {
        $data = json_decode(file_get_contents('php://input'), true);
        $investmentId = $data['investment_id'] ?? null;
        $newProductId = $data['new_product_id'] ?? null;
        $additionalAmount = $data['additional_amount'] ?? 0;

        if (!$investmentId || !$newProductId) {
            $this->sendResponse(400, false, 'Investment ID and new product ID required');
        }

        try {
            $this->conn->beginTransaction();

            // Get current investment
            $stmt = $this->conn->prepare("
                SELECT * FROM user_investments 
                WHERE id = ? AND user_id = ? AND status = 'active'
            ");
            $stmt->execute([$investmentId, $this->userId]);
            $investment = $stmt->fetch(PDO::FETCH_ASSOC);

            if (!$investment) {
                $this->conn->rollBack();
                $this->sendResponse(404, false, 'Investment not found');
            }

            // Get new product details
            $stmt = $this->conn->prepare("SELECT * FROM investment_products WHERE id = ?");
            $stmt->execute([$newProductId]);
            $newProduct = $stmt->fetch(PDO::FETCH_ASSOC);

            if (!$newProduct) {
                $this->conn->rollBack();
                $this->sendResponse(404, false, 'New product not found');
            }

            // Calculate new investment amount
            $currentValue = $investment['amount'] + $investment['total_profit_earned'];
            $newAmount = $currentValue + $additionalAmount;

            // Check wallet balance for additional amount
            if ($additionalAmount > 0) {
                $stmt = $this->conn->prepare("SELECT balance FROM investment_wallets WHERE user_id = ?");
                $stmt->execute([$this->userId]);
                $wallet = $stmt->fetch(PDO::FETCH_ASSOC);

                if (!$wallet || $wallet['balance'] < $additionalAmount) {
                    $this->conn->rollBack();
                    $this->sendResponse(400, false, 'Insufficient balance');
                }

                // Deduct additional amount
                $stmt = $this->conn->prepare("
                    UPDATE investment_wallets 
                    SET balance = balance - ?
                    WHERE user_id = ?
                ");
                $stmt->execute([$additionalAmount, $this->userId]);
            }

            // Create new investment
            $maturityDate = date('Y-m-d', strtotime('+' . $newProduct['duration_days'] . ' days'));
            $stmt = $this->conn->prepare("
                INSERT INTO user_investments (user_id, product_id, amount, created_at, maturity_date, auto_renew, status)
                VALUES (?, ?, ?, NOW(), ?, ?, 'active')
            ");
            $stmt->execute([
                $this->userId,
                $newProductId,
                $newAmount,
                $maturityDate,
                $investment['auto_renew']
            ]);

            $newInvestmentId = $this->conn->lastInsertId();

            // Mark old investment as withdrawn
            $stmt = $this->conn->prepare("UPDATE user_investments SET status = 'withdrawn' WHERE id = ?");
            $stmt->execute([$investmentId]);

            $this->conn->commit();

            $this->sendResponse(200, true, 'Investment upgraded successfully', [
                'new_investment_id' => $newInvestmentId,
                'amount' => $newAmount,
                'product_name' => $newProduct['name'],
                'maturity_date' => $maturityDate
            ]);
        } catch (Exception $e) {
            $this->conn->rollBack();
            $this->sendResponse(500, false, 'Failed to upgrade investment: ' . $e->getMessage());
        }
    }

    private function sendResponse($code, $success, $message, $data = null) {
        http_response_code($code);
        echo json_encode(['success' => $success, 'message' => $message, 'data' => $data]);
        exit();
    }
}

if (isset($_GET['action'])) {
    $controller = new InvestmentActionsController();
    $controller->handleRequest($_GET['action']);
}
?>
