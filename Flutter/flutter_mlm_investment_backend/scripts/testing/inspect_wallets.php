<?php
require_once __DIR__ . '/config/database.php';

try {
    $db = Database::getInstance();
    $conn = $db->getConnection();
    
    // Check Columns
    $stmt = $conn->query("DESCRIBE wallets");
    echo "=== Wallets Schema ===\n";
    print_r($stmt->fetchAll(PDO::FETCH_COLUMN));
    
    // Check Data for User 3
    $stmt = $conn->prepare("SELECT * FROM wallets WHERE user_id = 3");
    $stmt->execute();
    echo "\n=== Wallet Data (User 3) ===\n";
    print_r($stmt->fetch(PDO::FETCH_ASSOC));
    
    // Check Deposits for User 3
    $stmt = $conn->prepare("SELECT * FROM deposits WHERE user_id = 3 ORDER BY id DESC LIMIT 5");
    $stmt->execute();
    echo "\n=== Recent Deposits (User 3) ===\n";
    print_r($stmt->fetchAll(PDO::FETCH_ASSOC));
    
} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
?>
