<?php
require_once __DIR__ . '/config/config.php';
require_once __DIR__ . '/config/database.php';

// Enable CORS
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

$method = $_SERVER['REQUEST_METHOD'];

// Route handler
if (isset($_GET['action'])) {
    $action = $_GET['action'];
    
    switch ($action) {
        case 'test':
            testConnection();
            break;
            
        // Auth routes
        case 'register':
        case 'login':
        case 'social_login':
        case 'verify_otp':
            require_once __DIR__ . '/routes/auth.php';
            break;

        // User Profile routes (Freelancer, Employer, Job Seeker)
        case 'get_profile':
        case 'update_profile':
        case 'upload_portfolio': // Freelancer
        case 'update_company_profile': // Employer
            require_once __DIR__ . '/routes/users.php';
            break;

        // Job/Project routes
        case 'post_job':
        case 'post_project':
        case 'get_jobs':
        case 'get_projects':
        case 'get_job_details':
        case 'get_project_details':
        case 'save_job':
            require_once __DIR__ . '/routes/jobs_projects.php';
            break;

        // Proposal/Application routes
        case 'apply_job':
        case 'submit_proposal':
        case 'get_proposals':
        case 'shortlist_proposal':
            require_once __DIR__ . '/routes/applications.php';
            break;

        // Chat routes
        case 'send_message':
        case 'get_messages':
        case 'get_conversations':
            require_once __DIR__ . '/routes/chat.php';
            break;

        // Wallet/Payment routes
        case 'get_wallet_balance':
        case 'add_funds':
        case 'withdraw':
        case 'get_transactions':
            require_once __DIR__ . '/routes/wallet.php';
            break;

        // Admin routes
        case 'admin_get_stats':
        case 'admin_manage_users':
        case 'admin_approve_kyc':
            require_once __DIR__ . '/routes/admin.php';
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
            'service' => 'Freelance Job Portal Backend'
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
