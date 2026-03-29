<?php
require_once __DIR__ . '/../../config/database.php';

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

$database = new Database();
$db = $database->getConnection();

$id = isset($_GET['id']) ? $_GET['id'] : null;

if (!$id) {
    http_response_code(400);
    echo json_encode(["message" => "ID is required"]);
    exit;
}

$query = "SELECT s.*, 
          a.name as artisan_name, a.location as artisan_location, a.image_url as artisan_image, a.rating as artisan_rating, a.bio as artisan_bio
          FROM sarees s
          LEFT JOIN artisans a ON s.artisan_id = a.id
          WHERE s.id = ? LIMIT 1";

$stmt = $db->prepare($query);
$stmt->execute([$id]);

if($stmt->rowCount() > 0){
    $row = $stmt->fetch(PDO::FETCH_ASSOC);
    
    $saree_item = array(
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
    );

    if ($row['artisan_id']) {
        $saree_item["artisan"] = array(
            "id" => $row['artisan_id'],
            "name" => $row['artisan_name'],
            "location" => $row['artisan_location'],
            "imageUrl" => $row['artisan_image'],
            "bio" => $row['artisan_bio'],
            "rating" => (float)$row['artisan_rating']
        );
    }
    
    http_response_code(200);
    echo json_encode($saree_item);
} else {
    http_response_code(404);
    echo json_encode(["message" => "Saree not found."]);
}
