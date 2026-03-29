<?php
require_once __DIR__ . '/../../config/database.php';

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");

$database = new Database();
$db = $database->getConnection();

$data = json_decode(file_get_contents("php://input"));

if (
    !empty($data->customerName) &&
    !empty($data->customerEmail) &&
    !empty($data->customerAddress) &&
    !empty($data->items) &&
    !empty($data->totalAmount) &&
    !empty($data->sellerId)
) {
    try {
        $db->beginTransaction();

        $query = "INSERT INTO orders (id, customer_id, customer_name, customer_email, customer_address, total_amount, seller_id, status) 
                  VALUES (:id, :customer_id, :customer_name, :customer_email, :customer_address, :total_amount, :seller_id, 'pending')";
        $stmt = $db->prepare($query);

        $orderId = 'ORD-' . strtoupper(uniqid());

        $stmt->bindParam(':id', $orderId);
        $stmt->bindParam(':customer_id', $data->customerId);
        $stmt->bindParam(':customer_name', $data->customerName);
        $stmt->bindParam(':customer_email', $data->customerEmail);
        $stmt->bindParam(':customer_address', $data->customerAddress);
        $stmt->bindParam(':total_amount', $data->totalAmount);
        $stmt->bindParam(':seller_id', $data->sellerId);

        if($stmt->execute()){
            // Insert order items
            $itemQuery = "INSERT INTO order_items (order_id, saree_id, quantity, price) VALUES (:order_id, :saree_id, :quantity, :price)";
            $itemStmt = $db->prepare($itemQuery);

            foreach($data->items as $item) {
                $itemStmt->bindParam(':order_id', $orderId);
                $itemStmt->bindParam(':saree_id', $item->sareeId);
                $itemStmt->bindParam(':quantity', $item->quantity);
                $itemStmt->bindParam(':price', $item->price);
                $itemStmt->execute();
            }

            $db->commit();

            http_response_code(201);
            echo json_encode(array(
                "message" => "Order was created.", 
                "success" => true,
                "orderId" => $orderId
            ));
        } else {
            $db->rollBack();
            http_response_code(503);
            echo json_encode(array("message" => "Unable to create order.", "success" => false));
        }
    } catch (Exception $e) {
        $db->rollBack();
        http_response_code(500);
        echo json_encode(array("message" => "An error occurred: " . $e->getMessage(), "success" => false));
    }
} else {
    http_response_code(400);
    echo json_encode(array("message" => "Incomplete data.", "success" => false));
}
