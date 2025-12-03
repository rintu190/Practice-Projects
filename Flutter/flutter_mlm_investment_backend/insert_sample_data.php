<?php
/**
 * Insert Sample Data for Testing
 */

require_once __DIR__ . '/config/config.php';
require_once __DIR__ . '/config/database.php';

try {
    $db = Database::getInstance()->getConnection();
    
    echo "Inserting sample data...\n\n";
    
    // 1. Insert sample investment products
    echo "Inserting investment products...\n";
    $db->exec("
        INSERT IGNORE INTO investment_products (id, name, description, min_amount, max_amount, roi_percentage, duration_days, status) VALUES
        (1, 'Gold Plan', 'High returns investment plan', 10000, 100000, 2.5, 365, 'active'),
        (2, 'Silver Plan', 'Medium returns investment plan', 5000, 50000, 1.8, 180, 'active'),
        (3, 'Bronze Plan', 'Starter investment plan', 1000, 10000, 1.2, 90, 'active')
    ");
    echo "✓ Investment products inserted\n\n";
    
    // 2. Insert sample ranks
    echo "Inserting ranks...\n";
    $db->exec("
        INSERT IGNORE INTO ranks (id, name, min_team_size, min_business_volume, benefits) VALUES
        (1, 'Basic', 0, 0, 'Basic benefits'),
        (2, 'Silver', 5, 50000, 'Silver tier benefits'),
        (3, 'Gold', 15, 150000, 'Gold tier benefits'),
        (4, 'Platinum', 50, 500000, 'Platinum tier benefits'),
        (5, 'Diamond', 100, 1000000, 'Diamond tier benefits')
    ");
    echo "✓ Ranks inserted\n\n";
    
    echo "✅ Sample data inserted successfully!\n";
    echo "\nYou can now test the app with the backend.\n";
    echo "Use any 10-digit phone number to login (OTP will be printed in the response).\n";
    
} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
