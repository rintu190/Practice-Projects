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
    // Fallback defaults if .env not found (e.g. Docker)
    $_ENV['DB_HOST'] = $_ENV['DB_HOST'] ?? '127.0.0.1';
    $_ENV['DB_USER'] = $_ENV['DB_USER'] ?? 'root';
    $_ENV['DB_PASSWORD'] = $_ENV['DB_PASSWORD'] ?? 'root';
    $_ENV['DB_NAME'] = $_ENV['DB_NAME'] ?? 'flutter_food_regional';
}

require_once __DIR__ . '/../config/Database.php';

try {
    $database = new Database();
    $db = $database->getConnection();
    
    echo "Starting data migration...\n";

    // --- Populate Restaurant Addresses ---
    echo "Populating restaurant addresses and phones...\n";
    
    // Get all restaurants
    $stmt = $db->query('SELECT id, name FROM restaurants');
    $restaurants = $stmt->fetchAll();
    
    $addresses = [
        'MG Road, Bangalore, Karnataka 560001',
        'Connaught Place, New Delhi 110001',
        'Park Street, Kolkata, West Bengal 700016',
        'Marine Drive, Mumbai, Maharashtra 400002',
        'Anna Salai, Chennai, Tamil Nadu 600002',
        'Banjara Hills, Hyderabad, Telangana 500034',
        'Saheed Nagar, Bhubaneswar, Odisha 751007',
        'Civil Lines, Jaipur, Rajasthan 302006',
    ];
    
    $phones = [
        '+91 80 1234 5678',
        '+91 11 2345 6789',
        '+91 33 3456 7890',
        '+91 22 4567 8901',
        '+91 44 5678 9012',
        '+91 40 6789 0123',
        '+91 674 789 0124',
        '+91 141 890 1235',
    ];
    
    foreach ($restaurants as $index => $restaurant) {
        $address = $addresses[$index % count($addresses)];
        $phone = $phones[$index % count($phones)];
        
        // Only update if address is null to avoid overwriting existing data
        $stmt = $db->prepare('UPDATE restaurants SET address = ?, phone = ? WHERE id = ? AND (address IS NULL OR address = "")');
        $stmt->execute([$address, $phone, $restaurant['id']]);
        
        if ($stmt->rowCount() > 0) {
            echo "Updated {$restaurant['name']}: $address, $phone\n";
        }
    }
    
    echo "Data migration completed successfully!\n";
    
} catch (Exception $e) {
    echo "ERROR: " . $e->getMessage() . "\n";
    exit(1);
}
