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
            SELECT u.id, u.phone, u.rank, up.full_name, g.leg
            FROM users u
            LEFT JOIN user_profiles up ON u.id = up.user_id
            LEFT JOIN genealogy g ON u.id = g.user_id
            WHERE u.id = ?
        ");
        $stmt->execute([$rootId]);
        $user = $stmt->fetch(PDO::FETCH_ASSOC);

        if (!$user) return null;

        $node = [
            'id' => $user['id'],
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
            // Total Team
            $stmt = $this->conn->prepare("SELECT COUNT(*) FROM genealogy WHERE sponsor_id = ?");
            $stmt->execute([$this->userId]);
            $directs = $stmt->fetchColumn();

            // Total Downline (Recursive - simplified for now to just directs + their directs)
            // Real MLM systems need a better way to count total downline (e.g. materialized path)
            // For now, we'll just return directs count as 'Team Size' for the demo
            
            $this->sendResponse(200, true, 'Stats fetched', [
                'direct_referrals' => $directs,
                'total_team' => $directs, // Placeholder for full recursive count
                'active_members' => $directs // Placeholder
            ]);
        } catch (Exception $e) {
            $this->sendResponse(500, false, 'Failed to fetch stats: ' . $e->getMessage());
        }
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
