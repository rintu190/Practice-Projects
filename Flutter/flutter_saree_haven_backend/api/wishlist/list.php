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

$query = "SELECT s.*, 
          a.name as artisan_name, a.location as artisan_location, a.image_url as artisan_image, a.rating as artisan_rating
          FROM sarees s 
          JOIN wishlists w ON s.id = w.saree_id 
          LEFT JOIN artisans a ON s.artisan_id = a.id
          WHERE w.user_id = ? 
          ORDER BY w.created_at DESC";
$stmt = $db->prepare($query);
$stmt->execute([$user_id]);

$sarees = [];
while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
    $saree = [
        "id" => $row['id'],
        "name" => $row['name'],
        "description" => $row['description'],
        "price" => (float)$row['price'],
        "category" => $row['category'],
        "type" => $row['type'],
        "imageUrls" => json_decode($row['image_urls'], true) ?? [],
        "sellerId" => $row['seller_id'],
        "inStock" => (bool)$row['in_stock'],
        "isCustomizable" => (bool)$row['is_customizable'],
        "artisan" => null
    ];
    if ($row['artisan_id']) {
        $saree["artisan"] = [
            "id" => $row['artisan_id'],
            "name" => $row['artisan_name'],
            "location" => $row['artisan_location'],
            "imageUrl" => $row['artisan_image'],
            "bio" => null,
            "rating" => (float)$row['artisan_rating']
        ];
    }
    $sarees[] = $saree;
}

http_response_code(200);
echo json_encode($sarees);
?>
