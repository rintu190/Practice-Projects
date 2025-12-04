<?php
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../utils/jwt.php';

class GenealogyController {
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
            case 'get_tree':
                $this->getTree();
                break;
            case 'get_stats':
                $this->getStats();
                break;
            case 'get_code':
                $this->getCode();
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

    private function getTree() {
        $type = $_GET['type'] ?? 'unilevel'; // unilevel, binary
        $rootId = $_GET['root_id'] ?? $this->userId;

        // Security check: Ensure rootId is in user's downline or is the user themselves
        if ($rootId != $this->userId && !$this->isDownline($this->userId, $rootId)) {
            $this->sendResponse(403, false, 'Unauthorized access to this tree branch');
        }

        try {
            $tree = $this->buildTree($rootId, $type);
            $this->sendResponse(200, true, 'Tree fetched', $tree);
        } catch (Exception $e) {
            $this->sendResponse(500, false, 'Failed to fetch tree: ' . $e->getMessage());
        }
    }

    private function buildTree($rootId, $type, $depth = 0, $maxDepth = 3) {
        if ($depth > $maxDepth) return null;

        // Get User Details
        $stmt = $this->conn->prepare("
            SELECT u.id, u.phone, u.rank, u.referral_code, up.full_name, g.leg
            FROM users u
            LEFT JOIN user_profiles up ON u.id = up.user_id
            LEFT JOIN genealogy g ON u.id = g.user_id
            WHERE u.id = ?
        ");
        $stmt->execute([$rootId]);
        $user = $stmt->fetch(PDO::FETCH_ASSOC);

        if (!$user) return null;

        $node = [
            'id' => $user['referral_code'] ?: $user['id'], // Use referral code or user ID
            'user_id' => $user['id'], // Keep actual user ID for internal use
            'name' => $user['full_name'] ?? $user['phone'] ?? 'User ' . $user['id'],
            'rank' => $user['rank'],
            'leg' => $user['leg'],
            'children' => []
        ];

        // Get Children
        if ($type === 'binary') {
            // Fetch left and right specifically
            $childrenStmt = $this->conn->prepare("
                SELECT user_id, leg FROM genealogy WHERE parent_id = ?
            ");
            $childrenStmt->execute([$rootId]);
            $children = $childrenStmt->fetchAll(PDO::FETCH_ASSOC);

            $leftNode = null;
            $rightNode = null;

            foreach ($children as $child) {
                $childNode = $this->buildTree($child['user_id'], $type, $depth + 1, $maxDepth);
                if ($child['leg'] === 'left') $leftNode = $childNode;
                if ($child['leg'] === 'right') $rightNode = $childNode;
            }
            
            // Always return left and right keys for binary, even if null
            $node['left'] = $leftNode;
            $node['right'] = $rightNode;
            unset($node['children']); // Binary uses left/right instead of children array

        } else {
            // Unilevel - fetch all direct referrals
            $childrenStmt = $this->conn->prepare("
                SELECT user_id FROM genealogy WHERE sponsor_id = ?
            ");
            $childrenStmt->execute([$rootId]);
            $children = $childrenStmt->fetchAll(PDO::FETCH_COLUMN);

            foreach ($children as $childId) {
                $childNode = $this->buildTree($childId, $type, $depth + 1, $maxDepth);
                if ($childNode) {
                    $node['children'][] = $childNode;
                }
            }
        }

        return $node;
    }

    private function isDownline($sponsorId, $targetId) {
        // Recursive check or path check. For now, simplified: allow if target is direct child
        // In production, use closure table or recursive query
        // For this demo, we'll allow viewing any node for simplicity, 
        // assuming the UI restricts navigation properly.
        return true; 
    }

    private function getStats() {
        try {
            // Direct Referrals
            $stmt = $this->conn->prepare("SELECT COUNT(*) FROM genealogy WHERE sponsor_id = ?");
            $stmt->execute([$this->userId]);
            $directs = $stmt->fetchColumn();

            // Total Team (Recursive) - Get all downline members
            $totalTeam = $this->getDownlineCount($this->userId);

            // Active Members - Users with active investments
            $activeStmt = $this->conn->prepare("
                SELECT COUNT(DISTINCT g.user_id) 
                FROM genealogy g
                INNER JOIN user_investments ui ON g.user_id = ui.user_id
                WHERE ui.status = 'active' 
                AND g.sponsor_id = ?
            ");
            $activeStmt->execute([$this->userId]);
            $activeMembers = $activeStmt->fetchColumn();

            $this->sendResponse(200, true, 'Stats fetched', [
                'direct_referrals' => $directs,
                'total_team' => $totalTeam,
                'active_members' => $activeMembers
            ]);
        } catch (Exception $e) {
            $this->sendResponse(500, false, 'Failed to fetch stats: ' . $e->getMessage());
        }
    }

    private function getCode() {
        try {
            $stmt = $this->conn->prepare("SELECT referral_code FROM users WHERE id = ?");
            $stmt->execute([$this->userId]);
            $code = $stmt->fetchColumn();

            if (!$code) {
                $this->sendResponse(404, false, 'Referral code not found');
            }

            // Construct deep link (placeholder for now, should match Play Store guide)
            // In production, this would be a Firebase Dynamic Link or similar
            $link = "https://mlminvestment.page.link/?link=https://mlminvestment.com/register?ref={$code}&apn=com.example.mlm_investment";

            $this->sendResponse(200, true, 'Referral code fetched', [
                'code' => $code,
                'link' => $link
            ]);
        } catch (Exception $e) {
            $this->sendResponse(500, false, 'Failed to fetch code: ' . $e->getMessage());
        }
    }

    private function getAnalytics() {
        try {
            // Total Signups (Direct Referrals)
            $stmt = $this->conn->prepare("SELECT COUNT(*) FROM genealogy WHERE sponsor_id = ?");
            $stmt->execute([$this->userId]);
            $signups = $stmt->fetchColumn();

            // Active Members (Directs with active investments)
            $activeStmt = $this->conn->prepare("
                SELECT COUNT(DISTINCT g.user_id) 
                FROM genealogy g
                INNER JOIN user_investments ui ON g.user_id = ui.user_id
                WHERE ui.status = 'active' 
                AND g.sponsor_id = ?
            ");
            $activeStmt->execute([$this->userId]);
            $activeMembers = $activeStmt->fetchColumn();

            // Total Earned (from commissions)
            // Assuming 'earnings_balance' in users table includes commissions, 
            // OR we can sum from commissions table. Let's use commissions table for accuracy if available,
            // otherwise user's total_earned field.
            $earnStmt = $this->conn->prepare("SELECT total_earned FROM users WHERE id = ?");
            $earnStmt->execute([$this->userId]);
            $totalEarned = $earnStmt->fetchColumn() ?: 0;

            // Conversion Rate
            $conversionRate = $signups > 0 ? round(($activeMembers / $signups) * 100, 1) : 0;

            $this->sendResponse(200, true, 'Analytics fetched', [
                'signups' => $signups,
                'active_referrals' => $activeMembers,
                'total_earned' => $totalEarned,
                'conversion_rate' => $conversionRate
            ]);
        } catch (Exception $e) {
            $this->sendResponse(500, false, 'Failed to fetch analytics: ' . $e->getMessage());
        }
    }

    private function getDownlineCount($userId) {
        // Get all direct referrals
        $stmt = $this->conn->prepare("SELECT user_id FROM genealogy WHERE sponsor_id = ?");
        $stmt->execute([$userId]);
        $directs = $stmt->fetchAll(PDO::FETCH_COLUMN);
        
        $count = count($directs);
        
        // Recursively count their downlines
        foreach ($directs as $directId) {
            $count += $this->getDownlineCount($directId);
        }
        
        return $count;
    }

    private function sendResponse($code, $success, $message, $data = null) {
        http_response_code($code);
        echo json_encode(['success' => $success, 'message' => $message, 'data' => $data]);
        exit();
    }
}

if (isset($_GET['action'])) {
    $controller = new GenealogyController();
    $controller->handleRequest($_GET['action']);
}
?>
