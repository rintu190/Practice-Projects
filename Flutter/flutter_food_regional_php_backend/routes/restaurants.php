<?php

require_once __DIR__ . '/../config/Database.php';

function handleRestaurantRoutes($method, $path) {
    $database = new Database();
    $db = $database->getConnection();

    // Create new restaurant
    if ($method === 'POST' && $path === '') {
        $data = json_decode(file_get_contents('php://input'), true);

        if (!$data || !isset($data['name']) || !isset($data['cuisine'])) {
            http_response_code(400);
            echo json_encode(['error' => 'Name and cuisine are required']);
            return;
        }

        $id = bin2hex(random_bytes(16));
        $name = $data['name'];
        $cuisine = $data['cuisine'];
        $rating = $data['rating'] ?? 4.0;
        $deliveryTime = $data['delivery_time'] ?? '30-40 min';
        $address = $data['address'] ?? '';
        $phone = $data['phone'] ?? '';
        $imageUrl = $data['image_url'] ?? '';
        $latitude = isset($data['latitude']) ? $data['latitude'] : null;
        $longitude = isset($data['longitude']) ? $data['longitude'] : null;

        try {
            $stmt = $db->prepare('INSERT INTO restaurants (id, name, cuisine, rating, delivery_time, address, phone, image_url, latitude, longitude) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)');
            $stmt->execute([$id, $name, $cuisine, $rating, $deliveryTime, $address, $phone, $imageUrl, $latitude, $longitude]);
            
            http_response_code(201);
            echo json_encode([
                'message' => 'Restaurant created successfully',
                'id' => $id
            ]);
        } catch (PDOException $e) {
            http_response_code(500);
            echo json_encode(['error' => 'Database error: ' . $e->getMessage()]);
        }
        return;
    }

    // Get all restaurants (with optional cuisine filter)
    if ($method === 'GET' && $path === '') {
        $cuisine = $_GET['cuisine'] ?? null;
        
        $query = 'SELECT * FROM restaurants';
        $params = [];
        
        if ($cuisine && $cuisine !== 'All') {
            $query .= ' WHERE cuisine = ?';
            $params[] = $cuisine;
        }

        $stmt = $db->prepare($query);
        $stmt->execute($params);
        $restaurants = $stmt->fetchAll();

        echo json_encode($restaurants);
        return;
    }

    // Get restaurant by ID with menu items
    if ($method === 'GET' && preg_match('/^\/([a-f0-9-]+)$/', $path, $matches)) {
        $id = $matches[1];

        $stmt = $db->prepare('SELECT * FROM restaurants WHERE id = ?');
        $stmt->execute([$id]);
        $restaurant = $stmt->fetch();

        if (!$restaurant) {
            http_response_code(404);
            echo json_encode(['error' => 'Restaurant not found']);
            return;
        }

        $stmt = $db->prepare('SELECT * FROM menu_items WHERE restaurant_id = ?');
        $stmt->execute([$id]);
        $menuItems = $stmt->fetchAll();

        $restaurant['menuItems'] = $menuItems;
        echo json_encode($restaurant);
        return;
    }

    // Get menu items for a restaurant
    if ($method === 'GET' && preg_match('/^\/([a-f0-9-]+)\/menu$/', $path, $matches)) {
        $id = $matches[1];

        $stmt = $db->prepare('SELECT * FROM menu_items WHERE restaurant_id = ?');
        $stmt->execute([$id]);
        $menuItems = $stmt->fetchAll();

        echo json_encode($menuItems);
        return;
    }

    // Update restaurant by ID
    if ($method === 'PUT' && preg_match('/^\/([a-f0-9-]+)$/', $path, $matches)) {
        require_once __DIR__ . '/../middleware/AuthMiddleware.php';
        $userId = AuthMiddleware::authenticate();
        
        $id = $matches[1];
        $data = json_decode(file_get_contents('php://input'), true);

        if (!$data) {
            http_response_code(400);
            echo json_encode(['error' => 'Invalid JSON input']);
            return;
        }

        // Check if user is admin or the restaurant owner
        $userStmt = $db->prepare('SELECT role, restaurant_id FROM users WHERE id = ?');
        $userStmt->execute([$userId]);
        $user = $userStmt->fetch();

        if (!$user) {
            http_response_code(403);
            echo json_encode(['error' => 'Unauthorized']);
            return;
        }

        // Allow if user is admin OR if user is restaurant owner and this is their restaurant
        $isAdmin = $user['role'] === 'admin';
        $isOwnerOfRestaurant = $user['role'] === 'restaurant' && $user['restaurant_id'] === $id;

        if (!$isAdmin && !$isOwnerOfRestaurant) {
            http_response_code(403);
            echo json_encode(['error' => 'You can only edit your own restaurant']);
            return;
        }

        $setClauses = [];
        $params = [];

        if (isset($data['name'])) {
            $setClauses[] = 'name = ?';
            $params[] = $data['name'];
        }
        if (isset($data['address'])) {
            $setClauses[] = 'address = ?';
            $params[] = $data['address'];
        }
        if (isset($data['cuisine'])) {
            $setClauses[] = 'cuisine = ?';
            $params[] = $data['cuisine'];
        }
        if (isset($data['rating'])) {
            $setClauses[] = 'rating = ?';
            $params[] = $data['rating'];
        }
        if (isset($data['phone'])) {
            $setClauses[] = 'phone = ?';
            $params[] = $data['phone'];
        }
        if (isset($data['image_url'])) {
            $setClauses[] = 'image_url = ?';
            $params[] = $data['image_url'];
        }
        if (isset($data['latitude'])) {
            $setClauses[] = 'latitude = ?';
            $params[] = $data['latitude'];
        }
        if (isset($data['longitude'])) {
            $setClauses[] = 'longitude = ?';
            $params[] = $data['longitude'];
        }

        if (empty($setClauses)) {
            http_response_code(400);
            echo json_encode(['error' => 'No fields provided for update']);
            return;
        }

        $params[] = $id; // Add ID for WHERE clause

        $query = 'UPDATE restaurants SET ' . implode(', ', $setClauses) . ' WHERE id = ?';
        $stmt = $db->prepare($query);

        try {
            $stmt->execute($params);
            if ($stmt->rowCount() > 0) {
                http_response_code(200);
                echo json_encode(['message' => 'Restaurant updated successfully']);
            } else {
                http_response_code(404);
                echo json_encode(['error' => 'Restaurant not found or no changes made']);
            }
        } catch (PDOException $e) {
            http_response_code(500);
            echo json_encode(['error' => 'Database error: ' . $e->getMessage()]);
        }
        return;
    }

    http_response_code(404);
    echo json_encode(['error' => 'Route not found']);
}
