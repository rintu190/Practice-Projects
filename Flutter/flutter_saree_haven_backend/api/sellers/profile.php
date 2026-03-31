<?php
require_once __DIR__ . '/../../config/database.php';

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

$database = new Database();
$db = $database->getConnection();

$id = isset($_GET['id']) ? $_GET['id'] : null;

if (!$id) {
    http_response_code(400);
    echo json_encode(["message" => "ID is required"]);
    exit;
}

// Fetch seller profile
$query = "SELECT * FROM sellers WHERE id = ? LIMIT 1";
$stmt = $db->prepare($query);
$stmt->execute([$id]);

if($stmt->rowCount() > 0){
    $row = $stmt->fetch(PDO::FETCH_ASSOC);
    
    // Calculate Dynamic Stats
    // 1. Total Orders
    $queryTotal = "SELECT COUNT(*) as total FROM orders WHERE seller_id = ?";
    $stmtTotal = $db->prepare($queryTotal);
    $stmtTotal->execute([$id]);
    $totalOrders = $stmtTotal->fetch(PDO::FETCH_ASSOC)['total'] ?? 0;

    // 2. Pending Orders
    $queryPending = "SELECT COUNT(*) as pending FROM orders WHERE seller_id = ? AND status = 'pending'";
    $stmtPending = $db->prepare($queryPending);
    $stmtPending->execute([$id]);
    $pendingOrders = $stmtPending->fetch(PDO::FETCH_ASSOC)['pending'] ?? 0;

    // 3. Total Earnings (excluding cancelled)
    $queryEarnings = "SELECT SUM(total_amount) as earnings FROM orders WHERE seller_id = ? AND status != 'cancelled'";
    $stmtEarnings = $db->prepare($queryEarnings);
    $stmtEarnings->execute([$id]);
    $totalEarnings = (float)($stmtEarnings->fetch(PDO::FETCH_ASSOC)['earnings'] ?? 0.0);

    // 4. Products Count
    $queryProducts = "SELECT COUNT(*) as count FROM sarees WHERE seller_id = ?";
    $stmtProducts = $db->prepare($queryProducts);
    $stmtProducts->execute([$id]);
    $totalProducts = $stmtProducts->fetch(PDO::FETCH_ASSOC)['count'] ?? 0;
    
    $seller_item = array(
        "id" => $row['id'],
        "storeName" => $row['store_name'],
        "ownerName" => $row['owner_name'],
        "location" => $row['location'],
        "imageUrl" => $row['image_url'],
        "bio" => $row['bio'],
        "rating" => (float)$row['rating'],
        "contactEmail" => $row['contact_email'],
        "mobileNumber" => $row['mobile_number'],
        "specialization" => $row['specialization'],
        "totalOrders" => $totalOrders,
        "pendingOrders" => $pendingOrders,
        "totalEarning" => $totalEarnings,
        "productCount" => $totalProducts // Adding product count for convenience
    );
    
    http_response_code(200);
    echo json_encode($seller_item);
} else {
    http_response_code(404);
    echo json_encode(["message" => "Seller not found."]);
}
