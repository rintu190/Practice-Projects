<?php
require_once __DIR__ . '/config/config.php';
require_once __DIR__ . '/config/database.php';

// Get request method
$method = $_SERVER['REQUEST_METHOD'];

// Route handler
if (isset($_GET['action'])) {
    $action = $_GET['action'];
    
    switch ($action) {
        case 'test':
            testConnection();
            break;
        case 'send_otp':
        case 'verify_otp':
        case 'register':
            require_once __DIR__ . '/routes/auth.php';
            break;
        case 'get_data':
            require_once __DIR__ . '/routes/dashboard.php';
            break;
        case 'get_balance':
        case 'get_transactions':
            require_once __DIR__ . '/routes/wallet.php';
            break;
        case 'get_portfolio':
            require_once __DIR__ . '/routes/investment.php';
            break;
        case 'get_commission_rules':
        case 'update_commission_rule':
        case 'get_commission_history':
        case 'calculate_commissions':
            require_once __DIR__ . '/routes/commission.php';
            break;
        case 'get_packages':
        case 'purchase':
        case 'get_my_purchases':
        case 'get_invoice':
            require_once __DIR__ . '/routes/package.php';
            break;
        default:
            sendResponse(404, false, 'Invalid action');
    }
} else {
    sendResponse(400, false, 'Action parameter required');
}

function testConnection() {
    try {
        $db = Database::getInstance();
        $conn = $db->getConnection();
        
        sendResponse(200, true, 'Database connection successful', [
            'server_time' => date('Y-m-d H:i:s'),
            'php_version' => phpversion(),
            'database' => 'Connected'
        ]);
    } catch (Exception $e) {
        sendResponse(500, false, 'Database connection failed: ' . $e->getMessage());
    }
}

function sendResponse($code, $success, $message, $data = null) {
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
