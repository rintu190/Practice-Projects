<?php

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Content-Type: application/json; charset=UTF-8");

// Handle PHP built-in server
if (php_sapi_name() == 'cli-server') {
    $url = parse_url($_SERVER['REQUEST_URI']);
    $file = __DIR__ . $url['path'];
    if (is_file($file)) {
        return false;
    }
}

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Load environment variables
require_once __DIR__ . '/config/Env.php';
Env::load(__DIR__ . '/.env');

// Load vendor autoload for JWT
require_once __DIR__ . '/vendor/autoload.php';

// Load helpers
require_once __DIR__ . '/helpers.php';

// Load middleware
require_once __DIR__ . '/middleware/AuthMiddleware.php';

// Get request method and URI
$method = $_SERVER['REQUEST_METHOD'];
$uri = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
$uri = str_replace('/index.php', '', $uri);

// Remove base path if running from subdirectory
$basePath = '/api';
if (strpos($uri, $basePath) === 0) {
    $uri = substr($uri, strlen($basePath));
}

error_log("DEBUG: Request URI: " . $_SERVER['REQUEST_URI']);
error_log("DEBUG: Parsed URI: " . $uri);
error_log("DEBUG: Method: " . $method);

// Route handling
try {
    // Health check
    if ($uri === '/health') {
        echo json_encode(['status' => 'ok', 'message' => 'Server is running']);
        exit();
    }

    // Auth routes
    if (strpos($uri, '/auth') === 0) {
        require_once __DIR__ . '/routes/auth.php';
        $path = substr($uri, 5); // Remove '/auth'
        handleAuthRoutes($method, $path);
        exit();
    }

    // Restaurant routes
    if (strpos($uri, '/restaurants') === 0) {
        require_once __DIR__ . '/routes/restaurants.php';
        $path = substr($uri, 12); // Remove '/restaurants'
        handleRestaurantRoutes($method, $path);
        exit();
    }

    // Address routes
    if (strpos($uri, '/addresses') === 0) {
        require_once __DIR__ . '/routes/addresses.php';
        $path = substr($uri, 10); // Remove '/addresses'
        handleAddressRoutes($method, $path);
        exit();
    }

    // Payment Methods routes
    // Payment Methods routes
    if (strpos($uri, '/payment-methods') === 0) {
        require_once __DIR__ . '/routes/payment_methods.php';
        $path = substr($uri, 16); // Remove '/payment-methods'
        handlePaymentMethodRoutes($method, $path);
        exit();
    }

    // Users routes
    error_log("DEBUG: Checking users route. URI: $uri, strpos result: " . strpos($uri, '/users'));
    if (strpos($uri, '/users') === 0) {
        error_log("DEBUG: Matched users route!");
        require_once __DIR__ . '/routes/users.php';
        $path = substr($uri, 6); // Remove '/users'
        error_log("DEBUG: Users path: $path");
        handleUserRoutes($method, $path);
        exit();
    }

// Order routes
    if (strpos($uri, '/orders') === 0) {
        require_once __DIR__ . '/routes/orders.php';
        $path = substr($uri, 7); // Remove '/orders'
        handleOrderRoutes($method, $path);
        exit();
    }

    // Commissions routes
    if (strpos($uri, '/commissions') === 0) {
        require_once __DIR__ . '/routes/commissions.php';
        $path = substr($uri, 12); // Remove '/commissions'
        handleCommissionRoutes($method, $path);
        exit();
    }

    // Menu items routes
    if (strpos($uri, '/menu-items') === 0) {
        require_once __DIR__ . '/routes/menu_items.php';
        $path = substr($uri, 11); // Remove '/menu-items'
        handleMenuItemRoutes($method, $path);
        exit();
    }

    // Upload routes
    if (strpos($uri, '/upload') === 0) {
        require_once __DIR__ . '/routes/upload.php';
        $path = substr($uri, 7); // Remove '/upload'
        handleUploadRoutes($method);
        exit();
    }

    // Route not found
    http_response_code(404);
    echo json_encode(['error' => 'Route not found']);

} catch (Exception $e) {
    error_log($e->getMessage());
    http_response_code(500);
    echo json_encode(['error' => 'Something went wrong!']);
}
