<?php
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../utils/jwt.php';

class DashboardController {
    private $db;
    private $conn;
    private $userId;

    public function __construct() {
        $this->db = Database::getInstance();
        $this->conn = $this->db->getConnection();
        $this->authenticate();
    }

    private function authenticate() {
        // Try to get headers using getallheaders() if available
        $headers = function_exists('getallheaders') ? getallheaders() : [];
        $authHeader = $headers['Authorization'] ?? '';

        // Fallback to $_SERVER['HTTP_AUTHORIZATION']
        if (empty($authHeader) && isset($_SERVER['HTTP_AUTHORIZATION'])) {
            $authHeader = $_SERVER['HTTP_AUTHORIZATION'];
        }

        // Debug logging (remove in production)
        // error_log("Auth Header: " . $authHeader);
        
        if (preg_match('/Bearer\s(\S+)/', $authHeader, $matches)) {
            $token = $matches[1];
            $payload = JWT::verify($token);
            if ($payload) {
                $this->userId = $payload['id'];
                return;
            } else {
                // error_log("Token verification failed");
            }
        } else {
            // error_log("No Bearer token found");
        }
        
        $this->sendResponse(401, false, 'Unauthorized');
    }

    public function handleRequest($action) {
        switch ($action) {
            case 'get_data':
                $this->getDashboardData();
                break;
            default:
                $this->sendResponse(400, false, 'Invalid action');
        }
    }

