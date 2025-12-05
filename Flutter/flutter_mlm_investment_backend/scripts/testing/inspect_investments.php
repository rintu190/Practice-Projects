<?php
require_once 'config/database.php';

try {
    $conn = Database::getInstance()->getConnection();
    
    echo "=== user_investments Schema ===\n";
    $stmt = $conn->query("DESCRIBE user_investments");
    $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);
    foreach ($columns as $col) {
        echo "{$col['Field']} ({$col['Type']}) - {$col['Null']} - Default: {$col['Default']}\n";
    }
    
    echo "\n=== Sample Investment Data ===\n";
    $stmt = $conn->query("SELECT * FROM user_investments ORDER BY created_at DESC LIMIT 3");
    print_r($stmt->fetchAll(PDO::FETCH_ASSOC));
    
} catch (PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
