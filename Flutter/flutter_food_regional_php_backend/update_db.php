<?php
// Load .env file
if (file_exists(__DIR__ . '/.env')) {
    $lines = file(__DIR__ . '/.env', FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
    foreach ($lines as $line) {
        if (strpos($line, '=') !== false && strpos($line, '#') !== 0) {
            list($key, $value) = explode('=', $line, 2);
            $_ENV[trim($key)] = trim($value);
        }
    }
}

require_once __DIR__ . '/config/Database.php';

try {
    $database = new Database();
    $db = $database->getConnection();

    $sql = "ALTER TABLE users ADD COLUMN latitude DECIMAL(10, 8) NULL, ADD COLUMN longitude DECIMAL(11, 8) NULL";
    $db->exec($sql);
    echo "Columns added successfully\n";
} catch (PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
