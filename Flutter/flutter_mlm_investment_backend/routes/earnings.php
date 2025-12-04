<?php
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../utils/jwt.php';

class EarningsController {
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
            case 'get_breakdown':
                $this->getEarningsBreakdown();
                break;
            case 'get_history':
                $this->getEarningsHistory();
                break;
            default:
                $this->sendResponse(400, false, 'Invalid action');
        }
    }

    private function getEarningsBreakdown() {
        try {
            // Get current balances
            $stmt = $this->conn->prepare("
                SELECT earnings_balance, total_earned 
                FROM wallets 
                WHERE user_id = ?
            ");
            $stmt->execute([$this->userId]);
            $wallet = $stmt->fetch();

            // Get commissions breakdown by type
            $commStmt = $this->conn->prepare("
                SELECT 
                    commission_type,
                    COUNT(*) as count,
                    SUM(amount) as total
                FROM commissions 
                WHERE user_id = ? AND status = 'paid'
                GROUP BY commission_type
            ");
            $commStmt->execute([$this->userId]);
            $commissions = $commStmt->fetchAll(PDO::FETCH_ASSOC);

            // Get investment profits breakdown by product
            $profitStmt = $this->conn->prepare("
                SELECT 
                    ip.name as product_name,
                    COUNT(*) as count,
                    SUM(ipr.amount) as total
                FROM investment_profits ipr
                JOIN user_investments ui ON ipr.investment_id = ui.id
                JOIN investment_products ip ON ui.product_id = ip.id
                WHERE ipr.user_id = ?
                GROUP BY ip.id, ip.name
            ");
            $profitStmt->execute([$this->userId]);
            $profits = $profitStmt->fetchAll(PDO::FETCH_ASSOC);

            // Calculate totals
            $totalCommissions = array_sum(array_column($commissions, 'total'));
            $totalProfits = array_sum(array_column($profits, 'total'));

            // Get withdrawal history
            $withdrawStmt = $this->conn->prepare("
                SELECT SUM(amount) as total_withdrawn
                FROM earnings_withdrawals
                WHERE user_id = ? AND status = 'completed'
            ");
            $withdrawStmt->execute([$this->userId]);
            $totalWithdrawn = $withdrawStmt->fetchColumn() ?? 0;

            $this->sendResponse(200, true, 'Earnings breakdown fetched', [
                'current_balance' => (float)($wallet['earnings_balance'] ?? 0),
                'total_earned' => (float)($wallet['total_earned'] ?? 0),
                'total_withdrawn' => (float)$totalWithdrawn,
                'commissions' => [
                    'total' => (float)$totalCommissions,
                    'breakdown' => array_map(function($item) {
                        return [
                            'type' => $item['commission_type'],
                            'count' => (int)$item['count'],
                            'amount' => (float)$item['total']
                        ];
                    }, $commissions)
                ],
                'profits' => [
                    'total' => (float)$totalProfits,
                    'breakdown' => array_map(function($item) {
                        return [
                            'product' => $item['product_name'],
                            'count' => (int)$item['count'],
                            'amount' => (float)$item['total']
                        ];
                    }, $profits)
                ]
            ]);

        } catch (Exception $e) {
            $this->sendResponse(500, false, 'Failed to fetch earnings breakdown: ' . $e->getMessage());
        }
    }

    private function getEarningsHistory() {
        try {
            $limit = $_GET['limit'] ?? 50;
            $offset = $_GET['offset'] ?? 0;

            // Get all earnings transactions (commissions + profits)
            $stmt = $this->conn->prepare("
                SELECT * FROM (
                    SELECT 
                        'commission' as source_type,
                        commission_type as type,
                        amount,
                        description,
                        created_at
                    FROM commissions
                    WHERE user_id = ? AND status = 'paid'
                    
                    UNION ALL
                    
                    SELECT 
                        'profit' as source_type,
                        'investment_profit' as type,
                        amount,
                        CONCAT('Investment Profit - ', 
                            (SELECT name FROM investment_products WHERE id = 
                                (SELECT product_id FROM user_investments WHERE id = investment_id)
                            )
                        ) as description,
                        profit_date as created_at
                    FROM investment_profits
                    WHERE user_id = ?
                ) as earnings
                ORDER BY created_at DESC
                LIMIT ? OFFSET ?
            ");
            $stmt->execute([$this->userId, $this->userId, (int)$limit, (int)$offset]);
            $history = $stmt->fetchAll(PDO::FETCH_ASSOC);

            $this->sendResponse(200, true, 'Earnings history fetched', $history);

        } catch (Exception $e) {
            $this->sendResponse(500, false, 'Failed to fetch earnings history: ' . $e->getMessage());
        }
    }

    private function sendResponse($code, $success, $message, $data = null) {
        http_response_code($code);
        echo json_encode(['success' => $success, 'message' => $message, 'data' => $data]);
        exit();
    }
}

if (isset($_GET['action'])) {
    $earnings = new EarningsController();
    $earnings->handleRequest($_GET['action']);
}
?>
