<?php
require_once __DIR__ . '/../../config/database.php';

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

$database = new Database();
$db = $database->getConnection();

$user_id = $_GET['user_id'] ?? null;

if (!$user_id) {
    http_response_code(400);
    echo json_encode(["success" => false, "message" => "User ID is required."]);
    exit();
}

$query = "SELECT * FROM user_settings WHERE user_id = ?";
$stmt = $db->prepare($query);
$stmt->execute([$user_id]);

if ($stmt->rowCount() > 0) {
    echo json_encode(["success" => true, "settings" => $stmt->fetch(PDO::FETCH_ASSOC)]);
} else {
    // Create default settings if not exists
    $insertQuery = "INSERT INTO user_settings (user_id) VALUES (?)";
    $insertStmt = $db->prepare($insertQuery);
    $insertStmt->execute([$user_id]);
    
    echo json_encode([
        "success" => true,
        "settings" => [
            "user_id" => $user_id,
            "push_notifications" => 1,
            "promotional_emails" => 0,
            "dark_mode" => 0
        ]
    ]);
}
?>
