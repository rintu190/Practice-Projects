<?php
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../utils/commission_calculator.php';

$action = $_GET['action'] ?? '';
$method = $_SERVER['REQUEST_METHOD'];
$userId = $_GET['user_id'] ?? null; // For history

// Simple auth check (in real app, use middleware)
// For now, we assume the main index.php or middleware handles auth/session if needed
// But since we are just adding routes, we'll do basic checks here

switch ($action) {
    case 'get_commission_rules':
        if ($method === 'GET') {
            getCommissionRules();
        }
        break;
        
    case 'update_commission_rule':
        if ($method === 'POST') {
            updateCommissionRule();
        }
        break;
        
    case 'get_commission_history':
        if ($method === 'GET') {
            getCommissionHistory($userId);
        }
        break;
        
    case 'calculate_commissions':
        if ($method === 'POST') {
            triggerCommissionCalculation();
        }
        break;
        
    default:
        echo json_encode(['success' => false, 'message' => 'Invalid commission action']);
        break;
}

function getCommissionRules() {
    try {
        $db = Database::getInstance()->getConnection();
        $stmt = $db->query("SELECT * FROM commission_rules ORDER BY type, level");
        $rules = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        echo json_encode(['success' => true, 'data' => $rules]);
    } catch (Exception $e) {
        echo json_encode(['success' => false, 'message' => $e->getMessage()]);
    }
}

function updateCommissionRule() {
    $data = json_decode(file_get_contents('php://input'), true);
    
    error_log("Update Commission Rule Request: " . print_r($data, true));

    if (!isset($data['id']) || !isset($data['percentage'])) {
        error_log("Missing fields: id or percentage");
        echo json_encode(['success' => false, 'message' => 'Missing required fields']);
        return;
    }
    
    try {
        $db = Database::getInstance()->getConnection();
        $stmt = $db->prepare("UPDATE commission_rules SET percentage = ?, fixed_amount = ?, is_active = ? WHERE id = ?");
        $stmt->execute([
            $data['percentage'],
            $data['fixed_amount'] ?? 0,
            isset($data['is_active']) ? $data['is_active'] : 1,
            $data['id']
        ]);
        
        echo json_encode(['success' => true, 'message' => 'Rule updated successfully']);
    } catch (Exception $e) {
        echo json_encode(['success' => false, 'message' => $e->getMessage()]);
    }
}

function getCommissionHistory($userId) {
    if (!$userId) {
        echo json_encode(['success' => false, 'message' => 'User ID required']);
        return;
    }
    
    try {
        $db = Database::getInstance()->getConnection();
        $stmt = $db->prepare("
            SELECT c.*, u.phone as source_user_phone 
            FROM commissions c 
            LEFT JOIN users u ON c.source_user_id = u.id 
            WHERE c.user_id = ? 
            ORDER BY c.created_at DESC
        ");
        $stmt->execute([$userId]);
        $history = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        echo json_encode(['success' => true, 'data' => $history]);
    } catch (Exception $e) {
        echo json_encode(['success' => false, 'message' => $e->getMessage()]);
    }
}

function triggerCommissionCalculation() {
    $data = json_decode(file_get_contents('php://input'), true);
    $userId = $data['user_id'] ?? null;
    $amount = $data['amount'] ?? 0;
    $investmentId = $data['investment_id'] ?? null;
    
    if (!$userId || !$amount) {
        echo json_encode(['success' => false, 'message' => 'User ID and Amount required']);
        return;
    }
    
    try {
        $calculator = new CommissionCalculator();
        $calculator->distributeCommissions($userId, $amount, $investmentId);
        
        echo json_encode(['success' => true, 'message' => 'Commissions calculated and distributed successfully']);
    } catch (Exception $e) {
        echo json_encode(['success' => false, 'message' => 'Error: ' . $e->getMessage()]);
    }
}
