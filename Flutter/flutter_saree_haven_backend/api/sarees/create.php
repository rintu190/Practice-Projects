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

$name = $_POST['name'] ?? '';
$description = $_POST['description'] ?? '';
$price = $_POST['price'] ?? '';
$category = $_POST['category'] ?? '';
$type = $_POST['type'] ?? '';
$sellerId = $_POST['sellerId'] ?? '';
$artisanId = $_POST['artisanId'] ?? null;
$inStock = isset($_POST['inStock']) ? filter_var($_POST['inStock'], FILTER_VALIDATE_BOOLEAN) : true;
$isCustomizable = isset($_POST['isCustomizable']) ? filter_var($_POST['isCustomizable'], FILTER_VALIDATE_BOOLEAN) : false;

$imageUrlsArr = [];

// Handle File Upload
// Handle File Upload
if (isset($_FILES['image']) && $_FILES['image']['error'] === UPLOAD_ERR_OK) {
    $uploadDir = __DIR__ . '/../../uploads/sarees/';
    if (!is_dir($uploadDir)) mkdir($uploadDir, 0755, true);
    
    $newFileName = uniqid('saree_') . '.jpg';
    $targetFile = $uploadDir . $newFileName;

    // Compress and save
    $source = $_FILES['image']['tmp_name'];
    $info = getimagesize($source);
    if ($info['mime'] == 'image/jpeg') $image = imagecreatefromjpeg($source);
    elseif ($info['mime'] == 'image/gif') $image = imagecreatefromgif($source);
    elseif ($info['mime'] == 'image/png') $image = imagecreatefrompng($source);
    elseif ($info['mime'] == 'image/webp') $image = imagecreatefromwebp($source);

    if (isset($image)) {
        imagejpeg($image, $targetFile, 75);
        imagedestroy($image);

        $protocol = isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] === 'on' ? "https" : "http";
        $requestUri = explode('/api/', $_SERVER['REQUEST_URI'])[0] ?? '';
        $imageUrlsArr = [$protocol . "://" . $_SERVER['HTTP_HOST'] . $requestUri . "/uploads/sarees/" . $newFileName];
    }
} else if (!empty($_POST['imageUrls'])) {
    // Fallback if URL is passed as form data string
    $imageUrlsArr = json_decode($_POST['imageUrls'], true) ?? [$_POST['imageUrls']];
} else {
    // Default mock image if no file and no URL passed
    $imageUrlsArr = ['https://images.unsplash.com/photo-1610030469983-98e550d6193c?auto=format&fit=crop&q=80&w=800'];
}

if (!empty($name) && !empty($description) && !empty($price) && !empty($category) && !empty($type) && !empty($sellerId)) {
    $id = 's' . uniqid();
    $imageUrlsJson = json_encode($imageUrlsArr);

    $query = "INSERT INTO sarees (id, name, description, price, category, type, image_urls, artisan_id, seller_id, in_stock, is_customizable)
              VALUES (:id, :name, :description, :price, :category, :type, :image_urls, :artisan_id, :seller_id, :in_stock, :is_customizable)";

    $stmt = $db->prepare($query);
    $stmt->bindParam(':id', $id);
    $stmt->bindParam(':name', $name);
    $stmt->bindParam(':description', $description);
    $stmt->bindParam(':price', $price);
    $stmt->bindParam(':category', $category);
    $stmt->bindParam(':type', $type);
    $stmt->bindParam(':image_urls', $imageUrlsJson);
    $stmt->bindParam(':artisan_id', $artisanId);
    $stmt->bindParam(':seller_id', $sellerId);
    $stmt->bindParam(':in_stock', $inStock, PDO::PARAM_BOOL);
    $stmt->bindParam(':is_customizable', $isCustomizable, PDO::PARAM_BOOL);

    if ($stmt->execute()) {
        http_response_code(201);
        echo json_encode(["success" => true, "message" => "Saree listed successfully.", "id" => $id]);
    } else {
        http_response_code(503);
        echo json_encode(["success" => false, "message" => "Unable to create saree listing."]);
    }
} else {
    http_response_code(400);
    echo json_encode(["success" => false, "message" => "Incomplete data. Required: name, description, price, category, type, sellerId."]);
}
