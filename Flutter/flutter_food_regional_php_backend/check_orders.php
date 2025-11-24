<?php
$_ENV['DB_HOST'] = '127.0.0.1';
$_ENV['DB_USER'] = 'root';
$_ENV['DB_PASSWORD'] = 'root';
$_ENV['DB_NAME'] = 'flutter_food_regional';
require_once __DIR__ . '/config/Database.php';

try {
    $database = new Database();
    $db = $database->getConnection();
    
    echo "Checking orders and rider assignments...\n\n";
    
    // Get rider user
    $stmt = $db->query("SELECT id, name, email FROM users WHERE role = 'rider'");
    $riders = $stmt->fetchAll();
    
    echo "Riders in system:\n";
    foreach ($riders as $rider) {
        echo "- {$rider['name']} ({$rider['email']}) - ID: {$rider['id']}\n";
    }
    
    echo "\n";
    
    // Get all orders
    $stmt = $db->query("SELECT id, user_id, restaurant_id, rider_id, status FROM orders");
    $orders = $stmt->fetchAll();
    
    echo "Orders in system:\n";
    foreach ($orders as $order) {
        $riderId = $order['rider_id'] ?? 'NULL';
        echo "- Order {$order['id']} - Rider: $riderId - Status: {$order['status']}\n";
    }
    
} catch (Exception $e) {
    echo "ERROR: " . $e->getMessage() . "\n";
}
