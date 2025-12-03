<?php
require_once __DIR__ . '/config/database.php';

try {
    $conn = Database::getInstance()->getConnection();
    
    echo "=== kyc_documents Schema ===\n";
    $stmt = $conn->query("DESCRIBE kyc_documents");
    $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);
    foreach ($columns as $col) {
        echo "{$col['Field']} ({$col['Type']})\n";
    }
    
} catch (PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
