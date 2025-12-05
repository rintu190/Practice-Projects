<?php
require_once __DIR__ . '/config/config.php';
require_once __DIR__ . '/config/database.php';

try {
    $db = Database::getInstance()->getConnection();
    
    echo "Creating commission tables...\n\n";
    
    // Disable foreign key checks temporarily
    $db->exec("SET FOREIGN_KEY_CHECKS = 0");
    
    // 1. Commission Rules
    echo "Creating commission_rules table...\n";
    $db->exec("
        CREATE TABLE IF NOT EXISTS commission_rules (
            id INT AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR(100) NOT NULL,
            type ENUM('direct', 'level', 'matching', 'rank', 'investment', 'roi', 'pool') NOT NULL,
            model_type ENUM('binary', 'unilevel', 'matrix', 'hybrid', 'all') DEFAULT 'all',
            level INT DEFAULT NULL COMMENT 'For level/unilevel bonuses',
            rank_required VARCHAR(50) DEFAULT NULL,
            percentage DECIMAL(5, 2) DEFAULT 0.00,
            fixed_amount DECIMAL(15, 2) DEFAULT 0.00,
            is_active BOOLEAN DEFAULT TRUE,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
        ) ENGINE=InnoDB
    ");
    echo "✓ commission_rules table created\n\n";
    
    // 2. Commissions (Logs)
    echo "Creating commissions table...\n";
    $db->exec("
        CREATE TABLE IF NOT EXISTS commissions (
            id INT AUTO_INCREMENT PRIMARY KEY,
            user_id INT NOT NULL,
            source_user_id INT DEFAULT NULL,
            amount DECIMAL(15, 2) NOT NULL,
            type ENUM('direct', 'level', 'matching', 'rank', 'investment', 'roi', 'pool') NOT NULL,
            description VARCHAR(255),
            status ENUM('pending', 'paid', 'cancelled') DEFAULT 'pending',
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
            FOREIGN KEY (source_user_id) REFERENCES users(id) ON DELETE SET NULL,
            INDEX idx_user_type (user_id, type),
            INDEX idx_created_at (created_at)
        ) ENGINE=InnoDB
    ");
    echo "✓ commissions table created\n\n";
    
    // Insert some default rules
    echo "Seeding default commission rules...\n";
    $stmt = $db->prepare("SELECT COUNT(*) FROM commission_rules");
    $stmt->execute();
    if ($stmt->fetchColumn() == 0) {
        $db->exec("
            INSERT INTO commission_rules (name, type, model_type, level, percentage, is_active) VALUES
            ('Direct Referral Bonus', 'direct', 'all', 1, 10.00, 1),
            ('Level 1 Bonus', 'level', 'unilevel', 1, 5.00, 1),
            ('Level 2 Bonus', 'level', 'unilevel', 2, 3.00, 1),
            ('Level 3 Bonus', 'level', 'unilevel', 3, 2.00, 1),
            ('Matching Bonus', 'matching', 'binary', NULL, 10.00, 1),
            ('ROI Daily', 'roi', 'all', NULL, 1.50, 1)
        ");
        echo "✓ Default rules seeded\n";
    } else {
        echo "• Rules already exist, skipping seed\n";
    }

    // Re-enable foreign key checks
    $db->exec("SET FOREIGN_KEY_CHECKS = 1");
    
    echo "\n✅ Commission tables setup complete!\n";
    
} catch (Exception $e) {
    echo "❌ Fatal Error: " . $e->getMessage() . "\n";
    exit(1);
}
