<?php
require_once 'config/database.php';

try {
    $conn = Database::getInstance()->getConnection();
    
    // Update all users with 'Member' rank to 'Basic' - using backticks for reserved keyword
    $stmt = $conn->prepare("UPDATE users SET `rank` = 'Basic' WHERE `rank` = 'Member'");
    $stmt->execute();
    
    $rowCount = $stmt->rowCount();
    echo "Successfully updated $rowCount user(s) from 'Member' to 'Basic' rank.\n";
    
    // Verify the change
    echo "\n=== Verification ===\n";
    $stmt = $conn->query("SELECT id, phone, `rank` FROM users");
    $users = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    foreach ($users as $user) {
        echo "User ID: {$user['id']}, Phone: {$user['phone']}, Rank: '{$user['rank']}'\n";
    }
    
} catch (PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
