<?php
require_once __DIR__ . '/config/database.php';

try {
    $conn = Database::getInstance()->getConnection();
    
    echo "Adding KYC document columns...\n\n";
    
    // Add new columns for PAN and Aadhaar
    $alterQueries = [
        "ALTER TABLE kyc_documents ADD COLUMN pan_number VARCHAR(10) AFTER user_id",
        "ALTER TABLE kyc_documents ADD COLUMN pan_image VARCHAR(255) AFTER pan_number",
        "ALTER TABLE kyc_documents ADD COLUMN aadhaar_number VARCHAR(12) AFTER pan_image",
        "ALTER TABLE kyc_documents ADD COLUMN aadhaar_front_image VARCHAR(255) AFTER aadhaar_number",
        "ALTER TABLE kyc_documents ADD COLUMN aadhaar_back_image VARCHAR(255) AFTER aadhaar_front_image",
        "ALTER TABLE kyc_documents ADD COLUMN submitted_at TIMESTAMP NULL AFTER aadhaar_back_image"
    ];
    
    foreach ($alterQueries as $query) {
        try {
            $conn->exec($query);
            echo "✓ Executed: " . substr($query, 0, 80) . "...\n";
        } catch (PDOException $e) {
            // Column might already exist
            if (strpos($e->getMessage(), 'Duplicate column') !== false) {
                echo "• Column already exists, skipping\n";
            } else {
                throw $e;
            }
        }
    }
    
    echo "\n=== Updated kyc_documents Schema ===\n";
    $stmt = $conn->query("DESCRIBE kyc_documents");
    $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);
    foreach ($columns as $col) {
        echo "{$col['Field']} ({$col['Type']})\n";
    }
    
    echo "\n✅ KYC schema updated successfully!\n";
    
} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
