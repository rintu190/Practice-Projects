<?php
require_once __DIR__ . '/../../config/database.php';

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");

$database = new Database();
$db = $database->getConnection();

$data = json_decode(file_get_contents("php://input"));

if (!empty($data->email) && !empty($data->password)) {
    $query = "SELECT id, name, email, password_hash, role FROM users WHERE email = ? LIMIT 1";
    $stmt = $db->prepare($query);
    $stmt->execute([$data->email]);

    if($stmt->rowCount() > 0) {
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        if (password_verify($data->password, $row['password_hash'])) {
            http_response_code(200);
            echo json_encode(array(
                "message" => "Login successful.",
                "success" => true,
                "user" => array(
                    "id" => $row['id'],
                    "name" => $row['name'],
                    "email" => $row['email'],
                    "role" => $row['role']
                )
            ));
        } else {
            http_response_code(401);
            echo json_encode(array("message" => "Invalid credentials.", "success" => false));
        }
    } else {
        http_response_code(401);
        echo json_encode(array("message" => "Invalid credentials.", "success" => false));
    }
} else {
    http_response_code(400);
    echo json_encode(array("message" => "Incomplete data.", "success" => false));
}
