<?php
require_once __DIR__ . '/../../config/database.php';

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

$database = new Database();
$db = $database->getConnection();

$user_id = isset($_GET['user_id']) ? $_GET['user_id'] : null;

if (!$user_id) {
    http_response_code(400);
    echo json_encode(["message" => "User ID is required"]);
    exit;
}

$query = "SELECT * FROM payment_methods WHERE user_id = ? ORDER BY is_default DESC, id DESC";
$stmt = $db->prepare($query);
$stmt->execute([$user_id]);

$methods = [];
while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
    $methods[] = [
        "id" => (int)$row['id'],
        "type" => $row['type'],
        "lastFour" => $row['last_four'],
        "expiry" => $row['expiry'],
        "cardHolder" => $row['card_holder'],
        "isDefault" => (bool)$row['is_default']
    ];
}

http_response_code(200);
echo json_encode($methods);
?>
