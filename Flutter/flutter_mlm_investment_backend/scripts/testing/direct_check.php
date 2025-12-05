<?php
require_once 'config/database.php';

try {
    // Force a fresh connection
    $conn = Database::getInstance()->getConnection();
    
    echo "=== Direct Query Test ===\n";
    $result = $conn->query("SELECT id, phone, `rank` FROM users WHERE id = 2");
    $user = $result->fetch(PDO::FETCH_ASSOC);
    
    echo "User ID: {$user['id']}\n";
    echo "Phone: {$user['phone']}\n";
    echo "Rank: '{$user['rank']}'\n";
    echo "Rank length: " . strlen($user['rank']) . "\n";
    echo "Rank hex: " . bin2hex($user['rank']) . "\n";
    
} catch (PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
