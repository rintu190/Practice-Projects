<?php
require_once __DIR__ . '/../../config/database.php';

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: PUT, POST");

$database = new Database();
$db = $database->getConnection();

$data = json_decode(file_get_contents("php://input"));

if (!empty($data->id) && !empty($data->status)) {
    $query = "UPDATE orders SET status = :status WHERE id = :id";
    $stmt = $db->prepare($query);

    $stmt->bindParam(':status', $data->status);
    $stmt->bindParam(':id', $data->id);

    if($stmt->execute()){
        http_response_code(200);
        echo json_encode(array("message" => "Order status updated.", "success" => true));
    } else {
        http_response_code(503);
        echo json_encode(array("message" => "Unable to update order status.", "success" => false));
    }
} else {
    http_response_code(400);
    echo json_encode(array("message" => "Incomplete data.", "success" => false));
}
