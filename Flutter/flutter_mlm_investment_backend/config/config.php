<?php
// Database Configuration
define('DB_HOST', '127.0.0.1');
define('DB_PORT', '3306');
define('DB_NAME', 'flutter_mlm_investment');
define('DB_USER', 'root');
define('DB_PASS', 'root');
define('DB_CHARSET', 'utf8mb4');

// API Configuration
define('API_VERSION', 'v1');
define('API_BASE_URL', 'http://localhost/flutter_mlm_investment_backend');

// JWT Configuration
define('JWT_SECRET_KEY', 'your-secret-key-change-this-in-production');
define('JWT_ALGORITHM', 'HS256');
define('JWT_EXPIRY', 86400); // 24 hours in seconds

// OTP Configuration
define('OTP_LENGTH', 6);
define('OTP_EXPIRY', 300); // 5 minutes in seconds
define('OTP_PROVIDER', 'test'); // 'test', 'twilio', 'msg91', etc.

// File Upload Configuration
define('UPLOAD_DIR', __DIR__ . '/../uploads/');
define('MAX_FILE_SIZE', 5242880); // 5MB in bytes
define('ALLOWED_IMAGE_TYPES', ['image/jpeg', 'image/png', 'image/jpg']);

// Wallet Configuration
define('MIN_WITHDRAWAL_AMOUNT', 100);
define('WITHDRAWAL_CHARGE_PERCENTAGE', 2); // 2% charge
define('MAX_DAILY_WITHDRAWAL', 50000);

// Investment Configuration
define('MIN_INVESTMENT_AMOUNT', 1000);
define('MAX_INVESTMENT_AMOUNT', 1000000);

// Pagination
define('DEFAULT_PAGE_SIZE', 20);
define('MAX_PAGE_SIZE', 100);

// Timezone
date_default_timezone_set('Asia/Kolkata');

// Error Reporting (disable in production)
error_reporting(E_ALL);
ini_set('display_errors', 1);

// CORS Headers
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');
header('Content-Type: application/json');

// Handle preflight requests
if (isset($_SERVER['REQUEST_METHOD']) && $_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}
