<?php
require_once 'config/database.php';

$db = Database::getInstance();
$conn = $db->getConnection();

echo "=== Recalculating Total Earned for All Users ===\n\n";

try {
    $conn->beginTransaction();
    
    // Get all users
    $usersStmt = $conn->query("SELECT id FROM users");
    $users = $usersStmt->fetchAll(PDO::FETCH_COLUMN);
    
    foreach ($users as $userId) {
        // Calculate total commissions
        $commStmt = $conn->prepare("
            SELECT COALESCE(SUM(amount), 0) as total 
            FROM commissions 
            WHERE user_id = ? AND status = 'paid'
        ");
        $commStmt->execute([$userId]);
        $totalCommissions = $commStmt->fetchColumn();
        
        // Calculate total investment profits
        $profitStmt = $conn->prepare("
            SELECT COALESCE(SUM(amount), 0) as total 
            FROM investment_profits 
            WHERE user_id = ?
        ");
        $profitStmt->execute([$userId]);
        $totalProfits = $profitStmt->fetchColumn();
        
        // Total earned = commissions + investment profits
        $totalEarned = $totalCommissions + $totalProfits;
        
        // Update wallet
        $updateStmt = $conn->prepare("
            UPDATE wallets 
            SET total_earned = ? 
            WHERE user_id = ?
        ");
        $updateStmt->execute([$totalEarned, $userId]);
        
        echo "User $userId: Total Earned = ₹$totalEarned (Commissions: ₹$totalCommissions + Profits: ₹$totalProfits)\n";
    }
    
    $conn->commit();
    echo "\n✅ Successfully recalculated total_earned for all users!\n";
    
} catch (Exception $e) {
    $conn->rollBack();
    echo "❌ Error: " . $e->getMessage() . "\n";
}
