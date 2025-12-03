<?php
require_once 'config/database.php';

try {
    $conn = Database::getInstance()->getConnection();
    
    echo "=== Checking Users Table ===\n";
    $stmt = $conn->query("SELECT id, phone, full_name, `rank` FROM users LIMIT 5");
    $users = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    foreach ($users as $user) {
        echo "User ID: {$user['id']}, Name: {$user['full_name']}, Rank: '{$user['rank']}'\n";
    }
    
    echo "\n=== Checking Ranks Table ===\n";
    $stmt = $conn->query("SELECT id, rank_name, min_team_size, min_business_volume FROM ranks ORDER BY id");
    $ranks = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    foreach ($ranks as $rank) {
        echo "Rank ID: {$rank['id']}, Name: '{$rank['rank_name']}', Min Team: {$rank['min_team_size']}, Min Business: {$rank['min_business_volume']}\n";
    }
    
} catch (PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
