<?php
require_once __DIR__ . '/../../config/database.php';

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

$database = new Database();
$db = $database->getConnection();

$data = json_decode(file_get_contents("php://input"));

if (!$data || !isset($data->user_id) || !isset($data->label) || !isset($data->details)) {
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

$query = "INSERT INTO shipping_addresses (user_id, label, details, is_default) VALUES (?, ?, ?, ?)";
$stmt = $db->prepare($query);
$isDefault = isset($data->isDefault) ? (int)$data->isDefault : 0;

if ($stmt->execute([$data->user_id, $data->label, $data->details, $isDefault])) {
    $db->commit();
    http_response_code(201);
    echo json_encode(["message" => "Address added successfully", "id" => $db->lastInsertId()]);
} else {
    $db->rollBack();
    http_response_code(503);
    echo json_encode(["message" => "Unable to add address"]);
}
?>
