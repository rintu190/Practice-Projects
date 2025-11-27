<?php
// Enable full error reporting
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

echo "<h1>Debug Page</h1>";
echo "<p>PHP Version: " . phpversion() . "</p>";

// Check if .env exists
if (file_exists('.env')) {
    echo "<p style='color:green'>✅ .env file found</p>";
} else {
    echo "<p style='color:red'>❌ .env file NOT found</p>";
}

// Try loading configuration
try {
    require_once 'config/Env.php';
    Env::load(__DIR__ . '/.env');
    echo "<p>Environment loaded.</p>";
    
    require_once 'config/Database.php';
    $database = new Database();
    
    $start = microtime(true);
    $db = $database->getConnection();
    $end = microtime(true);
    
    $time = round(($end - $start) * 1000, 2);
    
    echo "<p style='color:green'>✅ Database Connected Successfully! ({$time}ms)</p>";
    
} catch (Exception $e) {
    echo "<p style='color:red'>❌ Error: " . $e->getMessage() . "</p>";
    echo "<pre>" . $e->getTraceAsString() . "</pre>";
}
?>
