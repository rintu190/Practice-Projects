<?php
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../utils/jwt.php';

class PackageController {
    private $db;
    private $conn;
    private $userId;

    public function __construct() {
        $this->db = Database::getInstance();
        $this->conn = $this->db->getConnection();
    }

    public function handleRequest($action) {
        switch ($action) {
            case 'get_packages':
                $this->getPackages();
                break;
            case 'purchase':
                $this->userId = $this->authenticate();
                $this->purchasePackage();
                break;
            case 'get_my_purchases':
                $this->userId = $this->authenticate();
                $this->getMyPurchases();
                break;
            case 'get_invoice':
                $this->userId = $this->authenticate();
                $this->getInvoice();
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

    private function getPackages() {
        try {
            $type = $_GET['type'] ?? 'all';
            
            $sql = "SELECT * FROM packages WHERE is_active = 1";
            if ($type !== 'all') {
                $sql .= " AND type = ?";
            }
            $sql .= " ORDER BY sort_order ASC";
            
            $stmt = $this->conn->prepare($sql);
            if ($type !== 'all') {
                $stmt->execute([$type]);
            } else {
                $stmt->execute();
            }
            
            $packages = $stmt->fetchAll(PDO::FETCH_ASSOC);
            
            // Decode JSON features
            foreach ($packages as &$package) {
                $package['features'] = json_decode($package['features'], true);
                $package['total_with_gst'] = $package['price'] + ($package['price'] * $package['gst_rate'] / 100);
            }
            
            $this->sendResponse(200, true, 'Packages retrieved', $packages);
            
        } catch (Exception $e) {
            $this->sendResponse(500, false, 'Error: ' . $e->getMessage());
        }
    }

    private function purchasePackage() {
        try {
            $data = json_decode(file_get_contents('php://input'), true);
            $packageId = $data['package_id'] ?? null;
            
            if (!$packageId) {
                $this->sendResponse(400, false, 'Package ID required');
            }
            
            $this->conn->beginTransaction();
            
            // Get package details
            $stmt = $this->conn->prepare("SELECT * FROM packages WHERE id = ? AND is_active = 1");
            $stmt->execute([$packageId]);
            $package = $stmt->fetch(PDO::FETCH_ASSOC);
            
            if (!$package) {
                $this->conn->rollBack();
                $this->sendResponse(404, false, 'Package not found');
            }
            
            // Calculate amounts
            $amount = $package['price'];
            $gstAmount = ($amount * $package['gst_rate']) / 100;
            $totalAmount = $amount + $gstAmount;
            
            // Check wallet balance
            $stmt = $this->conn->prepare("SELECT e_wallet_balance FROM wallets WHERE user_id = ?");
            $stmt->execute([$this->userId]);
            $wallet = $stmt->fetch(PDO::FETCH_ASSOC);
            
            if (!$wallet || $wallet['e_wallet_balance'] < $totalAmount) {
                $this->conn->rollBack();
                $this->sendResponse(400, false, 'Insufficient wallet balance');
            }
            
            // Generate invoice number
            $invoiceNumber = 'INV-' . date('Ymd') . '-' . str_pad($this->userId, 4, '0', STR_PAD_LEFT) . '-' . uniqid();
            
            // Calculate expiry date
            $expiresAt = null;
            if ($package['validity_days']) {
                $expiresAt = date('Y-m-d H:i:s', strtotime("+{$package['validity_days']} days"));
            }
            
            // Create purchase record
            $stmt = $this->conn->prepare("
                INSERT INTO package_purchases 
                (user_id, package_id, amount, gst_amount, total_amount, invoice_number, status, expires_at)
                VALUES (?, ?, ?, ?, ?, ?, 'completed', ?)
            ");
            $stmt->execute([
                $this->userId,
                $packageId,
                $amount,
                $gstAmount,
                $totalAmount,
                $invoiceNumber,
                $expiresAt
            ]);
            $purchaseId = $this->conn->lastInsertId();
            
            // Create invoice
            $stmt = $this->conn->prepare("
                INSERT INTO invoices 
                (purchase_id, invoice_number, user_id, subtotal, gst_amount, total_amount)
                VALUES (?, ?, ?, ?, ?, ?)
            ");
            $stmt->execute([
                $purchaseId,
                $invoiceNumber,
                $this->userId,
                $amount,
                $gstAmount,
                $totalAmount
            ]);
            
            // Deduct from wallet
            $stmt = $this->conn->prepare("
                UPDATE wallets 
                SET e_wallet_balance = e_wallet_balance - ?
                WHERE user_id = ?
            ");
            $stmt->execute([$totalAmount, $this->userId]);
            
            // Create transaction record
            $stmt = $this->conn->prepare("
                INSERT INTO transactions 
                (user_id, wallet_type, type, amount, balance_before, balance_after, description, reference_id, reference_type, status)
                SELECT ?, 'e_wallet', 'debit', ?, e_wallet_balance + ?, e_wallet_balance, ?, ?, 'package_purchase', 'completed'
                FROM wallets WHERE user_id = ?
            ");
            $stmt->execute([
                $this->userId,
                $totalAmount,
                $totalAmount,
                "Package Purchase: {$package['name']}",
                $purchaseId,
                $this->userId
            ]);
            
            // Auto-assign to genealogy if joining package
            if ($package['type'] === 'joining') {
                $this->autoAssignToGenealogy($this->userId);
            }
            
            $this->conn->commit();
            
            $this->sendResponse(200, true, 'Package purchased successfully', [
                'purchase_id' => $purchaseId,
                'invoice_number' => $invoiceNumber,
                'total_amount' => $totalAmount
            ]);
            
        } catch (Exception $e) {
            if ($this->conn->inTransaction()) {
                $this->conn->rollBack();
            }
            $this->sendResponse(500, false, 'Purchase failed: ' . $e->getMessage());
        }
    }

    private function autoAssignToGenealogy($userId) {
        // Check if user already in genealogy
        $stmt = $this->conn->prepare("SELECT id FROM genealogy WHERE user_id = ?");
        $stmt->execute([$userId]);
        if ($stmt->fetch()) {
            return; // Already assigned
        }
        
        // Get sponsor
        $stmt = $this->conn->prepare("SELECT referred_by FROM users WHERE id = ?");
        $stmt->execute([$userId]);
        $user = $stmt->fetch(PDO::FETCH_ASSOC);
        $sponsorId = $user['referred_by'];
        
        if (!$sponsorId) {
            // Root user - no parent
            $stmt = $this->conn->prepare("
                INSERT INTO genealogy (user_id, sponsor_id, parent_id, position, level, path)
                VALUES (?, NULL, NULL, NULL, 1, ?)
            ");
            $stmt->execute([$userId, $userId]);
            return;
        }
        
        // Find best placement position (balanced binary)
        $parentId = $this->findBestPlacement($sponsorId);
        
        // Determine position (left or right)
        $stmt = $this->conn->prepare("
            SELECT position FROM genealogy 
            WHERE parent_id = ? 
            ORDER BY position
        ");
        $stmt->execute([$parentId]);
        $existingPositions = $stmt->fetchAll(PDO::FETCH_COLUMN);
        
        $position = 'left';
        if (in_array('left', $existingPositions)) {
            $position = 'right';
        }
        
        // Get parent level and path
        $stmt = $this->conn->prepare("SELECT level, path FROM genealogy WHERE user_id = ?");
        $stmt->execute([$parentId]);
        $parent = $stmt->fetch(PDO::FETCH_ASSOC);
        
        $level = $parent['level'] + 1;
        $path = $parent['path'] . ',' . $userId;
        
        // Insert into genealogy
        $stmt = $this->conn->prepare("
            INSERT INTO genealogy (user_id, sponsor_id, parent_id, position, level, path)
            VALUES (?, ?, ?, ?, ?, ?)
        ");
        $stmt->execute([$userId, $sponsorId, $parentId, $position, $level, $path]);
    }

    private function findBestPlacement($sponsorId) {
        // Simple balanced placement: find first available spot under sponsor
        // BFS approach to find leftmost available position
        
        $queue = [$sponsorId];
        
        while (!empty($queue)) {
            $currentId = array_shift($queue);
            
            // Check how many children this node has
            $stmt = $this->conn->prepare("
                SELECT COUNT(*) as child_count 
                FROM genealogy 
                WHERE parent_id = ?
            ");
            $stmt->execute([$currentId]);
            $result = $stmt->fetch(PDO::FETCH_ASSOC);
            
            if ($result['child_count'] < 2) {
                // This node has space
                return $currentId;
            }
            
            // Add children to queue
            $stmt = $this->conn->prepare("
                SELECT user_id FROM genealogy 
                WHERE parent_id = ? 
                ORDER BY position
            ");
            $stmt->execute([$currentId]);
            $children = $stmt->fetchAll(PDO::FETCH_COLUMN);
            $queue = array_merge($queue, $children);
        }
        
        return $sponsorId; // Fallback
    }

    private function getMyPurchases() {
        try {
            $stmt = $this->conn->prepare("
                SELECT 
                    pp.*,
                    p.name as package_name,
                    p.type as package_type
                FROM package_purchases pp
                JOIN packages p ON pp.package_id = p.id
                WHERE pp.user_id = ?
                ORDER BY pp.purchased_at DESC
            ");
            $stmt->execute([$this->userId]);
            $purchases = $stmt->fetchAll(PDO::FETCH_ASSOC);
            
            $this->sendResponse(200, true, 'Purchases retrieved', $purchases);
            
        } catch (Exception $e) {
            $this->sendResponse(500, false, 'Error: ' . $e->getMessage());
        }
    }

    private function getInvoice() {
        try {
            $invoiceNumber = $_GET['invoice_number'] ?? null;
            
            if (!$invoiceNumber) {
                $this->sendResponse(400, false, 'Invoice number required');
            }
            
            $stmt = $this->conn->prepare("
                SELECT 
                    i.*,
                    pp.package_id,
                    p.name as package_name,
                    p.description as package_description,
                    u.phone,
                    up.full_name
                FROM invoices i
                JOIN package_purchases pp ON i.purchase_id = pp.id
                JOIN packages p ON pp.package_id = p.id
                JOIN users u ON i.user_id = u.id
                LEFT JOIN user_profiles up ON u.id = up.user_id
                WHERE i.invoice_number = ? AND i.user_id = ?
            ");
            $stmt->execute([$invoiceNumber, $this->userId]);
            $invoice = $stmt->fetch(PDO::FETCH_ASSOC);
            
            if (!$invoice) {
                $this->sendResponse(404, false, 'Invoice not found');
            }
            
            $this->sendResponse(200, true, 'Invoice retrieved', $invoice);
            
        } catch (Exception $e) {
            $this->sendResponse(500, false, 'Error: ' . $e->getMessage());
        }
    }

    private function sendResponse($code, $success, $message, $data = null) {
        http_response_code($code);
        echo json_encode([
            'success' => $success,
            'message' => $message,
            'data' => $data
        ]);
        exit;
    }
}

if (isset($_GET['action'])) {
    $controller = new PackageController();
    $controller->handleRequest($_GET['action']);
}
