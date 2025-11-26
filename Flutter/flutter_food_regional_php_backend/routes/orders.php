<?php

require_once __DIR__ . '/../config/Database.php';

function handleOrderRoutes($method, $path) {
    $database = new Database();
    $db = $database->getConnection();
    $userId = AuthMiddleware::authenticate();

    // Get user's orders (or all orders for admin/restaurant)
    if ($method === 'GET' && $path === '') {
        // Get user role
        $stmt = $db->prepare('SELECT role FROM users WHERE id = ?');
        $stmt->execute([$userId]);
        $user = $stmt->fetch();
        $role = $user['role'] ?? 'customer';
        
        error_log("DEBUG Orders: User ID: $userId, Role: $role");

        if ($role === 'admin' || $role === 'restaurant') {
            // Admin and Restaurant see all orders
            $stmt = $db->prepare('
                SELECT o.*, r.name as restaurant_name, r.image_url as restaurant_image,
                       r.address as restaurant_address, r.phone as restaurant_phone, r.latitude as restaurant_latitude, r.longitude as restaurant_longitude,
                       u.name as user_name, u.phone as user_phone,
                       a.house_number, a.street, a.locality, a.city, a.state, a.pincode, a.latitude, a.longitude,
                       rider.name as rider_name
                FROM orders o
                JOIN restaurants r ON o.restaurant_id = r.id
                JOIN users u ON o.user_id = u.id
                JOIN addresses a ON o.address_id = a.id
                LEFT JOIN users rider ON o.rider_id = rider.id
                ORDER BY o.created_at DESC
            ');
            $stmt->execute();
        } elseif ($role === 'rider') {
            // Riders see only their assigned orders with full details
            $stmt = $db->prepare('
                SELECT o.*, r.name as restaurant_name, r.image_url as restaurant_image,
                       r.address as restaurant_address, r.phone as restaurant_phone, r.latitude as restaurant_latitude, r.longitude as restaurant_longitude,
                       u.name as user_name, u.phone as user_phone,
                       a.house_number, a.street, a.locality, a.city, a.state, a.pincode, a.latitude, a.longitude
                FROM orders o
                JOIN restaurants r ON o.restaurant_id = r.id
                JOIN users u ON o.user_id = u.id
                JOIN addresses a ON o.address_id = a.id
                WHERE o.rider_id = ?
                ORDER BY o.created_at DESC
            ');
            $stmt->execute([$userId]);
        } else {
            // Customers see only their orders
            $stmt = $db->prepare('
                SELECT o.*, r.name as restaurant_name, r.image_url as restaurant_image,
                       r.address as restaurant_address, r.phone as restaurant_phone,
                       rider.name as rider_name, rider.phone as rider_phone
                FROM orders o
                JOIN restaurants r ON o.restaurant_id = r.id
                LEFT JOIN users rider ON o.rider_id = rider.id
                WHERE o.user_id = ?
                ORDER BY o.created_at DESC
            ');
            $stmt->execute([$userId]);
        }
        
        $orders = $stmt->fetchAll();
        
        // Fetch items for each order
        foreach ($orders as &$order) {
            $itemStmt = $db->prepare('
                SELECT oi.*, mi.name, mi.price
                FROM order_items oi
                JOIN menu_items mi ON oi.menu_item_id = mi.id
                WHERE oi.order_id = ?
            ');
            $itemStmt->execute([$order['id']]);
            $order['items'] = $itemStmt->fetchAll();
        }
        
        echo json_encode($orders);
        return;
    }

    // Get order details by ID
    if ($method === 'GET' && preg_match('/^\/([a-f0-9-]+)$/', $path, $matches)) {
        $id = $matches[1];

        // Get user role
        $stmt = $db->prepare('SELECT role FROM users WHERE id = ?');
        $stmt->execute([$userId]);
        $user = $stmt->fetch();
        $role = $user['role'] ?? 'customer';

        $query = '
            SELECT o.*, r.name as restaurant_name, r.image_url as restaurant_image, r.latitude as restaurant_latitude, r.longitude as restaurant_longitude,
                   r.address as restaurant_address, r.phone as restaurant_phone,
                   a.house_number, a.street, a.locality, a.city, a.state, a.pincode, a.latitude, a.longitude,
                   rider.name as rider_name, rider.phone as rider_phone
            FROM orders o
            JOIN restaurants r ON o.restaurant_id = r.id
            JOIN addresses a ON o.address_id = a.id
            LEFT JOIN users rider ON o.rider_id = rider.id
            WHERE o.id = ?
        ';
        
        $params = [$id];

        // If customer, restrict to their own orders
        if ($role === 'customer') {
            $query .= ' AND o.user_id = ?';
            $params[] = $userId;
        }

        $stmt = $db->prepare($query);
        $stmt->execute($params);
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

    // Update order status
    if ($method === 'PUT' && preg_match('/^\/([a-f0-9-]+)\/status$/', $path, $matches)) {
        $id = $matches[1];
        $data = json_decode(file_get_contents("php://input"), true);

        if (!isset($data['status'])) {
            http_response_code(400);
            echo json_encode(['error' => 'Missing status field']);
            return;
        }

        $validStatuses = ['pending', 'preparing', 'rider_assigned', 'handover', 'delivered', 'cancelled'];
        if (!in_array($data['status'], $validStatuses)) {
            http_response_code(400);
            echo json_encode(['error' => 'Invalid status']);
            return;
        }

        // Get user role
        $stmt = $db->prepare('SELECT role FROM users WHERE id = ?');
        $stmt->execute([$userId]);
        $user = $stmt->fetch();
        $role = $user['role'] ?? 'customer';

        // Admin and Restaurant can update to any status
        // Riders can only update to 'delivered'
        if ($role === 'admin' || $role === 'restaurant') {
            // Admin and Restaurant can update to any status
        } elseif ($role === 'rider') {
            // Riders can only mark as delivered
            if ($data['status'] !== 'delivered') {
                http_response_code(403);
                echo json_encode(['error' => 'Riders can only mark orders as delivered']);
                return;
            }
            // Verify the order is assigned to this rider
            $stmt = $db->prepare('SELECT rider_id FROM orders WHERE id = ?');
            $stmt->execute([$id]);
            $order = $stmt->fetch();
            if (!$order || $order['rider_id'] !== $userId) {
                http_response_code(403);
                echo json_encode(['error' => 'You can only update orders assigned to you']);
                return;
            }
        } else {
            // Customers cannot update status
            http_response_code(403);
            echo json_encode(['error' => 'Unauthorized']);
            return;
        }

        $stmt = $db->prepare('UPDATE orders SET status = ? WHERE id = ?');
        $stmt->execute([$data['status'], $id]);

        if ($stmt->rowCount() === 0) {
            // Check if order exists
            $stmt = $db->prepare('SELECT id FROM orders WHERE id = ?');
            $stmt->execute([$id]);
            if ($stmt->rowCount() === 0) {
                http_response_code(404);
                echo json_encode(['error' => 'Order not found']);
                return;
            }
        }

        // Auto-create commissions when order is delivered
        if ($data['status'] === 'delivered') {
            // Get order details
            $stmt = $db->prepare('SELECT total_amount, rider_id, restaurant_id FROM orders WHERE id = ?');
            $stmt->execute([$id]);
            $order = $stmt->fetch();

            if ($order) {
                $totalAmount = $order['total_amount'];
                $riderId = $order['rider_id'];
                $restaurantId = $order['restaurant_id'];

                // Create rider commission (5%)
                if ($riderId) {
                    $riderCommission = $totalAmount * 0.05;
                    $commissionId = bin2hex(random_bytes(16));
                    $stmt = $db->prepare('
                        INSERT INTO commissions (id, user_id, order_id, amount, percentage, status)
                        VALUES (?, ?, ?, ?, ?, ?)
                    ');
                    $stmt->execute([$commissionId, $riderId, $id, $riderCommission, 5.00, 'pending']);
                }

                // Create restaurant commission (15%)
                // Get restaurant owner user_id
                $stmt = $db->prepare('SELECT id FROM users WHERE restaurant_id = ? AND role = ?');
                $stmt->execute([$restaurantId, 'restaurant']);
                $restaurantOwner = $stmt->fetch();

                if ($restaurantOwner) {
                    $restaurantCommission = $totalAmount * 0.15;
                    $commissionId = bin2hex(random_bytes(16));
                    $stmt = $db->prepare('
                        INSERT INTO commissions (id, user_id, order_id, amount, percentage, status)
                        VALUES (?, ?, ?, ?, ?, ?)
                    ');
                    $stmt->execute([$commissionId, $restaurantOwner['id'], $id, $restaurantCommission, 15.00, 'pending']);
                }
            }
        }

        echo json_encode(['message' => 'Order status updated', 'status' => $data['status']]);
        return;
    }

    // Assign rider to order
    if ($method === 'PUT' && preg_match('/^\/([a-f0-9-]+)\/assign-rider$/', $path, $matches)) {
        $id = $matches[1];
        $data = json_decode(file_get_contents("php://input"), true);

        if (!isset($data['riderId'])) {
            http_response_code(400);
            echo json_encode(['error' => 'Missing riderId field']);
            return;
        }

        // Get user role
        $stmt = $db->prepare('SELECT role FROM users WHERE id = ?');
        $stmt->execute([$userId]);
        $user = $stmt->fetch();
        $role = $user['role'] ?? 'customer';

        // Only Admin can assign riders
        if ($role !== 'admin') {
            http_response_code(403);
            echo json_encode(['error' => 'Unauthorized']);
            return;
        }

        // Verify rider exists and has rider role
        $stmt = $db->prepare('SELECT id FROM users WHERE id = ? AND role = ?');
        $stmt->execute([$data['riderId'], 'rider']);
        if ($stmt->rowCount() === 0) {
            http_response_code(400);
            echo json_encode(['error' => 'Invalid rider ID']);
            return;
        }

        $stmt = $db->prepare('UPDATE orders SET rider_id = ? WHERE id = ?');
        $stmt->execute([$data['riderId'], $id]);

        if ($stmt->rowCount() === 0) {
            // Check if order exists
            $stmt = $db->prepare('SELECT id FROM orders WHERE id = ?');
            $stmt->execute([$id]);
            if ($stmt->rowCount() === 0) {
                http_response_code(404);
                echo json_encode(['error' => 'Order not found']);
                return;
            }
        }

        echo json_encode(['message' => 'Rider assigned successfully', 'riderId' => $data['riderId']]);
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


