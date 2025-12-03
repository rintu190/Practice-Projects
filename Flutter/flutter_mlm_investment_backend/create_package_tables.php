<?php
require_once __DIR__ . '/config/database.php';

try {
    $conn = Database::getInstance()->getConnection();
    
    echo "Creating package management tables...\n\n";
    
    $conn->exec("SET FOREIGN_KEY_CHECKS = 0");
    
    // 1. Packages Table
    echo "Creating packages table...\n";
    $conn->exec("
        CREATE TABLE IF NOT EXISTS packages (
            id INT AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR(100) NOT NULL,
            description TEXT,
            type ENUM('joining', 'renewal', 'addon') NOT NULL,
            price DECIMAL(10, 2) NOT NULL,
            gst_rate DECIMAL(5, 2) DEFAULT 18.00,
            validity_days INT DEFAULT NULL COMMENT 'NULL for lifetime',
            features JSON COMMENT 'Package features/benefits',
            is_active BOOLEAN DEFAULT TRUE,
            sort_order INT DEFAULT 0,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            INDEX idx_type (type),
            INDEX idx_active (is_active)
        ) ENGINE=InnoDB
    ");
    echo "✓ packages table created\n\n";
    
    // 2. Package Purchases Table
    echo "Creating package_purchases table...\n";
    $conn->exec("
        CREATE TABLE IF NOT EXISTS package_purchases (
            id INT AUTO_INCREMENT PRIMARY KEY,
            user_id INT NOT NULL,
            package_id INT NOT NULL,
            amount DECIMAL(10, 2) NOT NULL,
            gst_amount DECIMAL(10, 2) NOT NULL,
            total_amount DECIMAL(10, 2) NOT NULL,
            payment_method ENUM('wallet', 'gateway') DEFAULT 'wallet',
            status ENUM('pending', 'completed', 'failed', 'refunded') DEFAULT 'pending',
            invoice_number VARCHAR(50) UNIQUE,
            purchased_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            expires_at TIMESTAMP NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
            FOREIGN KEY (package_id) REFERENCES packages(id) ON DELETE RESTRICT,
            INDEX idx_user_status (user_id, status),
            INDEX idx_invoice (invoice_number)
        ) ENGINE=InnoDB
    ");
    echo "✓ package_purchases table created\n\n";
    
    // 3. Invoices Table
    echo "Creating invoices table...\n";
    $conn->exec("
        CREATE TABLE IF NOT EXISTS invoices (
            id INT AUTO_INCREMENT PRIMARY KEY,
            purchase_id INT NOT NULL,
            invoice_number VARCHAR(50) UNIQUE NOT NULL,
            user_id INT NOT NULL,
            subtotal DECIMAL(10, 2) NOT NULL,
            gst_amount DECIMAL(10, 2) NOT NULL,
            total_amount DECIMAL(10, 2) NOT NULL,
            invoice_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (purchase_id) REFERENCES package_purchases(id) ON DELETE CASCADE,
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
            INDEX idx_invoice_number (invoice_number),
            INDEX idx_user (user_id)
        ) ENGINE=InnoDB
    ");
    echo "✓ invoices table created\n\n";
    
    $conn->exec("SET FOREIGN_KEY_CHECKS = 1");
    
    // Seed default packages
    echo "Seeding default packages...\n";
    $stmt = $conn->prepare("SELECT COUNT(*) FROM packages");
    $stmt->execute();
    if ($stmt->fetchColumn() == 0) {
        $packages = [
            [
                'name' => 'Basic Package',
                'description' => 'Perfect for getting started with MLM business',
                'type' => 'joining',
                'price' => 2500.00,
                'features' => json_encode([
                    'Direct commission: 10%',
                    'Level bonus up to 3 levels',
                    'Basic training materials',
                    'Email support'
                ]),
                'sort_order' => 1
            ],
            [
                'name' => 'Premium Package',
                'description' => 'Enhanced features for serious entrepreneurs',
                'type' => 'joining',
                'price' => 5000.00,
                'features' => json_encode([
                    'Direct commission: 15%',
                    'Level bonus up to 5 levels',
                    'Premium training materials',
                    'Priority support',
                    'Marketing tools included'
                ]),
                'sort_order' => 2
            ],
            [
                'name' => 'Elite Package',
                'description' => 'Maximum benefits for top performers',
                'type' => 'joining',
                'price' => 10000.00,
                'features' => json_encode([
                    'Direct commission: 20%',
                    'Level bonus up to 7 levels',
                    'Elite training & mentorship',
                    '24/7 dedicated support',
                    'Advanced marketing suite',
                    'Exclusive webinars & events'
                ]),
                'sort_order' => 3
            ],
            [
                'name' => 'Annual Renewal',
                'description' => 'Renew your package for another year',
                'type' => 'renewal',
                'price' => 1000.00,
                'validity_days' => 365,
                'features' => json_encode([
                    'Maintain your current rank',
                    'Continue earning commissions',
                    'Access to all features'
                ]),
                'sort_order' => 4
            ],
            [
                'name' => 'Extra Position',
                'description' => 'Add an extra position in genealogy tree',
                'type' => 'addon',
                'price' => 500.00,
                'features' => json_encode([
                    'Additional earning position',
                    'Expand your network',
                    'Increase income potential'
                ]),
                'sort_order' => 5
            ]
        ];
        
        $stmt = $conn->prepare("
            INSERT INTO packages (name, description, type, price, features, sort_order)
            VALUES (?, ?, ?, ?, ?, ?)
        ");
        
        foreach ($packages as $pkg) {
            $stmt->execute([
                $pkg['name'],
                $pkg['description'],
                $pkg['type'],
                $pkg['price'],
                $pkg['features'],
                $pkg['sort_order']
            ]);
        }
        echo "✓ Default packages seeded\n";
    } else {
        echo "• Packages already exist, skipping seed\n";
    }
    
    echo "\n✅ Package management system setup complete!\n";
    
} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
