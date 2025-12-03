<?php
require_once __DIR__ . '/config/database.php';

try {
    $db = Database::getInstance();
    $conn = $db->getConnection();

    $products = [
        [
            'Starter Plan',
            'Low risk starter plan with 1.5% daily ROI for 30 days.',
            1000,
            5000,
            1.5,
            30,
            'active'
        ],
        [
            'Growth Plan',
            'Medium risk growth plan with 2.0% daily ROI for 60 days.',
            5001,
            25000,
            2.0,
            60,
            'active'
        ],
        [
            'Premium Plan',
            'High return premium plan with 2.5% daily ROI for 90 days.',
            25001,
            100000,
            2.5,
            90,
            'active'
        ],
        [
            'Elite Plan',
            'Elite plan for serious investors with 3.0% daily ROI for 120 days.',
            100001,
            1000000,
            3.0,
            120,
            'active'
        ]
    ];

    $stmt = $conn->prepare("
        INSERT INTO investment_products (
            name, description, min_amount, max_amount, 
            roi_percentage, duration_days, status
        ) VALUES (?, ?, ?, ?, ?, ?, ?)
    ");

    foreach ($products as $product) {
        // Check if exists
        $check = $conn->prepare("SELECT id FROM investment_products WHERE name = ?");
        $check->execute([$product[0]]);
        if (!$check->fetch()) {
            $stmt->execute($product);
            echo "Inserted: " . $product[0] . "\n";
        } else {
            echo "Skipped: " . $product[0] . " (Already exists)\n";
        }
    }

    echo "Product seeding completed.\n";

} catch (Exception $e) {
    echo "Error seeding products: " . $e->getMessage() . "\n";
}
?>
