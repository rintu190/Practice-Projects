<?php
require_once __DIR__ . '/../../config/database.php';

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");

$database = new Database();
$db = $database->getConnection();

// Extract data from POST (Multipart)
$name = $_POST['name'] ?? null;
$email = $_POST['email'] ?? null;
$password = $_POST['password'] ?? null;
$role = $_POST['role'] ?? 'customer';
$phone = $_POST['phone'] ?? '';
$storeName = $_POST['store_name'] ?? null;

if (!empty($name) && !empty($email) && !empty($password)) {
    
    // Check if email exists
    $checkQuery = "SELECT id FROM users WHERE email = ? LIMIT 1";
    $checkStmt = $db->prepare($checkQuery);
    $checkStmt->execute([$email]);
    
    if ($checkStmt->rowCount() > 0) {
        http_response_code(400);
        echo json_encode(array("message" => "Email already exists.", "success" => false));
        exit;
    }

    $query = "INSERT INTO users (id, name, email, password_hash, role) VALUES (:id, :name, :email, :password, :role)";
    $stmt = $db->prepare($query);

    $userId = uniqid('user_');
    $password_hash = password_hash($password, PASSWORD_BCRYPT);

    $stmt->bindParam(':id', $userId);
    $stmt->bindParam(':name', $name);
    $stmt->bindParam(':email', $email);
    $stmt->bindParam(':password', $password_hash);
    $stmt->bindParam(':role', $role);

    if($stmt->execute()){
        // If it's a seller, create a seller profile record
        if ($role === 'seller') {
            $sellerId = uniqid('seller_');
            $finalStoreName = $storeName ? $storeName : $name . "'s Store";
            
            // Handle Image Upload if present
            $imageUrl = null;
            if (isset($_FILES['image']) && $_FILES['image']['error'] === UPLOAD_ERR_OK) {
                $uploadDir = __DIR__ . '/../../uploads/';
                if (!is_dir($uploadDir)) mkdir($uploadDir, 0755, true);
                
                $fileExtension = strtolower(pathinfo($_FILES['image']['name'], PATHINFO_EXTENSION));
                $newFileName = uniqid('store_') . '.' . $fileExtension;
                if (move_uploaded_file($_FILES['image']['tmp_name'], $uploadDir . $newFileName)) {
                    $protocol = isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] === 'on' ? "https" : "http";
                    $requestUri = explode('/api/', $_SERVER['REQUEST_URI'])[0] ?? '';
                    $imageUrl = $protocol . "://" . $_SERVER['HTTP_HOST'] . $requestUri . "/uploads/" . $newFileName;
                }
            }

            $sellerQuery = "INSERT INTO sellers (id, user_id, store_name, owner_name, location, contact_email, mobile_number, image_url) 
                            VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
            $sellerStmt = $db->prepare($sellerQuery);
            $sellerStmt->execute([$sellerId, $userId, $finalStoreName, $name, 'Not specified', $email, $phone, $imageUrl]);
        }

        http_response_code(201);
        echo json_encode(array(
            "message" => "User was created.",
            "success" => true,
            "user" => array(
                "id" => $userId,
                "name" => $name,
                "email" => $email,
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
