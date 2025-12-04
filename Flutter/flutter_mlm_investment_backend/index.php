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
            
        // Auth routes
        case 'send_otp':
        case 'verify_otp':
        case 'login_password':
        case 'register':
        case 'login':
        case 'logout':
            require_once __DIR__ . '/routes/auth.php';
            break;
            
        // Dashboard routes
        case 'get_data':
            require_once __DIR__ . '/routes/dashboard.php';
            break;
            
        // Wallet routes
        case 'get_balance':
        case 'get_transactions':
        case 'add_funds':
        case 'withdraw':
        case 'withdraw_earnings':
            require_once __DIR__ . '/routes/wallet.php';
            break;
            
        // Investment routes
        case 'get_portfolio':
        case 'get_products':
        case 'invest':
        case 'get_my_investments':
            require_once __DIR__ . '/routes/investment.php';
            break;
            
        // Commission routes
        case 'get_commission_rules':
        case 'update_commission_rule':
        case 'get_commission_history':
        case 'calculate_commissions':
        case 'get_commissions':
        case 'get_summary':
            require_once __DIR__ . '/routes/commission.php';
            break;
            
        // Package routes
        case 'get_packages':
        case 'purchase':
        case 'get_my_purchases':
        case 'get_invoice':
            require_once __DIR__ . '/routes/package.php';
            break;
            
        // Genealogy routes
        case 'get_tree':
        case 'get_stats':
        case 'get_referrals':
        case 'get_referral_link':
        case 'get_code':
        case 'get_analytics':
            require_once __DIR__ . '/routes/genealogy.php';
            break;
            
        // User routes
        case 'get_profile':
        case 'update_profile':
            require_once __DIR__ . '/routes/users.php';
            break;
            
        // KYC routes
        case 'upload':
        case 'get_status':
        case 'update':
            require_once __DIR__ . '/routes/kyc.php';
            break;
            
        // Bank routes
        case 'add':
        case 'get':
        case 'update_bank':
            require_once __DIR__ . '/routes/bank.php';
            break;
            
        // Earnings routes
        case 'get_breakdown':
        case 'get_history':
            require_once __DIR__ . '/routes/earnings.php';
            break;
            
        // Support routes
        case 'create_ticket':
        case 'get_tickets':
        case 'send_message':
        case 'get_ticket_details':
            require_once __DIR__ . '/routes/support.php';
            break;
            
        // Admin routes
        case 'get_users':
        case 'get_user_details':
        case 'update_user_status':
        case 'get_pending_approvals':
        case 'approve_deposit':
        case 'reject_deposit':
        case 'approve_withdrawal':
        case 'reject_withdrawal':
        case 'get_all_investments':
        case 'get_all_tickets':
        case 'reply_ticket':
        case 'close_ticket':
            require_once __DIR__ . '/routes/admin.php';
            break;
            
        // Team routes
        case 'get_directs':
            require_once __DIR__ . '/routes/team.php';
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
