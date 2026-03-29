<?php
require_once __DIR__ . '/../../config/database.php';

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

$database = new Database();
$db = $database->getConnection();

$query = "SELECT * FROM sellers";
$stmt = $db->prepare($query);
$stmt->execute();

$sellers_arr = array();

while ($row = $stmt->fetch(PDO::FETCH_ASSOC)){
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
    array_push($sellers_arr, $seller_item);
}

http_response_code(200);
echo json_encode($sellers_arr);
