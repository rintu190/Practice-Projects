<?php
/**
 * Application Configuration
 */

// Database Configuration
define('DB_HOST', '127.0.0.1');
define('DB_USER', 'root');
define('DB_PASS', 'Open@120');
define('DB_NAME', 'saree_haven_db');
define('DB_CHARSET', 'utf8mb4');

// API Configuration
define('APP_URL', 'http://localhost/flutter_saree_haven_backend');
define('API_VERSION', 'v1');

// Error Reporting
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
