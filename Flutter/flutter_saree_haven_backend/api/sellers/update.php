<?php
require_once __DIR__ . '/../../config/database.php';

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

$database = new Database();
$db = $database->getConnection();

// Get data from POST (supporting both JSON and multipart/form-data)
$data = json_decode(file_get_contents("php://input"));

$id = $_POST['id'] ?? ($data->id ?? null);
$storeName = $_POST['storeName'] ?? ($data->storeName ?? null);
$ownerName = $_POST['ownerName'] ?? ($data->ownerName ?? null);
$location = $_POST['location'] ?? ($data->location ?? null);
$bio = $_POST['bio'] ?? ($data->bio ?? null);
$mobileNumber = $_POST['mobileNumber'] ?? ($data->mobileNumber ?? null);
$specialization = $_POST['specialization'] ?? ($data->specialization ?? null);

if (!$id) {
    http_response_code(400);
    echo json_encode(["success" => false, "message" => "Seller ID is required."]);
    exit();
}

// Fetch current values to avoid overwriting with nulls if not provided in request
$currentQuery = "SELECT * FROM sellers WHERE id = ?";
$currentStmt = $db->prepare($currentQuery);
$currentStmt->execute([$id]);
$current = $currentStmt->fetch(PDO::FETCH_ASSOC);

if (!$current) {
    http_response_code(404);
    echo json_encode(["success" => false, "message" => "Seller not found."]);
    exit();
}

// Handle Image Upload if present
$imageUrl = $current['image_url'];
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

$query = "UPDATE sellers 
          SET store_name = :storeName, 
              owner_name = :ownerName, 
              location = :location, 
              bio = :bio, 
              mobile_number = :mobileNumber, 
              specialization = :specialization,
              image_url = :imageUrl
          WHERE id = :id";

$stmt = $db->prepare($query);
$stmt->bindValue(':id', $id);
$stmt->bindValue(':storeName', $storeName ?? $current['store_name']);
$stmt->bindValue(':ownerName', $ownerName ?? $current['owner_name']);
$stmt->bindValue(':location', $location ?? $current['location']);
$stmt->bindValue(':bio', $bio ?? $current['bio']);
$stmt->bindValue(':mobileNumber', $mobileNumber ?? $current['mobile_number']);
$stmt->bindValue(':specialization', $specialization ?? $current['specialization']);
$stmt->bindValue(':imageUrl', $imageUrl);

if ($stmt->execute()) {
    http_response_code(200);
    echo json_encode([
        "success" => true, 
        "message" => "Seller profile updated successfully.",
        "imageUrl" => $imageUrl
    ]);
} else {
    http_response_code(503);
    echo json_encode(["success" => false, "message" => "Unable to update seller profile."]);
}
?>
