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

$query = "DELETE FROM wishlists WHERE user_id = ? AND saree_id = ?";
$stmt = $db->prepare($query);

if ($stmt->execute([$data->user_id, $data->saree_id])) {
    http_response_code(200);
    echo json_encode(["message" => "Removed from wishlist successfully"]);
} else {
    http_response_code(503);
    echo json_encode(["message" => "Unable to remove from wishlist"]);
}
?>
