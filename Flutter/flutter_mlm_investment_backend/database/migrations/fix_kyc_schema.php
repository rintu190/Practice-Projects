<?php
require_once __DIR__ . '/config/database.php';

try {
    $conn = Database::getInstance()->getConnection();
    
    echo "Fixing kyc_documents table schema...\n\n";
    
    // Make old columns nullable since we're using new specific columns
    $alterQueries = [
        "ALTER TABLE kyc_documents MODIFY COLUMN document_type ENUM('pan','aadhaar','passport','driving_license') NULL",
        "ALTER TABLE kyc_documents MODIFY COLUMN document_number VARCHAR(50) NULL",
        "ALTER TABLE kyc_documents MODIFY COLUMN document_image VARCHAR(255) NULL"
    ];
    
    foreach ($alterQueries as $query) {
        try {
            $conn->exec($query);
            echo "✓ Executed: " . substr($query, 0, 80) . "...\n";
        } catch (PDOException $e) {
            echo "⚠ Warning: " . $e->getMessage() . "\n";
        }
    }
    
    echo "\n=== Updated kyc_documents Schema ===\n";
    $stmt = $conn->query("DESCRIBE kyc_documents");
    $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);
    foreach ($columns as $col) {
        $null = $col['Null'] === 'YES' ? 'NULL' : 'NOT NULL';
        $default = $col['Default'] ? " DEFAULT {$col['Default']}" : '';
        echo "{$col['Field']} ({$col['Type']}) {$null}{$default}\n";
    }
    
    echo "\n✅ Schema fixed successfully!\n";
    
} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
