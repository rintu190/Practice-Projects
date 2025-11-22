<?php

require_once __DIR__ . '/../config/Database.php';

function handleOrderRoutes($method, $path) {
    $database = new Database();
    $db = $database->getConnection();
    $userId = AuthMiddleware::authenticate();

    // Get user's orders
    if ($method === 'GET' && $path === '') {
        $stmt = $db->prepare('
            SELECT o.*, r.name as restaurant_name, r.image_url as restaurant_image
            FROM orders o
            JOIN restaurants r ON o.restaurant_id = r.id
            WHERE o.user_id = ?
            ORDER BY o.created_at DESC
        ');
        $stmt->execute([$userId]);
        $orders = $stmt->fetchAll();

        echo json_encode($orders);
        return;
    }

    // Get order details by ID
    if ($method === 'GET' && preg_match('/^\/([a-f0-9-]+)$/', $path, $matches)) {
        $id = $matches[1];

        $stmt = $db->prepare('
            SELECT o.*, r.name as restaurant_name, r.image_url as restaurant_image,
                   a.house_number, a.street, a.locality, a.city, a.state, a.pincode
            FROM orders o
            JOIN restaurants r ON o.restaurant_id = r.id
            JOIN addresses a ON o.address_id = a.id
            WHERE o.id = ? AND o.user_id = ?
        ');
        $stmt->execute([$id, $userId]);
        $order = $stmt->fetch();

        if (!$order) {
            http_response_code(404);
            echo json_encode(['error' => 'Order not found']);
            return;
        }

        $stmt = $db->prepare('
            SELECT oi.*, mi.name, mi.image_url
            FROM order_items oi
            JOIN menu_items mi ON oi.menu_item_id = mi.id
            WHERE oi.order_id = ?
        ');
        $stmt->execute([$id]);
        $orderItems = $stmt->fetchAll();

        $order['items'] = $orderItems;
        echo json_encode($order);
        return;
    }

    // Create new order
    if ($method === 'POST' && $path === '') {
        $data = json_decode(file_get_contents("php://input"), true);
        
        if (!isset($data['restaurantId'], $data['addressId'], $data['items'], $data['totalAmount'])) {
            http_response_code(400);
            echo json_encode(['error' => 'Missing required fields']);
            return;
        }

        try {
            $db->beginTransaction();

            // Create order
            $orderId = generateUuid();
            $stmt = $db->prepare('INSERT INTO orders (id, user_id, restaurant_id, address_id, total_amount, status) VALUES (?, ?, ?, ?, ?, ?)');
            $stmt->execute([
                $orderId,
                $userId,
                $data['restaurantId'],
                $data['addressId'],
                $data['totalAmount'],
                'pending'
            ]);

            // Create order items
            foreach ($data['items'] as $item) {
                $orderItemId = generateUuid();
                $stmt = $db->prepare('INSERT INTO order_items (id, order_id, menu_item_id, quantity, price) VALUES (?, ?, ?, ?, ?)');
                $stmt->execute([
                    $orderItemId,
                    $orderId,
                    $item['menuItemId'],
                    $item['quantity'],
                    $item['price']
                ]);
            }

            $db->commit();

            $stmt = $db->prepare('SELECT * FROM orders WHERE id = ?');
            $stmt->execute([$orderId]);
            $newOrder = $stmt->fetch();

            http_response_code(201);
            echo json_encode($newOrder);
        } catch (Exception $e) {
            $db->rollBack();
            http_response_code(500);
            echo json_encode(['error' => 'Server error']);
        }
        return;
    }

    http_response_code(404);
    echo json_encode(['error' => 'Route not found']);
}


