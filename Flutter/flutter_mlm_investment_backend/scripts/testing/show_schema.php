<?php
require_once 'config/database.php';

try {
    $conn = Database::getInstance()->getConnection();
    
    echo "=== Users Table Schema ===\n";
    $stmt = $conn->query("DESCRIBE users");
    $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    foreach ($columns as $col) {
        echo "{$col['Field']} ({$col['Type']})\n";
    }
    
    echo "\n=== Current User Data ===\n";
    $stmt = $conn->query("SELECT * FROM users LIMIT 1");
    $user = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if ($user) {
        foreach ($user as $key => $value) {
            if ($key === 'rank') {
                echo ">>> $key: '$value' <<<\n";
            } else {
                echo "$key: $value\n";
            }
        }
    }
    
} catch (PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
