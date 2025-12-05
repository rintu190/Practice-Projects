<?php
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../utils/jwt.php';

class PnlController {
    private $db;
    private $conn;

    public function __construct() {
        $this->db = Database::getInstance();
        $this->conn = $this->db->getConnection();
    }

    public function handleRequest($action) {
        switch ($action) {
            case 'get_today':
                $this->getTodayPnl();
                break;
            case 'get_history':
                $this->getPnlHistory();
                break;
            case 'get_unrealized':
                $this->getUnrealizedPnl();
                break;
            case 'admin_upload':
                $this->adminUploadPnl();
                break;
            default:
                $this->sendResponse(400, false, 'Invalid action');
        }
    }

    private function authenticate() {
        $headers = function_exists('getallheaders') ? getallheaders() : [];
        $authHeader = $headers['Authorization'] ?? $headers['authorization'] ?? $_SERVER['HTTP_AUTHORIZATION'] ?? null;
        
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

    private function getTodayPnl() {
        $userId = $this->authenticate();

        try {
            // Get today's P&L from daily_pnl table
            // Get today's P&L from daily_pnl and investment_profits
            $stmt = $this->conn->prepare(
                "SELECT SUM(net_pnl) as today_pnl FROM (
                    SELECT net_pnl FROM daily_pnl WHERE user_id = ? AND DATE(pnl_date) = CURDATE()
                    UNION ALL
                    SELECT amount as net_pnl FROM investment_profits WHERE user_id = ? AND DATE(profit_date) = CURDATE()
                ) as combined"
            );
            $stmt->execute([$userId, $userId]);
            $result = $stmt->fetch();

            $todayPnl = $result['today_pnl'] ?? 0;

            $this->sendResponse(200, true, 'Today\'s P&L retrieved', [
                'today_pnl' => (float)$todayPnl,
                'date' => date('Y-m-d')
            ]);

        } catch (Exception $e) {
            $this->sendResponse(500, false, 'Failed to fetch today\'s P&L: ' . $e->getMessage());
        }
    }

    private function getPnlHistory() {
        $userId = $this->authenticate();
        $days = $_GET['days'] ?? 30;

        try {
            // Get historical P&L data - Fixed SQL mode compatibility
            // Combine manual daily_pnl and automated investment_profits
            $stmt = $this->conn->prepare(
                "SELECT date, SUM(net_pnl) as net_pnl FROM (
                    SELECT DATE(pnl_date) as date, net_pnl FROM daily_pnl WHERE user_id = ?
                    UNION ALL
                    SELECT DATE(profit_date) as date, amount as net_pnl FROM investment_profits WHERE user_id = ?
                ) as combined
                WHERE date >= DATE_SUB(CURDATE(), INTERVAL ? DAY)
                GROUP BY date
                ORDER BY date ASC"
            );
            $stmt->execute([$userId, $userId, $days]);
            $history = $stmt->fetchAll();

            // Calculate cumulative P&L
            $cumulative = 0;
            $chartData = [];
            foreach ($history as $row) {
                $cumulative += (float)$row['net_pnl'];
                $chartData[] = [
                    'date' => $row['date'],
                    'net_pnl' => (float)$row['net_pnl'],
                    'cumulative' => $cumulative
                ];
            }

            $this->sendResponse(200, true, 'P&L history retrieved', [
                'history' => $chartData,
                'total_pnl' => $cumulative,
                'days' => (int)$days
            ]);

        } catch (Exception $e) {
            $this->sendResponse(500, false, 'Failed to fetch P&L history: ' . $e->getMessage());
        }
    }

    private function getUnrealizedPnl() {
        $userId = $this->authenticate();

        try {
            // Get unrealized P&L from investment_wallets table
            $stmt = $this->conn->prepare(
                "SELECT unrealized_pnl, total_invested
                 FROM investment_wallets
                 WHERE user_id = ?"
            );
            $stmt->execute([$userId]);
            $result = $stmt->fetch();

            $unrealizedPnl = $result['unrealized_pnl'] ?? 0;
            $totalInvested = $result['total_invested'] ?? 0;
            
            // Current value is total invested + unrealized P&L
            $currentValue = $totalInvested + $unrealizedPnl;

            // Calculate percentage
            $percentage = $totalInvested > 0 ? (($unrealizedPnl / $totalInvested) * 100) : 0;

            $this->sendResponse(200, true, 'Unrealized P&L calculated', [
                'unrealized_pnl' => (float)$unrealizedPnl,
                'total_invested' => (float)$totalInvested,
                'current_value' => (float)$currentValue,
                'percentage' => round($percentage, 2)
            ]);

        } catch (Exception $e) {
            $this->sendResponse(500, false, 'Failed to calculate unrealized P&L: ' . $e->getMessage());
        }
    }

    private function adminUploadPnl() {
        // This would be admin-only endpoint
        // For now, simplified version for testing
        $userId = $this->authenticate();
        $data = json_decode(file_get_contents("php://input"), true);

        $pnlAmount = $data['pnl_amount'] ?? null;
        $pnlDate = $data['pnl_date'] ?? date('Y-m-d');

        if ($pnlAmount === null) {
            $this->sendResponse(400, false, 'P&L amount required');
        }

        try {
            $stmt = $this->conn->prepare(
                "INSERT INTO daily_pnl (user_id, pnl_date, profit_amount) 
                 VALUES (?, ?, ?)"
            );
            $stmt->execute([$userId, $pnlDate, $pnlAmount]);

            $this->sendResponse(201, true, 'P&L uploaded successfully', [
                'id' => $this->conn->lastInsertId()
            ]);

        } catch (Exception $e) {
            $this->sendResponse(500, false, 'Failed to upload P&L: ' . $e->getMessage());
        }
    }

    private function sendResponse($code, $success, $message, $data = null) {
        http_response_code($code);
        $response = [
            'success' => $success,
            'message' => $message
        ];
        if ($data !== null) {
            $response['data'] = $data;
        }
        echo json_encode($response);
        exit();
    }
}

// Handle request
if (isset($_GET['action'])) {
    $pnl = new PnlController();
    $pnl->handleRequest($_GET['action']);
}
?>
