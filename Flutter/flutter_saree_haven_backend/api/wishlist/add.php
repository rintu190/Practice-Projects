<?php
require_once __DIR__ . '/../../config/database.php';

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

$database = new Database();
$db = $database->getConnection();

$data = json_decode(file_get_contents("php://input"));

if (!$data || !isset($data->user_id) || !isset($data->saree_id)) {
    http_response_code(400);
    echo json_encode(["message" => "Incomplete data"]);
    exit;
}

// Check if already in wishlist
$check = "SELECT id FROM wishlists WHERE user_id = ? AND saree_id = ?";
$stmt_check = $db->prepare($check);
$stmt_check->execute([$data->user_id, $data->saree_id]);

if ($stmt_check->rowCount() > 0) {
    http_response_code(200);
    echo json_encode(["message" => "Already in wishlist", "id" => $stmt_check->fetchColumn()]);
    exit;
}

$query = "INSERT INTO wishlists (user_id, saree_id) VALUES (?, ?)";
$stmt = $db->prepare($query);

if ($stmt->execute([$data->user_id, $data->saree_id])) {
    http_response_code(201);
    echo json_encode(["message" => "Added to wishlist successfully", "id" => $db->lastInsertId()]);
} else {
    http_response_code(503);
    echo json_encode(["message" => "Unable to add to wishlist"]);
}
?>