    private function getDashboardData() {
        try {
            // 1. Get User Profile (no rank system yet, default to Member)
            $userStmt = $this->conn->prepare("
                SELECT u.phone, u.referral_code, u.kyc_status, p.full_name, p.profile_image
                FROM users u
                LEFT JOIN user_profiles p ON u.id = p.user_id
                WHERE u.id = ?
            ");
            $userStmt->execute([$this->userId]);
            $user = $userStmt->fetch();

            // 2. Get Wallet Balance (e_wallet and earnings)
            $walletStmt = $this->conn->prepare("
                SELECT e_wallet_balance, earnings_balance, total_earned 
                FROM wallets 
                WHERE user_id = ?
            ");
            $walletStmt->execute([$this->userId]);
            $wallet = $walletStmt->fetch();

            // 3. Get Investment Summary
            $invStmt = $this->conn->prepare("
                SELECT 
                    SUM(amount) as total_invested
                FROM user_investments 
                WHERE user_id = ? AND status = 'active'
            ");
            $invStmt->execute([$this->userId]);
            $investment = $invStmt->fetch();

            // 3b. Get Unrealized P&L (from daily_pnl only) for ACTIVE investments
            $unrealizedStmt = $this->conn->prepare("
                SELECT SUM(dp.net_pnl) as total_unrealized_pnl 
                FROM daily_pnl dp
                JOIN user_investments ui ON dp.investment_id = ui.id
                WHERE dp.user_id = ? AND ui.status = 'active'
            ");
            $unrealizedStmt->execute([$this->userId]);
            $unrealizedPnl = (float)($unrealizedStmt->fetch()['total_unrealized_pnl'] ?? 0);

            // 3c. Get Realized P&L (from investment_profits) for ACTIVE investments
            // This helps show the total return of current active investments
            $realizedStmt = $this->conn->prepare("
                SELECT SUM(ip.amount) as total_realized_pnl
                FROM investment_profits ip
                JOIN user_investments ui ON ip.investment_id = ui.id
                WHERE ip.user_id = ? AND ui.status = 'active'
            ");
            $realizedStmt->execute([$this->userId]);
            $realizedPnl = (float)($realizedStmt->fetch()['total_realized_pnl'] ?? 0);

            // Calculate current value = total_invested + unrealized_pnl
            // Realized profits are already in wallet/earnings, so they don't add to current investment value
            // unless we want to show 'Total Value Generated', but 'Current Value' usually implies liquidation value.
            // For now, let's assume Current Value = Principal + Unrealized Gains
            $totalInvested = (float)($investment['total_invested'] ?? 0);
            $currentValue = $totalInvested + $unrealizedPnl;
            
            // Total Profit on Active Investments = Realized + Unrealized
            $totalActiveProfit = $realizedPnl + $unrealizedPnl;

            // 4. Get Team Stats from genealogy
            $teamStmt = $this->conn->prepare("
                SELECT COUNT(*) as total_downline
                FROM genealogy 
                WHERE sponsor_id = ?
            ");
            $teamStmt->execute([$this->userId]);
            $team = $teamStmt->fetch();
            
            // Count active members (users who have made investments)
            $activeStmt = $this->conn->prepare("
                SELECT COUNT(DISTINCT ui.user_id) as active_count
                FROM user_investments ui
                INNER JOIN genealogy g ON ui.user_id = g.user_id
                WHERE g.sponsor_id = ? AND ui.status = 'active'
            ");
            $activeStmt->execute([$this->userId]);
            $activeCount = $activeStmt->fetch()['active_count'] ?? 0;

            // 5. Today's P&L
            $pnlStmt = $this->conn->prepare("
                SELECT SUM(pnl) as today_pnl FROM (
                    SELECT net_pnl as pnl FROM daily_pnl WHERE user_id = ? AND pnl_date = CURRENT_DATE
                    UNION ALL
                    SELECT amount as pnl FROM investment_profits WHERE user_id = ? AND profit_date = CURRENT_DATE
                ) as combined
            ");
            $pnlStmt->execute([$this->userId, $this->userId]);
            $todayPnl = $pnlStmt->fetch()['today_pnl'] ?? 0;

            // 6. Total P&L (Unrealized)
            $totalPnlStmt = $this->conn->prepare("
                SELECT SUM(pnl) as total_pnl FROM (
                    SELECT net_pnl as pnl FROM daily_pnl WHERE user_id = ?
                    UNION ALL
                    SELECT amount as pnl FROM investment_profits WHERE user_id = ?
                ) as combined
            ");
            $totalPnlStmt->execute([$this->userId, $this->userId]);
            $totalPnl = $totalPnlStmt->fetch()['total_pnl'] ?? 0;

            // 7. Calculate Rank
            require_once __DIR__ . '/../utils/rank_calculator.php';
            $rankCalc = new RankCalculator();
            $rankData = $rankCalc->calculateUserRank($this->userId);

            $data = [
                'user' => [
                    'name' => $user['full_name'] ?? 'User',
                    'rank' => $rankData['current_rank'] ?? 'Basic',
                    'referral_code' => $user['referral_code'] ?? '',
                    'kyc_status' => $user['kyc_status'] ?? 'pending',
                    'profile_image' => $user['profile_image'],
                    'next_rank' => $rankData['next_rank'] ?? null,
                ],
                'wallet' => [
                    'balance' => (float)($wallet['e_wallet_balance'] ?? 0),
                    'earnings_balance' => (float)($wallet['earnings_balance'] ?? 0),
                    'total_earned' => (float)($wallet['total_earned'] ?? 0),
                ],
                'investment' => [
                    'total_invested' => $totalInvested,
                    'current_value' => $currentValue,
                    'total_profit' => $totalActiveProfit,
                    'unrealized_pnl' => $unrealizedPnl,
                ],
                'team' => [
                    'total_members' => (int)($team['total_downline'] ?? 0),
                    'active_members' => (int)$activeCount,
                ],
                'today_pnl' => (float)$todayPnl,
            ];

            $this->sendResponse(200, true, 'Dashboard data fetched', $data);

        } catch (Exception $e) {
            $this->sendResponse(500, false, 'Failed to fetch dashboard data: ' . $e->getMessage());
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
    $dashboard = new DashboardController();
    $dashboard->handleRequest($_GET['action']);
}
?>
