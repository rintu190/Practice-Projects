<?php
require_once __DIR__ . '/../../config/database.php';

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

$database = new Database();
$db = $database->getConnection();

$user_id = isset($_GET['user_id']) ? $_GET['user_id'] : null;
$saree_id = isset($_GET['saree_id']) ? $_GET['saree_id'] : null;

if (!$user_id || !$saree_id) {
    http_response_code(400);
    echo json_encode(["message" => "User ID and Saree ID are required"]);
    exit;
}

$query = "SELECT id FROM wishlists WHERE user_id = ? AND saree_id = ?";
$stmt = $db->prepare($query);
$stmt->execute([$user_id, $saree_id]);

if ($stmt->rowCount() > 0) {
    echo json_encode(["in_wishlist" => true]);
} else {
    echo json_encode(["in_wishlist" => false]);
}
?>
