<?php
/**
 * Database Schema Import Script
 * Run this file once to create all database tables
 */

require_once __DIR__ . '/config/config.php';
require_once __DIR__ . '/config/database.php';

try {
    $db = Database::getInstance()->getConnection();
    
    // Read the schema file
    $schemaFile = __DIR__ . '/database/schema.sql';
    
    if (!file_exists($schemaFile)) {
        die("Error: schema.sql file not found at: $schemaFile\n");
    }
    
    $sql = file_get_contents($schemaFile);
    
    if ($sql === false) {
        die("Error: Could not read schema.sql file\n");
    }
    
    echo "Starting database schema import...\n\n";
    
    // Split SQL into individual statements
    $statements = array_filter(
        array_map('trim', explode(';', $sql)),
        function($stmt) {
            return !empty($stmt) && 
                   !preg_match('/^--/', $stmt) && 
                   !preg_match('/^\/\*/', $stmt);
        }
    );
    
    $successCount = 0;
    $errorCount = 0;
    
    foreach ($statements as $statement) {
        // Skip comments and empty statements
        if (empty(trim($statement))) {
            continue;
        }
        
        try {
            $db->exec($statement);
            
            // Extract table name for display
            if (preg_match('/CREATE TABLE\s+(?:IF NOT EXISTS\s+)?`?(\w+)`?/i', $statement, $matches)) {
                echo "✓ Created table: {$matches[1]}\n";
            } elseif (preg_match('/CREATE DATABASE\s+(?:IF NOT EXISTS\s+)?`?(\w+)`?/i', $statement, $matches)) {
                echo "✓ Created database: {$matches[1]}\n";
            } elseif (preg_match('/USE\s+`?(\w+)`?/i', $statement, $matches)) {
                echo "✓ Using database: {$matches[1]}\n";
            }
            
            $successCount++;
        } catch (PDOException $e) {
            // Check if error is "table already exists"
            if (strpos($e->getMessage(), 'already exists') !== false) {
                if (preg_match('/CREATE TABLE\s+(?:IF NOT EXISTS\s+)?`?(\w+)`?/i', $statement, $matches)) {
                    echo "⊙ Table already exists: {$matches[1]}\n";
                }
            } else {
                echo "✗ Error: " . $e->getMessage() . "\n";
                $errorCount++;
            }
        }
    }
    
    echo "\n========================================\n";
    echo "Schema import completed!\n";
    echo "Successful statements: $successCount\n";
    echo "Errors: $errorCount\n";
    echo "========================================\n\n";
    
    // Verify tables were created
    echo "Verifying tables...\n";
    $stmt = $db->query("SHOW TABLES");
    $tables = $stmt->fetchAll(PDO::FETCH_COLUMN);
    
    echo "Found " . count($tables) . " tables:\n";
    foreach ($tables as $table) {
        echo "  - $table\n";
    }
    
    echo "\n✓ Database setup complete!\n";
    
} catch (Exception $e) {
    echo "Fatal Error: " . $e->getMessage() . "\n";
    exit(1);
}
