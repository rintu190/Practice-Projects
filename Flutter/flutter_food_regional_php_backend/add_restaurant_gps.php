<?php
require_once __DIR__ . '/config/Database.php';

// Manually load .env for CLI execution
if (file_exists(__DIR__ . '/.env')) {
    $lines = file(__DIR__ . '/.env', FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
    foreach ($lines as $line) {
        if (strpos(trim($line), '#') === 0) continue;
        list($name, $value) = explode('=', $line, 2);
        $_ENV[trim($name)] = trim($value);
    }
}

$database = new Database();
$db = $database->getConnection();

try {
    // Add latitude column
    $stmt = $db->prepare("
        SELECT COUNT(*) 
        FROM information_schema.columns 
        WHERE table_schema = ? 
        AND table_name = 'restaurants' 
        AND column_name = 'latitude'
    ");
    $stmt->execute([$_ENV['DB_NAME']]);
    
    if ($stmt->fetchColumn() == 0) {
        $db->exec("ALTER TABLE restaurants ADD COLUMN latitude DECIMAL(10,8) NULL");
        echo "Added latitude column to restaurants table.\n";
    } else {
        echo "latitude column already exists in restaurants table.\n";
    }

    // Add longitude column
    $stmt = $db->prepare("
        SELECT COUNT(*) 
        FROM information_schema.columns 
        WHERE table_schema = ? 
        AND table_name = 'restaurants' 
        AND column_name = 'longitude'
    ");
    $stmt->execute([$_ENV['DB_NAME']]);
    
    if ($stmt->fetchColumn() == 0) {
        $db->exec("ALTER TABLE restaurants ADD COLUMN longitude DECIMAL(11,8) NULL");
        echo "Added longitude column to restaurants table.\n";
    } else {
        echo "longitude column already exists in restaurants table.\n";
    }

} catch (PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
