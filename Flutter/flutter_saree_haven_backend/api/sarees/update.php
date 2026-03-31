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

// Since we may be sending files, we use POST even for updates
$id = $_POST['id'] ?? '';
$name = $_POST['name'] ?? '';
$description = $_POST['description'] ?? '';
$price = $_POST['price'] ?? '';
$category = $_POST['category'] ?? '';
$type = $_POST['type'] ?? '';
$sellerId = $_POST['sellerId'] ?? '';
$artisanId = $_POST['artisanId'] ?? null;
$inStock = isset($_POST['inStock']) ? filter_var($_POST['inStock'], FILTER_VALIDATE_BOOLEAN) : true;
$isCustomizable = isset($_POST['isCustomizable']) ? filter_var($_POST['isCustomizable'], FILTER_VALIDATE_BOOLEAN) : false;

if (empty($id)) {
    http_response_code(400);
    echo json_encode(["success" => false, "message" => "Saree ID is required."]);
    exit();
}

// Fetch current saree to keep existing images if no new one provided
$getSaree = "SELECT image_urls FROM sarees WHERE id = :id";
$stmtSaree = $db->prepare($getSaree);
$stmtSaree->bindParam(':id', $id);
$stmtSaree->execute();
$currentSaree = $stmtSaree->fetch(PDO::FETCH_ASSOC);

if (!$currentSaree) {
    http_response_code(404);
    echo json_encode(["success" => false, "message" => "Saree not found."]);
    exit();
}

$imageUrlsArr = json_decode($currentSaree['image_urls'], true) ?? [];

// Handle New File Upload if present
// Handle New File Upload if present
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

        // Delete old images from server if they exist
        foreach ($imageUrlsArr as $oldUrl) {
            if (strpos($oldUrl, '/uploads/') !== false) {
                $oldPathParts = explode('/uploads/', $oldUrl);
                if (isset($oldPathParts[1])) {
                    $oldFile = __DIR__ . '/../../uploads/' . $oldPathParts[1];
                    if (file_exists($oldFile)) unlink($oldFile);
                }
            }
        }

        $protocol = isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] === 'on' ? "https" : "http";
        $requestUri = explode('/api/', $_SERVER['REQUEST_URI'])[0] ?? '';
        $imageUrlsArr = [$protocol . "://" . $_SERVER['HTTP_HOST'] . $requestUri . "/uploads/sarees/" . $newFileName];
    }
} else if (isset($_POST['imageUrls'])) {
    // If imageUrls is explicitly passed (e.g. for mock data update)
    $imageUrlsArr = json_decode($_POST['imageUrls'], true) ?? [$_POST['imageUrls']];
}

if (!empty($name) && !empty($description) && !empty($price) && !empty($category) && !empty($type)) {
    $imageUrlsJson = json_encode($imageUrlsArr);

    $query = "UPDATE sarees 
              SET name = :name, 
                  description = :description, 
                  price = :price, 
                  category = :category, 
                  type = :type, 
                  image_urls = :image_urls, 
                  artisan_id = :artisan_id, 
                  in_stock = :in_stock, 
                  is_customizable = :is_customizable 
              WHERE id = :id";

    $stmt = $db->prepare($query);
    $stmt->bindParam(':id', $id);
    $stmt->bindParam(':name', $name);
    $stmt->bindParam(':description', $description);
    $stmt->bindParam(':price', $price);
    $stmt->bindParam(':category', $category);
    $stmt->bindParam(':type', $type);
    $stmt->bindParam(':image_urls', $imageUrlsJson);
    $stmt->bindParam(':artisan_id', $artisanId);
    $stmt->bindParam(':in_stock', $inStock, PDO::PARAM_BOOL);
    $stmt->bindParam(':is_customizable', $isCustomizable, PDO::PARAM_BOOL);

    if ($stmt->execute()) {
        http_response_code(200);
        echo json_encode(["success" => true, "message" => "Saree updated successfully."]);
    } else {
        http_response_code(503);
        echo json_encode(["success" => false, "message" => "Unable to update saree listing."]);
    }
} else {
    http_response_code(400);
    echo json_encode(["success" => false, "message" => "Incomplete data."]);
}
?>
