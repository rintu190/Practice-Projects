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

$query = "SELECT * FROM sellers WHERE id = ? LIMIT 1";

$stmt = $db->prepare($query);
$stmt->execute([$id]);

if($stmt->rowCount() > 0){
    $row = $stmt->fetch(PDO::FETCH_ASSOC);
    
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
        "totalOrders" => (int)$row['total_orders'],
        "pendingOrders" => (int)$row['pending_orders'],
        "totalEarning" => (float)$row['total_earning']
    );
    
    http_response_code(200);
    echo json_encode($seller_item);
} else {
    http_response_code(404);
    echo json_encode(["message" => "Seller not found."]);
}
