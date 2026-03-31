<?php
require_once __DIR__ . '/../../config/database.php';

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

$database = new Database();
$db = $database->getConnection();

$data = json_decode(file_get_contents("php://input"));

if (!$data || !isset($data->id) || !isset($data->user_id) || !isset($data->label) || !isset($data->details)) {
    http_response_code(400);
    echo json_encode(["message" => "Incomplete data"]);
    exit;
}

$db->beginTransaction();

if (isset($data->isDefault) && $data->isDefault == true) {
    // Reset all existing addresses for this user
    $query = "UPDATE shipping_addresses SET is_default = 0 WHERE user_id = ?";
    $stmt = $db->prepare($query);
    $stmt->execute([$data->user_id]);
}

$query = "UPDATE shipping_addresses SET label = ?, details = ?, is_default = ? WHERE id = ? AND user_id = ?";
$stmt = $db->prepare($query);
$isDefault = isset($data->isDefault) ? (int)$data->isDefault : 0;

if ($stmt->execute([$data->label, $data->details, $isDefault, (int)$data->id, $data->user_id])) {
    $db->commit();
    http_response_code(200);
    echo json_encode(["message" => "Address updated successfully"]);
} else {
    $db->rollBack();
    http_response_code(503);
    echo json_encode(["message" => "Unable to update address"]);
}
?>
