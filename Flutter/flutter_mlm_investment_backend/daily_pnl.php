<?php
// daily_pnl.php
// Handles admin upload of daily P&L data and user retrieval.

require_once __DIR__ . '/config/database.php';
require_once __DIR__ . '/utils/jwt.php';

class DailyPnlController {
    private $db;
    private $conn;
    private $userId;
    private $isAdmin = false;

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
                // Determine admin status
                $stmt = $this->conn->prepare('SELECT is_admin FROM users WHERE id = ?');
                $stmt->execute([$this->userId]);
                $row = $stmt->fetch(PDO::FETCH_ASSOC);
                $this->isAdmin = $row && $row['is_admin'];
                return;
            }
        }
        $this->sendResponse(401, false, 'Unauthorized');
    }

    // Admin uploads a CSV file with daily P&L rows.
    public function uploadDailyPnl() {
        if (!$this->isAdmin) {
            $this->sendResponse(403, false, 'Admin privileges required');
        }
        if (!isset($_FILES['file'])) {
            $this->sendResponse(400, false, 'No file uploaded');
        }
        $file = $_FILES['file']['tmp_name'];
        $handle = fopen($file, 'r');
        if (!$handle) {
            $this->sendResponse(500, false, 'Unable to read uploaded file');
        }
        $header = fgetcsv($handle);
        $required = ['investment_id','user_id','product_id','pnl_date','profit_amount','loss_amount','net_pnl','investment_value_before','investment_value_after'];
        foreach ($required as $col) {
            if (!in_array($col, $header)) {
                $this->sendResponse(400, false, "Missing required column: $col");
            }
        }
        
        try {
            $this->conn->beginTransaction();
            
            $insertStmt = $this->conn->prepare('INSERT INTO daily_pnl (investment_id, user_id, product_id, pnl_date, profit_amount, loss_amount, net_pnl, investment_value_before, investment_value_after, notes) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)');
            $rowCount = 0;
            $affectedInvestments = [];
            
            while (($row = fgetcsv($handle)) !== false) {
                $data = array_combine($header, $row);
                // Basic validation
                if (empty($data['investment_id']) || empty($data['user_id']) || empty($data['product_id']) || empty($data['pnl_date'])) {
                    continue; // skip invalid rows
                }
                $insertStmt->execute([
                    $data['investment_id'],
                    $data['user_id'],
                    $data['product_id'],
                    $data['pnl_date'],
                    $data['profit_amount'] ?? 0,
                    $data['loss_amount'] ?? 0,
                    $data['net_pnl'] ?? 0,
                    $data['investment_value_before'] ?? 0,
                    $data['investment_value_after'] ?? 0,
                    $data['notes'] ?? null,
                ]);
                $rowCount++;
                $affectedInvestments[$data['investment_id']] = true;
            }
            fclose($handle);
            
            // Update total_profit_earned for affected investments
            foreach (array_keys($affectedInvestments) as $investmentId) {
                $updateStmt = $this->conn->prepare("
                    UPDATE user_investments ui
                    SET total_profit_earned = (
                        SELECT COALESCE(SUM(net_pnl), 0) 
                        FROM daily_pnl 
                        WHERE investment_id = ?
                    ) + (
                        SELECT COALESCE(SUM(amount), 0) 
                        FROM investment_profits 
                        WHERE investment_id = ?
                    ),
                    last_profit_date = GREATEST(
                        COALESCE((SELECT MAX(pnl_date) FROM daily_pnl WHERE investment_id = ?), '1000-01-01'),
                        COALESCE((SELECT MAX(profit_date) FROM investment_profits WHERE investment_id = ?), '1000-01-01')
                    )
                    WHERE id = ?
                ");
                $updateStmt->execute([$investmentId, $investmentId, $investmentId, $investmentId, $investmentId]);
            }
            
            $this->conn->commit();
            $this->sendResponse(200, true, "Uploaded $rowCount rows successfully and updated " . count($affectedInvestments) . " investments");
            
        } catch (Exception $e) {
            $this->conn->rollBack();
            $this->sendResponse(500, false, 'Upload failed: ' . $e->getMessage());
        }
    }

    // Users fetch their own daily P&L, optional filter by date range.
    public function getDailyPnl() {
        $userId = $this->userId;
        
        // Base query combining manual P&L and automated investment profits
        $sql = "
            SELECT 
                id, 
                investment_id, 
                user_id, 
                product_id, 
                pnl_date, 
                profit_amount, 
                loss_amount, 
                net_pnl, 
                investment_value_before,
                investment_value_after,
                notes 
            FROM daily_pnl 
            WHERE user_id = ?
            
            UNION ALL
            
            SELECT 
                ip.id, 
                ip.investment_id, 
                ip.user_id, 
                ui.product_id, 
                ip.profit_date as pnl_date, 
                ip.amount as profit_amount, 
                0 as loss_amount, 
                ip.amount as net_pnl, 
                0 as investment_value_before,
                0 as investment_value_after,
                'Automated ROI' as notes 
            FROM investment_profits ip
            JOIN user_investments ui ON ip.investment_id = ui.id
            WHERE ip.user_id = ?
        ";
        
        $params = [$userId, $userId];
        
        // Note: Date filtering would need to be applied to the result or wrapped in a subquery/CTE
        // For simplicity and performance with UNION, let's wrap it
        $wrappedSql = "SELECT * FROM ($sql) AS combined_pnl WHERE 1=1";
        
        if (isset($_GET['start_date'])) {
            $wrappedSql .= ' AND pnl_date >= ?';
            $params[] = $_GET['start_date'];
        }
        if (isset($_GET['end_date'])) {
            $wrappedSql .= ' AND pnl_date <= ?';
            $params[] = $_GET['end_date'];
        }
        
        $wrappedSql .= ' ORDER BY pnl_date DESC';
        
        try {
            $stmt = $this->conn->prepare($wrappedSql);
            $stmt->execute($params);
            $records = $stmt->fetchAll(PDO::FETCH_ASSOC);
            $this->sendResponse(200, true, 'Daily P&L fetched', $records);
        } catch (Exception $e) {
            $this->sendResponse(500, false, 'Failed to fetch P&L: ' . $e->getMessage());
        }
    }

    private function sendResponse($code, $success, $message, $data = null) {
        http_response_code($code);
        echo json_encode(['success' => $success, 'message' => $message, 'data' => $data]);
        exit();
    }
}
?>
