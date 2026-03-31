<?php
require_once __DIR__ . '/../../config/database.php';

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: GET, OPTIONS");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

$database = new Database();
$db = $database->getConnection();

$userId = isset($_GET['user_id']) ? $_GET['user_id'] : null;

if (!$userId) {
    http_response_code(400);
    echo json_encode(["message" => "User ID is required"]);
    exit;
}

$query = "SELECT * FROM sellers WHERE user_id = ? LIMIT 1";
$stmt = $db->prepare($query);
$stmt->execute([$userId]);

if ($stmt->rowCount() > 0) {
    $row = $stmt->fetch(PDO::FETCH_ASSOC);
    http_response_code(200);
    echo json_encode([
        "id"             => $row['id'],
        "storeName"      => $row['store_name'],
        "ownerName"      => $row['owner_name'],
        "location"       => $row['location'],
        "imageUrl"       => $row['image_url'],
        "bio"            => $row['bio'],
        "rating"         => (float)$row['rating'],
        "contactEmail"   => $row['contact_email'],
        "mobileNumber"   => $row['mobile_number'],
        "specialization" => $row['specialization'],
        "totalOrders"    => (int)$row['total_orders'],
        "pendingOrders"  => (int)$row['pending_orders'],
        "totalEarning"   => (float)$row['total_earning'],
    ]);
} else {
    // 404 means: user is a seller but has no seller record yet
    http_response_code(404);
    echo json_encode(["message" => "No seller profile found for this user."]);
}
