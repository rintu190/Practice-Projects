<?php
require_once 'config/database.php';

try {
    $conn = Database::getInstance()->getConnection();
    
    // Start transaction explicitly
    $conn->beginTransaction();
    
    echo "Starting transaction...\n";
    
    // Update with explicit transaction
    $stmt = $conn->prepare("UPDATE users SET `rank` = ? WHERE `rank` = ?");
    $stmt->execute(['Basic', 'Member']);
    
    $rowCount = $stmt->rowCount();
    echo "Rows affected: $rowCount\n";
    
    // Commit the transaction
    $conn->commit();
    echo "Transaction committed!\n\n";
    
    // Verify immediately
    echo "=== Verification ===\n";
    $stmt = $conn->query("SELECT id, phone, `rank` FROM users");
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        echo "User {$row['id']}: rank = '{$row['rank']}'\n";
    }
    
} catch (PDOException $e) {
    if ($conn->inTransaction()) {
        $conn->rollBack();
    }
    echo "Error: " . $e->getMessage() . "\n";
}
