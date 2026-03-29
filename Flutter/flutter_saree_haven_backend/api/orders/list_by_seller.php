<?php
require_once __DIR__ . '/../../config/database.php';

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

$database = new Database();
$db = $database->getConnection();

$sellerId = isset($_GET['seller_id']) ? $_GET['seller_id'] : null;

if (!$sellerId) {
    http_response_code(400);
    echo json_encode(["message" => "Seller ID is required"]);
    exit;
}

$query = "SELECT * FROM orders WHERE seller_id = ? ORDER BY order_date DESC";
$stmt = $db->prepare($query);
$stmt->execute([$sellerId]);

$orders_arr = array();

while ($row = $stmt->fetch(PDO::FETCH_ASSOC)){
    $order_id = $row['id'];

    // Get order items
    $items_query = "SELECT oi.*, s.name, s.price as saree_price, s.image_urls 
                    FROM order_items oi 
                    JOIN sarees s ON oi.saree_id = s.id 
                    WHERE oi.order_id = ?";
    $items_stmt = $db->prepare($items_query);
    $items_stmt->execute([$order_id]);
    
    $items_arr = array();
    while ($item_row = $items_stmt->fetch(PDO::FETCH_ASSOC)) {
        array_push($items_arr, array(
            "saree" => array(
                "id" => $item_row['saree_id'],
                "name" => $item_row['name'],
                "price" => (float)$item_row['saree_price'],
                "imageUrls" => json_decode($item_row['image_urls'], true) ?? []
            ),
            "quantity" => (int)$item_row['quantity'],
            "price" => (float)$item_row['price']
        ));
    }

    $order_item = array(
        "id" => $row['id'],
        "customerName" => $row['customer_name'],
        "customerEmail" => $row['customer_email'],
        "customerAddress" => $row['customer_address'],
        "items" => $items_arr,
        "totalAmount" => (float)$row['total_amount'],
        "orderDate" => $row['order_date'],
        "status" => $row['status'],
        "sellerId" => $row['seller_id']
    );
    array_push($orders_arr, $order_item);
}

http_response_code(200);
echo json_encode($orders_arr);
