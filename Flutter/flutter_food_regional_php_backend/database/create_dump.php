<?php
// Load environment variables manually for CLI execution
$envFile = __DIR__ . '/../.env';
if (file_exists($envFile)) {
    $lines = file($envFile, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
    foreach ($lines as $line) {
        if (strpos(trim($line), '#') === 0) continue;
        list($name, $value) = explode('=', $line, 2);
        $_ENV[trim($name)] = trim($value);
    }
} else {
    // Fallback defaults
    $_ENV['DB_HOST'] = $_ENV['DB_HOST'] ?? '127.0.0.1';
    $_ENV['DB_USER'] = $_ENV['DB_USER'] ?? 'root';
    $_ENV['DB_PASSWORD'] = $_ENV['DB_PASSWORD'] ?? 'root';
    $_ENV['DB_NAME'] = $_ENV['DB_NAME'] ?? 'flutter_food_regional';
}

require_once __DIR__ . '/../config/Database.php';

try {
    $database = new Database();
    $db = $database->getConnection();
    $dbName = $_ENV['DB_NAME'];
    
    echo "Starting database dump for '$dbName'...\n";
    
    $output = "-- Database Dump for $dbName\n";
    $output .= "-- Generated at " . date('Y-m-d H:i:s') . "\n\n";
    $output .= "SET FOREIGN_KEY_CHECKS=0;\n\n";
    
    // Get all tables
    $stmt = $db->query("SHOW TABLES");
    $tables = $stmt->fetchAll(PDO::FETCH_COLUMN);
    
    foreach ($tables as $table) {
        echo "Processing table: $table\n";
        
        // Get create table statement
        $stmt = $db->query("SHOW CREATE TABLE `$table`");
        $row = $stmt->fetch(PDO::FETCH_NUM);
        $createTable = $row[1];
        
        $output .= "-- Table structure for `$table`\n";
        $output .= "DROP TABLE IF EXISTS `$table`;\n";
        $output .= "$createTable;\n\n";
        
        // Get data
        $stmt = $db->query("SELECT * FROM `$table`");
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        if (count($rows) > 0) {
            $output .= "-- Dumping data for `$table`\n";
            
            foreach ($rows as $row) {
                $fields = array_map(function($value) use ($db) {
                    if ($value === null) return "NULL";
                    return $db->quote($value);
                }, array_values($row));
                
                $values = implode(", ", $fields);
                $output .= "INSERT INTO `$table` VALUES ($values);\n";
            }
            $output .= "\n";
        }
    }
    
    $output .= "SET FOREIGN_KEY_CHECKS=1;\n";
    
    // Save to file
    $dumpFile = __DIR__ . '/full_dump.sql';
    file_put_contents($dumpFile, $output);
    
    echo "Database dump created successfully at: $dumpFile\n";
    
} catch (Exception $e) {
    echo "ERROR: " . $e->getMessage() . "\n";
    exit(1);
}
