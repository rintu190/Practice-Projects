<?php
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../utils/jwt.php';

class TeamController {
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
            case 'get_directs':
                $this->getDirectReferrals();
                break;
            default:
                $this->sendResponse(400, false, 'Invalid action');
        }
    }

    private function getDirectReferrals() {
        try {
            $stmt = $this->conn->prepare("
                SELECT 
                    u.id, 
                    u.phone, 
                    u.created_at,
                    p.full_name,
                    p.profile_image,
                    (SELECT COUNT(*) FROM genealogy WHERE sponsor_id = u.id) as team_size,
                    (SELECT COALESCE(SUM(amount), 0) FROM user_investments WHERE user_id = u.id AND status = 'active') as total_investment,
                    CASE 
                        WHEN EXISTS (SELECT 1 FROM user_investments WHERE user_id = u.id AND status = 'active') THEN 'Active'
                        ELSE 'Inactive'
                    END as status
                FROM genealogy g
                JOIN users u ON g.user_id = u.id
                LEFT JOIN user_profiles p ON u.id = p.user_id
                WHERE g.sponsor_id = ?
                ORDER BY u.created_at DESC
            ");
            $stmt->execute([$this->userId]);
            $members = $stmt->fetchAll(PDO::FETCH_ASSOC);

            $this->sendResponse(200, true, 'Team members fetched', $members);
        } catch (Exception $e) {
            $this->sendResponse(500, false, 'Failed to fetch team members: ' . $e->getMessage());
        }
    }

    private function sendResponse($code, $success, $message, $data = null) {
        http_response_code($code);
        echo json_encode(['success' => $success, 'message' => $message, 'data' => $data]);
        exit();
    }
}

if (isset($_GET['action'])) {
    $controller = new TeamController();
    $controller->handleRequest($_GET['action']);
}
?>
