<?php
require_once __DIR__ . '/../../config/database.php';

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

$database = new Database();
$db = $database->getConnection();

$userId = $_GET['user_id'] ?? null;

if (!$userId) {
    echo json_encode(["status" => "error", "message" => "User ID is required"]);
    exit;
}

// In a real app, these would be separate tables. For now, we'll mock them or count them.
// Let's assume we have orders and wishlist tables eventually. 
// For this demo, let's return some realistic values or count from existing tables if they exist.

$stats = [
    "ordersCount" => 0,
    "wishlistCount" => 0,
    "walletBalance" => 0
];

try {
    // Orders count
    $orderStmt = $db->prepare("SELECT COUNT(*) as count FROM orders WHERE customer_id = ?");
    $orderStmt->execute([$userId]);
    $stats['ordersCount'] = (int)$orderStmt->fetch(PDO::FETCH_ASSOC)['count'];

    // Wishlist count
    $wishStmt = $db->prepare("SELECT COUNT(*) as count FROM wishlists WHERE user_id = ?");
    $wishStmt->execute([$userId]);
    $stats['wishlistCount'] = (int)$wishStmt->fetch(PDO::FETCH_ASSOC)['count'];

    // Wallet balance = Total lifetime order amount
    $walletStmt = $db->prepare("SELECT SUM(total_amount) as total FROM orders WHERE customer_id = ?");
    $walletStmt->execute([$userId]);
    $totalAmount = $walletStmt->fetch(PDO::FETCH_ASSOC)['total'];
    $stats['walletBalance'] = (double)($totalAmount ?? 0);

    echo json_encode([
        "status" => "success",
        "data" => $stats
    ]);

} catch (PDOException $e) {
    echo json_encode(["status" => "error", "message" => $e->getMessage()]);
}
?>
