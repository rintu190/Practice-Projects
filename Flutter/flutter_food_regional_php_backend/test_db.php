<?php

error_reporting(E_ALL);
ini_set('display_errors', 1);

// Load environment variables
require_once __DIR__ . '/config/Env.php';
Env::load(__DIR__ . '/.env');

// Test database connection
require_once __DIR__ . '/config/Database.php';

try {
    $database = new Database();
    $db = $database->getConnection();
    echo "Database connection successful!\n";
    echo "Database: " . ($_ENV['DB_NAME'] ?? 'unknown') . "\n";
    echo "Host: " . ($_ENV['DB_HOST'] ?? 'unknown') . "\n";
} catch (Exception $e) {
    echo "Database connection failed: " . $e->getMessage() . "\n";
}
