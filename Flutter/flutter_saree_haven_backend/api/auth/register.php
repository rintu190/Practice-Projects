<?php
require_once __DIR__ . '/../../config/database.php';

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");

$database = new Database();
$db = $database->getConnection();

$data = json_decode(file_get_contents("php://input"));

if (!empty($data->name) && !empty($data->email) && !empty($data->password)) {
    $role = isset($data->role) ? $data->role : 'customer';
    
    // Check if email exists
    $checkQuery = "SELECT id FROM users WHERE email = ? LIMIT 1";
    $checkStmt = $db->prepare($checkQuery);
    $checkStmt->execute([$data->email]);
    
    if ($checkStmt->rowCount() > 0) {
        http_response_code(400);
        echo json_encode(array("message" => "Email already exists.", "success" => false));
        exit;
    }

    $query = "INSERT INTO users (id, name, email, password_hash, role) VALUES (:id, :name, :email, :password, :role)";
    $stmt = $db->prepare($query);

    $id = uniqid('user_');
    $password_hash = password_hash($data->password, PASSWORD_BCRYPT);

    $stmt->bindParam(':id', $id);
    $stmt->bindParam(':name', $data->name);
    $stmt->bindParam(':email', $data->email);
    $stmt->bindParam(':password', $password_hash);
    $stmt->bindParam(':role', $role);

    if($stmt->execute()){
        http_response_code(201);
        echo json_encode(array(
            "message" => "User was created.",
            "success" => true,
            "user" => array(
                "id" => $id,
                "name" => $data->name,
                "email" => $data->email,
                "role" => $role
            )
        ));
    } else {
        http_response_code(503);
        echo json_encode(array("message" => "Unable to create user.", "success" => false));
    }
} else {
    http_response_code(400);
    echo json_encode(array("message" => "Incomplete data.", "success" => false));
}
