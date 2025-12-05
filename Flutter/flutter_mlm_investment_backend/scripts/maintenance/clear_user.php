<?php
/**
 * Clear Test User Data
 * Use this to reset and test the registration flow again
 */

require_once __DIR__ . '/config/config.php';
require_once __DIR__ . '/config/database.php';

try {
    $db = Database::getInstance()->getConnection();
    
    echo "Enter phone number to delete (or 'all' to clear all test data): ";
    $input = trim(fgets(STDIN));
    
    if ($input === 'all') {
        echo "\nClearing all user data...\n";
        
        $db->exec("SET FOREIGN_KEY_CHECKS = 0");
        $db->exec("TRUNCATE TABLE genealogy");
        $db->exec("TRUNCATE TABLE user_investments");
        $db->exec("TRUNCATE TABLE transactions");
        $db->exec("TRUNCATE TABLE wallets");
        $db->exec("TRUNCATE TABLE bank_details");
        $db->exec("TRUNCATE TABLE kyc_documents");
        $db->exec("TRUNCATE TABLE user_profiles");
        $db->exec("TRUNCATE TABLE users");
        $db->exec("TRUNCATE TABLE otp_verifications");
        $db->exec("SET FOREIGN_KEY_CHECKS = 1");
        
        echo "✅ All user data cleared!\n";
    } else {
        echo "\nDeleting user with phone: $input\n";
        
        // Get user ID
        $stmt = $db->prepare("SELECT id FROM users WHERE phone = ?");
        $stmt->execute([$input]);
        $user = $stmt->fetch();
        
        if (!$user) {
            echo "❌ User not found!\n";
            exit(1);
        }
        
        $userId = $user['id'];
        
        // Delete related data (foreign keys will cascade most of it)
        $db->prepare("DELETE FROM users WHERE id = ?")->execute([$userId]);
        $db->prepare("DELETE FROM otp_verifications WHERE phone = ?")->execute([$input]);
        
        echo "✅ User deleted successfully!\n";
    }
    
    echo "\nYou can now test the registration flow again.\n";
    
} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
