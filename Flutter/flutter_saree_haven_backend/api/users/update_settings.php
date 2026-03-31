<?php
require_once __DIR__ . '/../../config/database.php';

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");

$database = new Database();
$db = $database->getConnection();

$data = json_decode(file_get_contents("php://input"));

$user_id = $data->user_id ?? null;

if (!$user_id) {
    http_response_code(400);
    echo json_encode(["success" => false, "message" => "User ID is required."]);
    exit();
}

$push_notifications = isset($data->push_notifications) ? ($data->push_notifications ? 1 : 0) : null;
$promotional_emails = isset($data->promotional_emails) ? ($data->promotional_emails ? 1 : 0) : null;
$dark_mode = isset($data->dark_mode) ? ($data->dark_mode ? 1 : 0) : null;

$query = "UPDATE user_settings SET ";
$params = [];

if ($push_notifications !== null) {
    $query .= "push_notifications = :push_notifications, ";
    $params[':push_notifications'] = $push_notifications;
}
if ($promotional_emails !== null) {
    $query .= "promotional_emails = :promotional_emails, ";
    $params[':promotional_emails'] = $promotional_emails;
}
if ($dark_mode !== null) {
    $query .= "dark_mode = :dark_mode, ";
    $params[':dark_mode'] = $dark_mode;
}

// Remove trailing comma
$query = rtrim($query, ", ");
$query .= " WHERE user_id = :user_id";
$params[':user_id'] = $user_id;

$stmt = $db->prepare($query);

if ($stmt->execute($params)) {
    echo json_encode(["success" => true, "message" => "Settings updated successfully."]);
} else {
    http_response_code(500);
    echo json_encode(["success" => false, "message" => "Failed to update settings."]);
}
?>
