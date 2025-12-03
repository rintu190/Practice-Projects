<?php
require_once __DIR__ . '/../daily_pnl.php';
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../utils/jwt.php';

class InvestmentController {
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
            case 'get_products':
                $this->getProducts();
                break;
            case 'get_my_investments':
                $this->getMyInvestments();
                break;
            case 'invest':
                $this->invest();
                break;
            case 'get_portfolio':
                $this->getPortfolio();
                break;
            case 'upload_daily_pnl':
                $daily = new DailyPnlController();
                $daily->uploadDailyPnl();
                break;
            case 'get_daily_pnl':
                $daily = new DailyPnlController();
                $daily->getDailyPnl();
                break;
            default:
                $this->sendResponse(400, false, 'Invalid action');
        }
    }

    private function getProducts() {
        try {
            $sql = "SELECT * FROM investment_products WHERE status = 'active'";
            $params = [];

            // Filters
            if (isset($_GET['type'])) {
                $sql .= " AND product_type = ?";
                $params[] = $_GET['type'];
            }
            if (isset($_GET['risk'])) {
                $sql .= " AND risk_level = ?";
                $params[] = $_GET['risk'];
            }
            if (isset($_GET['frequency'])) {
                $sql .= " AND roi_frequency = ?";
                $params[] = $_GET['frequency'];
            }

            $stmt = $this->conn->prepare($sql);
            $stmt->execute($params);
            $products = $stmt->fetchAll(PDO::FETCH_ASSOC);
            $this->sendResponse(200, true, 'Products fetched', $products);
        } catch (Exception $e) {
            $this->sendResponse(500, false, 'Failed to fetch products: ' . $e->getMessage());
        }
    }

    private function invest() {
        $data = json_decode(file_get_contents("php://input"), true);
        $productId = $data['product_id'] ?? null;
        $amount = $data['amount'] ?? null;
        $autoRenew = $data['auto_renew'] ?? false;
        // wallet_type removed - always use e_wallet

        if (!$productId || !$amount || $amount <= 0) {
            $this->sendResponse(400, false, 'Invalid product or amount');
        }

        try {
            $this->conn->beginTransaction();

            // 1. Get Product Details
            $prodStmt = $this->conn->prepare("SELECT * FROM investment_products WHERE id = ? AND status = 'active'");
            $prodStmt->execute([$productId]);
            $product = $prodStmt->fetch(PDO::FETCH_ASSOC);

            if (!$product) {
                throw new Exception('Product not found or inactive');
            }

            // Validate Amount
            if ($amount < $product['min_amount']) {
                throw new Exception('Amount below minimum investment');
            }
            if ($product['max_amount'] && $amount > $product['max_amount']) {
                throw new Exception('Amount exceeds maximum investment');
            }

            // 2. Check E-Wallet Balance (only one wallet now)
            $walletStmt = $this->conn->prepare("SELECT e_wallet_balance as balance FROM wallets WHERE user_id = ? FOR UPDATE");
            $walletStmt->execute([$this->userId]);
            $wallet = $walletStmt->fetch(PDO::FETCH_ASSOC);

            if (!$wallet || $wallet['balance'] < $amount) {
                throw new Exception('Insufficient wallet balance');
            }

            // 3. Deduct Amount from E-Wallet
            $deductStmt = $this->conn->prepare("UPDATE wallets SET e_wallet_balance = e_wallet_balance - ? WHERE user_id = ?");
            $deductStmt->execute([$amount, $this->userId]);

            // 4. Create Investment Record
            $maturityDate = date('Y-m-d', strtotime('+' . $product['duration_days'] . ' days'));
            
            $investStmt = $this->conn->prepare("
                INSERT INTO user_investments (
                    user_id, product_id, amount, roi_percentage, created_at, 
                    maturity_date, auto_renew, status
                ) VALUES (?, ?, ?, ?, NOW(), ?, ?, 'active')
            ");
            $investStmt->execute([
                $this->userId, 
                $productId, 
                $amount, 
                $product['roi_percentage'],
                $maturityDate, 
                $autoRenew ? 1 : 0
            ]);
            
            $investmentId = $this->conn->lastInsertId();

            // 5. Create Transaction Record (always e_wallet now)
            $transStmt = $this->conn->prepare("
                INSERT INTO transactions (
                    user_id, wallet_type, type, amount, 
                    description, reference_type, reference_id, created_at
                ) VALUES (?, 'e_wallet', 'debit', ?, ?, 'investment', ?, NOW())
            ");
            $transStmt->execute([
                $this->userId, 
                $amount, 
                "Investment in " . $product['name'], 
                $investmentId
            ]);

            $this->conn->commit();

            // 7. Distribute Commissions (Outside transaction or inside? Inside is safer for consistency)
            // But if commission fails, should investment fail? 
            // Ideally yes, to ensure integrity.
            // Let's do it inside a new transaction or same one.
            // Since I already committed, I should probably have done it before commit.
            // But CommissionCalculator has its own transaction handling.
            // Let's move commit to after commission distribution if possible, 
            // OR handle commission separately.
            // Given the structure of CommissionCalculator (starts its own transaction), 
            // I should call it AFTER commit, or modify it to accept connection.
            // For now, calling it after commit is safer to avoid nested transaction issues if not handled.
            // If commission fails, we can log it. Investment is already secure.
            
            require_once __DIR__ . '/../utils/commission_calculator.php';
            $commCalc = new CommissionCalculator();
            $commCalc->distributeCommissions($this->userId, $amount, $investmentId);

            $this->sendResponse(200, true, 'Investment successful', ['investment_id' => $investmentId]);

        } catch (Exception $e) {
            if ($this->conn->inTransaction()) {
                $this->conn->rollBack();
            }
            $this->sendResponse(500, false, $e->getMessage());
        }
    }

    private function getMyInvestments() {
        try {
            $status = $_GET['status'] ?? 'all';
            
            $sql = "SELECT 
                    ui.*,
                    ip.name as product_name,
                    ip.roi_percentage as expected_roi,
                    ip.duration_days
                FROM user_investments ui
                JOIN investment_products ip ON ui.product_id = ip.id
                WHERE ui.user_id = ?";
            
            $params = [$this->userId];
            
            if ($status !== 'all') {
                $sql .= " AND ui.status = ?";
                $params[] = $status;
            }
            
            $sql .= " ORDER BY ui.created_at DESC";
            
            $stmt = $this->conn->prepare($sql);
            $stmt->execute($params);
            $investments = $stmt->fetchAll();
            
            // Calculate current value and progress for each investment
            foreach ($investments as &$inv) {
                $startDate = new DateTime($inv['created_at']);
                $now = new DateTime();
                $maturityDate = new DateTime($inv['maturity_date']);
                
                $totalDuration = $startDate->diff($maturityDate)->days;
                $elapsed = $startDate->diff($now)->days;
                
                // Cap progress at 100%
                $progress = ($totalDuration > 0) ? min(100, ($elapsed / $totalDuration) * 100) : 0;
                $inv['progress'] = round($progress, 2);
                
                // Use total_profit_earned from database instead of calculating
                $inv['current_value'] = (float)$inv['amount'] + (float)$inv['total_profit_earned'];
            }
            
            $this->sendResponse(200, true, 'Investments fetched', $investments);
        } catch (Exception $e) {
            $this->sendResponse(500, false, 'Failed to fetch investments: ' . $e->getMessage());
        }
    }

    private function getPortfolio() {
        // ... (existing implementation or improved)
        $this->getMyInvestments(); // Reuse for now
    }

    private function sendResponse($code, $success, $message, $data = null) {
        http_response_code($code);
        echo json_encode(['success' => $success, 'message' => $message, 'data' => $data]);
        exit();
    }
}

if (isset($_GET['action'])) {
    $investment = new InvestmentController();
    $investment->handleRequest($_GET['action']);
}
?>
