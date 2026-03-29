<?php
require_once __DIR__ . '/../../config/database.php';

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

$database = new Database();
$db = $database->getConnection();

$category = isset($_GET['category']) ? $_GET['category'] : null;
$type = isset($_GET['type']) ? $_GET['type'] : null;
$sellerId = isset($_GET['seller_id']) ? $_GET['seller_id'] : null;

$query = "SELECT s.*, 
          a.name as artisan_name, a.location as artisan_location, a.image_url as artisan_image, a.rating as artisan_rating,
          sl.store_name, sl.owner_name, sl.rating as seller_rating 
          FROM sarees s
          LEFT JOIN artisans a ON s.artisan_id = a.id
          LEFT JOIN sellers sl ON s.seller_id = sl.id
          WHERE 1=1";

$params = [];

if ($category && $category !== 'All') {
    $query .= " AND s.category = ?";
    $params[] = $category;
}
if ($type && $type !== 'All') {
    $query .= " AND s.type = ?";
    $params[] = $type;
}
if ($sellerId) {
    $query .= " AND s.seller_id = ?";
    $params[] = $sellerId;
}

$stmt = $db->prepare($query);
$stmt->execute($params);
$num = $stmt->rowCount();

if($num > 0){
    $sarees_arr = array();
    
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)){
        // Format to match Flutter model exactly
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
                "bio" => null,
                "rating" => (float)$row['artisan_rating']
            );
        }

        array_push($sarees_arr, $saree_item);
    }
    
    http_response_code(200);
    echo json_encode($sarees_arr);
} else {
    http_response_code(200);
    echo json_encode(array());
}
