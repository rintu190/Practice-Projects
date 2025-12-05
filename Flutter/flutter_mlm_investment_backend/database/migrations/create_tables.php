<?php
/**
 * Simple Database Table Creator
 * Creates tables one by one with better error handling
 */

require_once __DIR__ . '/config/config.php';
require_once __DIR__ . '/config/database.php';

try {
    $db = Database::getInstance()->getConnection();
    
    echo "Creating database tables...\n\n";
    
    // Disable foreign key checks temporarily
    $db->exec("SET FOREIGN_KEY_CHECKS = 0");
    
    // 1. Users table (must be first due to foreign keys)
    echo "Creating users table...\n";
    $db->exec("
        CREATE TABLE IF NOT EXISTS users (
            id INT AUTO_INCREMENT PRIMARY KEY,
            phone VARCHAR(15) UNIQUE NOT NULL,
            email VARCHAR(255) UNIQUE,
            password_hash VARCHAR(255),
            referral_code VARCHAR(20) UNIQUE NOT NULL,
            referred_by INT,
            status ENUM('active', 'suspended', 'blocked') DEFAULT 'active',
            kyc_status ENUM('pending', 'submitted', 'approved', 'rejected') DEFAULT 'pending',
            is_admin BOOLEAN DEFAULT FALSE,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            last_login TIMESTAMP NULL,
            INDEX idx_referral_code (referral_code),
            INDEX idx_referred_by (referred_by),
            INDEX idx_phone (phone)
        ) ENGINE=InnoDB
    ");
    echo "✓ users table created\n\n";
    
    // 2. User Profiles
    echo "Creating user_profiles table...\n";
    $db->exec("
        CREATE TABLE IF NOT EXISTS user_profiles (
            id INT AUTO_INCREMENT PRIMARY KEY,
            user_id INT UNIQUE NOT NULL,
            full_name VARCHAR(255) NOT NULL,
            date_of_birth DATE,
            gender ENUM('male', 'female', 'other'),
            address TEXT,
            city VARCHAR(100),
            state VARCHAR(100),
            pincode VARCHAR(10),
            profile_image VARCHAR(255),
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
        ) ENGINE=InnoDB
    ");
    echo "✓ user_profiles table created\n\n";
    
    // 3. Wallets
    echo "Creating wallets table...\n";
    $db->exec("
        CREATE TABLE IF NOT EXISTS wallets (
            id INT AUTO_INCREMENT PRIMARY KEY,
            user_id INT UNIQUE NOT NULL,
            e_wallet_balance DECIMAL(15, 2) DEFAULT 0.00,
            investment_wallet_balance DECIMAL(15, 2) DEFAULT 0.00,
            total_earned DECIMAL(15, 2) DEFAULT 0.00,
            total_withdrawn DECIMAL(15, 2) DEFAULT 0.00,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
        ) ENGINE=InnoDB
    ");
    echo "✓ wallets table created\n\n";
    
    // 4. Transactions
    echo "Creating transactions table...\n";
    $db->exec("
        CREATE TABLE IF NOT EXISTS transactions (
            id INT AUTO_INCREMENT PRIMARY KEY,
            user_id INT NOT NULL,
            wallet_type ENUM('e_wallet', 'investment_wallet') NOT NULL,
            type ENUM('credit', 'debit') NOT NULL,
            amount DECIMAL(15, 2) NOT NULL,
            balance_before DECIMAL(15, 2) NOT NULL,
            balance_after DECIMAL(15, 2) NOT NULL,
            description VARCHAR(255),
            reference_id VARCHAR(100),
            reference_type VARCHAR(50),
            status ENUM('pending', 'completed', 'failed', 'cancelled') DEFAULT 'completed',
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
            INDEX idx_user_wallet (user_id, wallet_type),
            INDEX idx_created_at (created_at)
        ) ENGINE=InnoDB
    ");
    echo "✓ transactions table created\n\n";
    
    // 5. Investment Products
    echo "Creating investment_products table...\n";
    $db->exec("
        CREATE TABLE IF NOT EXISTS investment_products (
            id INT AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR(255) NOT NULL,
            description TEXT,
            min_amount DECIMAL(15, 2) NOT NULL,
            max_amount DECIMAL(15, 2) NOT NULL,
            roi_percentage DECIMAL(5, 2) NOT NULL,
            duration_days INT NOT NULL,
            status ENUM('active', 'inactive') DEFAULT 'active',
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
        ) ENGINE=InnoDB
    ");
    echo "✓ investment_products table created\n\n";
    
    // 6. User Investments
    echo "Creating user_investments table...\n";
    $db->exec("
        CREATE TABLE IF NOT EXISTS user_investments (
            id INT AUTO_INCREMENT PRIMARY KEY,
            user_id INT NOT NULL,
            product_id INT NOT NULL,
            amount DECIMAL(15, 2) NOT NULL,
            roi_percentage DECIMAL(5, 2) NOT NULL,
            maturity_date DATE NOT NULL,
            status ENUM('active', 'matured', 'withdrawn', 'cancelled') DEFAULT 'active',
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
            FOREIGN KEY (product_id) REFERENCES investment_products(id) ON DELETE CASCADE,
            INDEX idx_user_status (user_id, status)
        ) ENGINE=InnoDB
    ");
    echo "✓ user_investments table created\n\n";
    
    // 7. Genealogy
    echo "Creating genealogy table...\n";
    $db->exec("
        CREATE TABLE IF NOT EXISTS genealogy (
            id INT AUTO_INCREMENT PRIMARY KEY,
            user_id INT UNIQUE NOT NULL,
            sponsor_id INT,
            parent_id INT,
            position ENUM('left', 'right', 'center') DEFAULT NULL,
            level INT DEFAULT 1,
            path VARCHAR(500),
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
            FOREIGN KEY (sponsor_id) REFERENCES users(id) ON DELETE SET NULL,
            FOREIGN KEY (parent_id) REFERENCES users(id) ON DELETE SET NULL,
            INDEX idx_sponsor (sponsor_id),
            INDEX idx_parent (parent_id)
        ) ENGINE=InnoDB
    ");
    echo "✓ genealogy table created\n\n";
    
    // 8. KYC Documents
    echo "Creating kyc_documents table...\n";
    $db->exec("
        CREATE TABLE IF NOT EXISTS kyc_documents (
            id INT AUTO_INCREMENT PRIMARY KEY,
            user_id INT NOT NULL,
            document_type ENUM('pan', 'aadhaar', 'passport', 'driving_license') NOT NULL,
            document_number VARCHAR(50) NOT NULL,
            document_image VARCHAR(255),
            status ENUM('pending', 'approved', 'rejected') DEFAULT 'pending',
            rejection_reason TEXT,
            verified_at TIMESTAMP NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
        ) ENGINE=InnoDB
    ");
    echo "✓ kyc_documents table created\n\n";
    
    // 9. Bank Details
    echo "Creating bank_details table...\n";
    $db->exec("
        CREATE TABLE IF NOT EXISTS bank_details (
            id INT AUTO_INCREMENT PRIMARY KEY,
            user_id INT UNIQUE NOT NULL,
            account_holder_name VARCHAR(255) NOT NULL,
            account_number VARCHAR(50) NOT NULL,
            ifsc_code VARCHAR(11) NOT NULL,
            bank_name VARCHAR(255) NOT NULL,
            branch_name VARCHAR(255),
            account_type VARCHAR(20) DEFAULT 'savings',
            upi_id VARCHAR(100),
            is_verified BOOLEAN DEFAULT FALSE,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
        ) ENGINE=InnoDB
    ");
    echo "✓ bank_details table created\n\n";
    
    // Re-enable foreign key checks
    $db->exec("SET FOREIGN_KEY_CHECKS = 1");
    
    // Add self-referencing foreign key to users table
    try {
        $db->exec("ALTER TABLE users ADD FOREIGN KEY (referred_by) REFERENCES users(id) ON DELETE SET NULL");
        echo "✓ Added foreign key constraint to users table\n\n";
    } catch (PDOException $e) {
        if (strpos($e->getMessage(), 'Duplicate') === false) {
            echo "Note: Foreign key constraint already exists\n\n";
        }
    }
    
    // Verify tables
    echo "========================================\n";
    echo "Verifying tables...\n";
    $stmt = $db->query("SHOW TABLES");
    $tables = $stmt->fetchAll(PDO::FETCH_COLUMN);
    
    echo "Found " . count($tables) . " tables:\n";
    foreach ($tables as $table) {
        echo "  ✓ $table\n";
    }
    
    echo "\n✅ Database setup complete!\n";
    
} catch (Exception $e) {
    echo "❌ Fatal Error: " . $e->getMessage() . "\n";
    exit(1);
}
