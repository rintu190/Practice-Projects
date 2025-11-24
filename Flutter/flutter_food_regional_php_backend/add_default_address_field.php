<?php

// Load environment variables manually for CLI execution
$envFile = __DIR__ . '/.env';
if (file_exists($envFile)) {
    $lines = file($envFile, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
    foreach ($lines as $line) {
        if (strpos(trim($line), '#') === 0) continue;
        list($name, $value) = explode('=', $line, 2);
        $_ENV[trim($name)] = trim($value);
    }
}

try {
    $db = new PDO(
        "mysql:host={$_ENV['DB_HOST']};dbname={$_ENV['DB_NAME']}",
        $_ENV['DB_USER'],
        $_ENV['DB_PASSWORD']
    );
    $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Adding is_default field to addresses table...\n";

    // Add is_default column
    $db->exec("ALTER TABLE addresses ADD COLUMN is_default BOOLEAN DEFAULT FALSE");

    echo "Migration completed successfully!\n";
} catch (PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
    exit(1);
}
