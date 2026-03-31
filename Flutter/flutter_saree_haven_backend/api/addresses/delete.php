<?php
require_once __DIR__ . '/../../config/database.php';

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

$database = new Database();
$db = $database->getConnection();

$data = json_decode(file_get_contents("php://input"));

if (!$data || !isset($data->id) || !isset($data->user_id)) {
    http_response_code(400);
    echo json_encode(["message" => "Incomplete data"]);
    exit;
}

$query = "DELETE FROM shipping_addresses WHERE id = ? AND user_id = ?";
$stmt = $db->prepare($query);

if ($stmt->execute([(int)$data->id, $data->user_id])) {
    http_response_code(200);
    echo json_encode(["message" => "Address deleted successfully"]);
} else {
    http_response_code(503);
    echo json_encode(["message" => "Unable to delete address"]);
}
?>
