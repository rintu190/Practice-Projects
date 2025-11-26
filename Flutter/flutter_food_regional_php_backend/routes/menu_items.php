<?php

require_once __DIR__ . '/../config/Database.php';
require_once __DIR__ . '/../middleware/AuthMiddleware.php';

function handleMenuItemRoutes($method, $path) {
    $database = new Database();
    $db = $database->getConnection();

    // Create new menu item
    if ($method === 'POST' && $path === '') {
        $userId = AuthMiddleware::authenticate();
        $data = json_decode(file_get_contents('php://input'), true);

        if (!$data || !isset($data['restaurant_id']) || !isset($data['name']) || !isset($data['price'])) {
            http_response_code(400);
            echo json_encode(['error' => 'restaurant_id, name, and price are required']);
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

        $isAdmin = $user['role'] === 'admin';
        $isOwnerOfRestaurant = $user['role'] === 'restaurant' && $user['restaurant_id'] === $data['restaurant_id'];

        if (!$isAdmin && !$isOwnerOfRestaurant) {
            http_response_code(403);
            echo json_encode(['error' => 'You can only add menu items to your own restaurant']);
            return;
        }

        $id = bin2hex(random_bytes(16));
        $restaurantId = $data['restaurant_id'];
        $name = $data['name'];
        $description = $data['description'] ?? '';
        $price = $data['price'];
        $imageUrl = $data['image_url'] ?? '';

        try {
            $isVeg = isset($data['is_veg']) ? ($data['is_veg'] ? 1 : 0) : 1; // Default to veg (1) if not set

            $stmt = $db->prepare('INSERT INTO menu_items (id, restaurant_id, name, description, price, image_url, is_veg) VALUES (?, ?, ?, ?, ?, ?, ?)');
            $stmt->execute([$id, $restaurantId, $name, $description, $price, $imageUrl, $isVeg]);
            
            http_response_code(201);
            echo json_encode([
                'message' => 'Menu item created successfully',
                'id' => $id
            ]);
        } catch (PDOException $e) {
            http_response_code(500);
            echo json_encode(['error' => 'Database error: ' . $e->getMessage()]);
        }
        return;
    }

    // Update menu item by ID
    if ($method === 'PUT' && preg_match('/^\/([a-f0-9-]+)$/', $path, $matches)) {
        $userId = AuthMiddleware::authenticate();
        $id = $matches[1];
        $data = json_decode(file_get_contents('php://input'), true);

        if (!$data) {
            http_response_code(400);
            echo json_encode(['error' => 'Invalid JSON input']);
            return;
        }

        // Get the menu item to check restaurant ownership
        $menuStmt = $db->prepare('SELECT restaurant_id FROM menu_items WHERE id = ?');
        $menuStmt->execute([$id]);
        $menuItem = $menuStmt->fetch();

        if (!$menuItem) {
            http_response_code(404);
            echo json_encode(['error' => 'Menu item not found']);
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

        $isAdmin = $user['role'] === 'admin';
        $isOwnerOfRestaurant = $user['role'] === 'restaurant' && $user['restaurant_id'] === $menuItem['restaurant_id'];

        if (!$isAdmin && !$isOwnerOfRestaurant) {
            http_response_code(403);
            echo json_encode(['error' => 'You can only edit menu items from your own restaurant']);
            return;
        }

        $setClauses = [];
        $params = [];

        if (isset($data['name'])) {
            $setClauses[] = 'name = ?';
            $params[] = $data['name'];
        }
        if (isset($data['description'])) {
            $setClauses[] = 'description = ?';
            $params[] = $data['description'];
        }
        if (isset($data['price'])) {
            $setClauses[] = 'price = ?';
            $params[] = $data['price'];
        }
        if (isset($data['image_url'])) {
            $setClauses[] = 'image_url = ?';
            $params[] = $data['image_url'];
        }
        if (isset($data['is_veg'])) {
            $setClauses[] = 'is_veg = ?';
            $params[] = $data['is_veg'] ? 1 : 0;
        }

        if (empty($setClauses)) {
            http_response_code(400);
            echo json_encode(['error' => 'No fields provided for update']);
            return;
        }

        $params[] = $id;

        $query = 'UPDATE menu_items SET ' . implode(', ', $setClauses) . ' WHERE id = ?';
        $stmt = $db->prepare($query);

        try {
            $stmt->execute($params);
            // Even if rowCount is 0, it means the query ran but maybe no values changed.
            // We should consider this a success for the client.
            http_response_code(200);
            echo json_encode(['message' => 'Menu item updated successfully']);
        } catch (PDOException $e) {
            http_response_code(500);
            echo json_encode(['error' => 'Database error: ' . $e->getMessage()]);
        }
        return;
    }

    // Delete menu item by ID
    if ($method === 'DELETE' && preg_match('/^\/([a-f0-9-]+)$/', $path, $matches)) {
        $userId = AuthMiddleware::authenticate();
        $id = $matches[1];

        // Get the menu item to check restaurant ownership
        $menuStmt = $db->prepare('SELECT restaurant_id FROM menu_items WHERE id = ?');
        $menuStmt->execute([$id]);
        $menuItem = $menuStmt->fetch();

        if (!$menuItem) {
            http_response_code(404);
            echo json_encode(['error' => 'Menu item not found']);
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

        $isAdmin = $user['role'] === 'admin';
        $isOwnerOfRestaurant = $user['role'] === 'restaurant' && $user['restaurant_id'] === $menuItem['restaurant_id'];

        if (!$isAdmin && !$isOwnerOfRestaurant) {
            http_response_code(403);
            echo json_encode(['error' => 'You can only delete menu items from your own restaurant']);
            return;
        }

        try {
            $stmt = $db->prepare('DELETE FROM menu_items WHERE id = ?');
            $stmt->execute([$id]);
            
            if ($stmt->rowCount() > 0) {
                http_response_code(200);
                echo json_encode(['message' => 'Menu item deleted successfully']);
            } else {
                http_response_code(404);
                echo json_encode(['error' => 'Menu item not found']);
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
