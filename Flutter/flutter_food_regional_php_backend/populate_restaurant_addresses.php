<?php
$_ENV['DB_HOST'] = '127.0.0.1';
$_ENV['DB_USER'] = 'root';
$_ENV['DB_PASSWORD'] = 'root';
$_ENV['DB_NAME'] = 'flutter_food_regional';
require_once __DIR__ . '/config/Database.php';

try {
    $database = new Database();
    $db = $database->getConnection();
    
    echo "Adding sample addresses to restaurants...\n";
    
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
        
        $stmt = $db->prepare('UPDATE restaurants SET address = ?, phone = ? WHERE id = ?');
        $stmt->execute([$address, $phone, $restaurant['id']]);
        
        echo "Updated {$restaurant['name']}: $address, $phone\n";
    }
    
    echo "\nSUCCESS: All restaurants updated with addresses and phones.\n";
    
} catch (Exception $e) {
    echo "ERROR: " . $e->getMessage() . "\n";
}
