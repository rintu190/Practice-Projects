<?php
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../utils/jwt.php';

class ReferralController {
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
            case 'get_code':
                $this->getReferralCode();
                break;
            case 'get_analytics':
                $this->getAnalytics();
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

    private function getReferralCode() {
        try {
            $stmt = $this->conn->prepare("SELECT referral_code FROM users WHERE id = ?");
            $stmt->execute([$this->userId]);
            $code = $stmt->fetchColumn();

            // Generate link (mock URL for now)
            $link = "https://myapp.com/register?ref=" . $code;

            $this->sendResponse(200, true, 'Referral code fetched', [
                'code' => $code,
                'link' => $link
            ]);
        } catch (Exception $e) {
            $this->sendResponse(500, false, 'Failed to fetch referral code: ' . $e->getMessage());
        }
    }

    private function getAnalytics() {
        try {
            // 1. Total Referrals (Signups)
            $stmt = $this->conn->prepare("SELECT COUNT(*) FROM genealogy WHERE sponsor_id = ?");
            $stmt->execute([$this->userId]);
            $signups = $stmt->fetchColumn();

            // 2. Active Referrals (Invested)
            $stmt = $this->conn->prepare("
                SELECT COUNT(DISTINCT g.user_id) 
                FROM genealogy g
                JOIN user_investments ui ON g.user_id = ui.user_id
                WHERE g.sponsor_id = ? AND ui.status = 'active'
            ");
            $stmt->execute([$this->userId]);
            $active = $stmt->fetchColumn();

            // 3. Total Earned from Referrals
            $stmt = $this->conn->prepare("
                SELECT SUM(amount) 
                FROM commissions 
                WHERE user_id = ? AND (commission_type = 'direct_sponsor' OR commission_type = 'level_bonus')
            ");
            $stmt->execute([$this->userId]);
            $earned = $stmt->fetchColumn() ?? 0;

            // 4. Clicks (Mocked for now, would need a tracking table)
            $clicks = $signups * rand(2, 5) + rand(10, 50);

            $this->sendResponse(200, true, 'Analytics fetched', [
                'clicks' => (int)$clicks,
                'signups' => (int)$signups,
                'active_referrals' => (int)$active,
                'total_earned' => (float)$earned,
                'conversion_rate' => $clicks > 0 ? round(($signups / $clicks) * 100, 1) : 0
            ]);

        } catch (Exception $e) {
            $this->sendResponse(500, false, 'Failed to fetch analytics: ' . $e->getMessage());
        }
    }

    private function sendResponse($code, $success, $message, $data = null) {
        http_response_code($code);
        echo json_encode(['success' => $success, 'message' => $message, 'data' => $data]);
        exit();
    }
}

if (isset($_GET['action'])) {
    $controller = new ReferralController();
    $controller->handleRequest($_GET['action']);
}
?>
