<?php
$_ENV['DB_HOST'] = '127.0.0.1';
$_ENV['DB_USER'] = 'root';
$_ENV['DB_PASSWORD'] = 'root';
$_ENV['DB_NAME'] = 'flutter_food_regional';
require_once __DIR__ . '/config/Database.php';

try {
    $database = new Database();
    $db = $database->getConnection();
    
    echo "Checking for rider users...\n";
    
    $stmt = $db->prepare('SELECT id, name, email, role FROM users WHERE role = ?');
    $stmt->execute(['rider']);
    $riders = $stmt->fetchAll();
    
    echo "Found " . count($riders) . " rider(s):\n";
    foreach ($riders as $rider) {
        echo "- ID: {$rider['id']}, Name: {$rider['name']}, Email: {$rider['email']}\n";
    }
    
} catch (Exception $e) {
    echo "ERROR: " . $e->getMessage() . "\n";
}
