<?php
error_reporting(0);
ini_set('display_errors', 0);
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

// Get data from POST
$data = json_decode(file_get_contents("php://input"));

$id = $_POST['id'] ?? ($data->id ?? null);
$name = $_POST['name'] ?? ($data->name ?? null);
$email = $_POST['email'] ?? ($data->email ?? null);

if (!$id) {
    http_response_code(400);
    echo json_encode(["success" => false, "message" => "User ID is required."]);
    exit();
}

$currentQuery = "SELECT * FROM users WHERE id = ?";
$currentStmt = $db->prepare($currentQuery);
$currentStmt->execute([$id]);
$current = $currentStmt->fetch(PDO::FETCH_ASSOC);

if (!$current) {
    http_response_code(404);
    echo json_encode(["success" => false, "message" => "User not found."]);
    exit();
}

$phone = $_POST['phone'] ?? ($data->phone ?? $current['phone']);

// Handle Image Upload
$imageUrl = $current['image_url'];
// Handle Image Upload
$imageUrl = $current['image_url'];
if (isset($_FILES['image']) && $_FILES['image']['error'] === UPLOAD_ERR_OK) {
    $uploadDir = __DIR__ . '/../../uploads/profile/';
    if (!is_dir($uploadDir)) mkdir($uploadDir, 0755, true);
    
    $fileExtension = strtolower(pathinfo($_FILES['image']['name'], PATHINFO_EXTENSION));
    $newFileName = uniqid('profile_') . '.jpg'; // Store all as jpg for consistency
    $targetFile = $uploadDir . $newFileName;

    // Compress and save
    $source = $_FILES['image']['tmp_name'];
    $info = getimagesize($source);
    if ($info['mime'] == 'image/jpeg') $image = imagecreatefromjpeg($source);
    elseif ($info['mime'] == 'image/gif') $image = imagecreatefromgif($source);
    elseif ($info['mime'] == 'image/png') $image = imagecreatefrompng($source);
    elseif ($info['mime'] == 'image/webp') $image = imagecreatefromwebp($source);

    if (isset($image)) {
        // Resize if needed or just compress
        imagejpeg($image, $targetFile, 75); // 75% quality
        imagedestroy($image);
        
        // Delete old image if it exists and is not a default
        if ($current['image_url']) {
            $oldPath = str_replace(['http://', 'https://'], '', $current['image_url']);
            $oldPathParts = explode('/uploads/', $oldPath);
            if (isset($oldPathParts[1])) {
                $oldFile = __DIR__ . '/../../uploads/' . $oldPathParts[1];
                if (file_exists($oldFile)) unlink($oldFile);
            }
        }

        $protocol = isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] === 'on' ? "https" : "http";
        $requestUri = explode('/api/', $_SERVER['REQUEST_URI'])[0] ?? '';
        $imageUrl = $protocol . "://" . $_SERVER['HTTP_HOST'] . $requestUri . "/uploads/profile/" . $newFileName;
    }
}

// Check if email is already taken
if ($email && $email !== $current['email']) {
    $checkStmt = $db->prepare("SELECT id FROM users WHERE email = ? AND id != ?");
    $checkStmt->execute([$email, $id]);
    if ($checkStmt->rowCount() > 0) {
        http_response_code(400);
        echo json_encode(["success" => false, "message" => "Email already in use."]);
        exit();
    }
}

$query = "UPDATE users SET name = :name, email = :email, phone = :phone, image_url = :imageUrl WHERE id = :id";
$stmt = $db->prepare($query);
$stmt->bindValue(':id', $id);
$stmt->bindValue(':name', $name ?? $current['name']);
$stmt->bindValue(':email', $email ?? $current['email']);
$stmt->bindValue(':phone', $phone);
$stmt->bindValue(':imageUrl', $imageUrl);

if ($stmt->execute()) {
    http_response_code(200);
    echo json_encode([
        "success" => true, 
        "message" => "Profile updated successfully.",
        "imageUrl" => $imageUrl
    ]);
} else {
    http_response_code(503);
    echo json_encode(["success" => false, "message" => "Unable to update user profile."]);
}
?>
