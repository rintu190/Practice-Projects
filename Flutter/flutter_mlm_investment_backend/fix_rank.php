<?php
require_once 'config/database.php';

try {
    $conn = Database::getInstance()->getConnection();
    
    // Update all users with 'Member' rank to 'Basic'
    $stmt = $conn->prepare("UPDATE users SET `rank` = 'Basic' WHERE `rank` = 'Member' OR `rank` IS NULL");
    $stmt->execute();
    
    $rowCount = $stmt->rowCount();
    
    echo "Successfully updated $rowCount user(s) from 'Member' to 'Basic' rank.\n";
    
    // Also update the ranks table if needed
    $stmt = $conn->prepare("UPDATE ranks SET rank_name = 'Basic' WHERE rank_name = 'Member'");
    $stmt->execute();
    
    $rankCount = $stmt->rowCount();
    echo "Successfully updated $rankCount rank(s) in ranks table.\n";
    
    echo "\nDone! All users should now show 'Basic' rank.\n";
    
} catch (PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
