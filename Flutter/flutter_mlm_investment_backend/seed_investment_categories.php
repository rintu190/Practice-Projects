<?php
require_once __DIR__ . '/config/database.php';

try {
    $db = Database::getInstance();
    $conn = $db->getConnection();
    
    echo "Seeding investment products with categories and tiers...\n\n";
    
    // Clear existing products
    $conn->exec("DELETE FROM investment_products");
    echo "Cleared existing products\n\n";
    
    $products = [
        // Securities
        ['Securities', 'Bronze', 'Securities Bronze Plan', 'Stock and bond investments - Bronze tier', 10000, 50000, 8.5, 365, 'daily', 'low'],
        ['Securities', 'Silver', 'Securities Silver Plan', 'Stock and bond investments - Silver tier', 50001, 200000, 10.5, 365, 'daily', 'low'],
        ['Securities', 'Gold', 'Securities Gold Plan', 'Stock and bond investments - Gold tier', 200001, 999999999, 12.5, 365, 'daily', 'low'],
        
        // Derivatives
        ['Derivatives', 'Bronze', 'Derivatives Bronze Plan', 'Options and futures trading - Bronze tier', 25000, 100000, 15.0, 180, 'weekly', 'medium'],
        ['Derivatives', 'Silver', 'Derivatives Silver Plan', 'Options and futures trading - Silver tier', 100001, 500000, 18.0, 180, 'weekly', 'medium'],
        ['Derivatives', 'Gold', 'Derivatives Gold Plan', 'Options and futures trading - Gold tier', 500001, 999999999, 22.0, 180, 'weekly', 'medium'],
        
        // Currency
        ['Currency', 'Bronze', 'Currency Bronze Plan', 'Forex and currency trading - Bronze tier', 15000, 75000, 9.5, 90, 'weekly', 'medium'],
        ['Currency', 'Silver', 'Currency Silver Plan', 'Forex and currency trading - Silver tier', 75001, 300000, 11.5, 90, 'weekly', 'medium'],
        ['Currency', 'Gold', 'Currency Gold Plan', 'Forex and currency trading - Gold tier', 300001, 999999999, 14.0, 90, 'weekly', 'medium'],
        
        // Commodity
        ['Commodity', 'Bronze', 'Commodity Bronze Plan', 'Gold, silver, and commodity futures - Bronze tier', 20000, 100000, 10.0, 180, 'monthly', 'medium'],
        ['Commodity', 'Silver', 'Commodity Silver Plan', 'Gold, silver, and commodity futures - Silver tier', 100001, 400000, 12.5, 180, 'monthly', 'medium'],
        ['Commodity', 'Gold', 'Commodity Gold Plan', 'Gold, silver, and commodity futures - Gold tier', 400001, 999999999, 15.0, 180, 'monthly', 'medium'],
        
        // Real Estate
        ['Real Estate', 'Bronze', 'Real Estate Bronze Plan', 'Property and real estate investments - Bronze tier', 50000, 250000, 7.5, 730, 'monthly', 'low'],
        ['Real Estate', 'Silver', 'Real Estate Silver Plan', 'Property and real estate investments - Silver tier', 250001, 1000000, 9.5, 730, 'monthly', 'low'],
        ['Real Estate', 'Gold', 'Real Estate Gold Plan', 'Property and real estate investments - Gold tier', 1000001, 999999999, 11.5, 730, 'monthly', 'low'],
    ];
    
    $stmt = $conn->prepare("
        INSERT INTO investment_products 
        (category, tier, name, description, min_amount, max_amount, roi_percentage, duration_days, roi_frequency, risk_level, status, product_type) 
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'active', 'fixed_plan')
    ");
    
    foreach ($products as $product) {
        $stmt->execute($product);
        echo "✓ Added: {$product[0]} - {$product[1]} ({$product[6]}% ROI)\n";
    }
    
    echo "\n✓ Successfully seeded " . count($products) . " investment products!\n";
    
} catch (PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
