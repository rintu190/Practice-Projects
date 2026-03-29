<?php
require_once __DIR__ . '/../../config/database.php';

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

$database = new Database();
$db = $database->getConnection();

$query = "SELECT * FROM artisans";
$stmt = $db->prepare($query);
$stmt->execute();

$artisans_arr = array();

while ($row = $stmt->fetch(PDO::FETCH_ASSOC)){
    $artisan_item = array(
        "id" => $row['id'],
        "name" => $row['name'],
        "location" => $row['location'],
        "imageUrl" => $row['image_url'],
        "bio" => $row['bio'],
        "rating" => (float)$row['rating']
    );
    array_push($artisans_arr, $artisan_item);
}

http_response_code(200);
echo json_encode($artisans_arr);
