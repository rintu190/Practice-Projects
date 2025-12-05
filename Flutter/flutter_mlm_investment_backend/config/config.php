<?php
/**
 * Application Configuration
 * Loads configuration from environment variables
 */

// Load environment variables
require_once __DIR__ . '/env_loader.php';
EnvLoader::load();

// Helper function to get env variables
function env($key, $default = null) {
    return EnvLoader::get($key, $default);
}

// Application Configuration
define('APP_ENV', env('APP_ENV', 'local'));
define('APP_DEBUG', env('APP_DEBUG', true));
define('APP_URL', env('APP_URL', 'http://localhost/flutter_mlm_investment_backend'));

// Database Configuration
define('DB_HOST', env('DB_HOST', '127.0.0.1'));
define('DB_PORT', env('DB_PORT', '3306'));
define('DB_NAME', env('DB_NAME', 'flutter_mlm_investment'));
define('DB_USER', env('DB_USER', 'root'));
define('DB_PASS', env('DB_PASS', 'root'));
define('DB_CHARSET', env('DB_CHARSET', 'utf8mb4'));

// API Configuration
define('API_VERSION', 'v1');
define('API_BASE_URL', env('APP_URL'));

// JWT Configuration
define('JWT_SECRET_KEY', env('JWT_SECRET_KEY', 'your-secret-key-change-this-in-production'));
define('JWT_ALGORITHM', env('JWT_ALGORITHM', 'HS256'));
define('JWT_EXPIRY', (int)env('JWT_EXPIRY', 86400)); // 24 hours in seconds

// OTP Configuration
define('OTP_LENGTH', (int)env('OTP_LENGTH', 6));
define('OTP_EXPIRY', (int)env('OTP_EXPIRY', 300)); // 5 minutes in seconds
define('OTP_PROVIDER', env('OTP_PROVIDER', 'test')); // 'test', 'twilio', 'msg91', '2factor'

// SMS Provider Configuration - Twilio
define('TWILIO_ACCOUNT_SID', env('TWILIO_ACCOUNT_SID', ''));
define('TWILIO_AUTH_TOKEN', env('TWILIO_AUTH_TOKEN', ''));
define('TWILIO_PHONE_NUMBER', env('TWILIO_PHONE_NUMBER', ''));

// SMS Provider Configuration - MSG91
define('MSG91_AUTH_KEY', env('MSG91_AUTH_KEY', ''));
define('MSG91_SENDER_ID', env('MSG91_SENDER_ID', ''));
define('MSG91_TEMPLATE_ID', env('MSG91_TEMPLATE_ID', ''));
define('MSG91_ROUTE', env('MSG91_ROUTE', '4'));

// SMS Provider Configuration - 2Factor
define('TWOFACTOR_API_KEY', env('TWOFACTOR_API_KEY', ''));

// File Upload Configuration
define('UPLOAD_DIR', __DIR__ . '/../' . env('UPLOAD_DIR', 'uploads/'));
define('MAX_FILE_SIZE', (int)env('MAX_FILE_SIZE', 5242880)); // 5MB in bytes
define('ALLOWED_IMAGE_TYPES', ['image/jpeg', 'image/png', 'image/jpg']);

// Wallet Configuration
define('MIN_WITHDRAWAL_AMOUNT', (int)env('MIN_WITHDRAWAL_AMOUNT', 100));
define('WITHDRAWAL_CHARGE_PERCENTAGE', (int)env('WITHDRAWAL_CHARGE_PERCENTAGE', 2)); // 2% charge
define('MAX_DAILY_WITHDRAWAL', (int)env('MAX_DAILY_WITHDRAWAL', 50000));

// Investment Configuration
define('MIN_INVESTMENT_AMOUNT', (int)env('MIN_INVESTMENT_AMOUNT', 1000));
define('MAX_INVESTMENT_AMOUNT', (int)env('MAX_INVESTMENT_AMOUNT', 1000000));

// Pagination
define('DEFAULT_PAGE_SIZE', (int)env('DEFAULT_PAGE_SIZE', 20));
define('MAX_PAGE_SIZE', (int)env('MAX_PAGE_SIZE', 100));

// Timezone
date_default_timezone_set(env('TIMEZONE', 'Asia/Kolkata'));

// Error Reporting (based on environment)
if (APP_ENV === 'production') {
    error_reporting(0);
    ini_set('display_errors', 0);
    ini_set('log_errors', 1);
    ini_set('error_log', __DIR__ . '/../logs/php_errors.log');
} else {
    error_reporting(E_ALL);
    ini_set('display_errors', 1);
}

// CORS Headers
$allowedOrigins = env('CORS_ALLOWED_ORIGINS', '*');
header('Access-Control-Allow-Origin: ' . $allowedOrigins);
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');
header('Content-Type: application/json');

// Handle preflight requests
if (isset($_SERVER['REQUEST_METHOD']) && $_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}
