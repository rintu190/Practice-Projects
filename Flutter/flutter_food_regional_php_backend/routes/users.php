<?php

require_once __DIR__ . '/../config/Database.php';
require_once __DIR__ . '/../middleware/AuthMiddleware.php';

function handleUserRoutes($method, $path) {
    $database = new Database();
    $db = $database->getConnection();
    $userId = AuthMiddleware::authenticate();

    // Get user role
    $stmt = $db->prepare('SELECT role FROM users WHERE id = ?');
    $stmt->execute([$userId]);
    $user = $stmt->fetch();
    $role = $user['role'] ?? 'customer';

    // Get all riders (Admin only)
    if ($method === 'GET' && $path === '/riders') {
        // Only Admin can fetch riders
        if ($role !== 'admin') {
            http_response_code(403);
            echo json_encode(['error' => 'Unauthorized']);
            return;
        }

        $stmt = $db->prepare('SELECT id, name, email, phone FROM users WHERE role = ?');
        $stmt->execute(['rider']);
        $riders = $stmt->fetchAll();

        echo json_encode($riders);
        return;
    }

    // Assign restaurant to user (Admin only)
    if ($method === 'PUT' && preg_match('/^\/([a-f0-9-]+)\/assign-restaurant$/', $path, $matches)) {
        $targetUserId = $matches[1];
        $data = json_decode(file_get_contents("php://input"), true);

        // Only Admin can assign restaurants
        if ($role !== 'admin') {
            http_response_code(403);
            echo json_encode(['error' => 'Unauthorized']);
            return;
        }

        $restaurantId = $data['restaurantId'] ?? null;

        // Update user's restaurant_id
        $stmt = $db->prepare('UPDATE users SET restaurant_id = ? WHERE id = ?');
        $stmt->execute([$restaurantId, $targetUserId]);

        if ($stmt->rowCount() === 0) {
            http_response_code(404);
            echo json_encode(['error' => 'User not found']);
            return;
        }

        echo json_encode(['message' => 'Restaurant assigned successfully', 'restaurantId' => $restaurantId]);
        return;
    }

    // Get all restaurant owners (Admin only)
    if ($method === 'GET' && $path === '/restaurant-owners') {
        if ($role !== 'admin') {
            http_response_code(403);
            echo json_encode(['error' => 'Unauthorized']);
            return;
        }

        $stmt = $db->prepare('
            SELECT u.id, u.name, u.email, u.phone, u.restaurant_id, r.name as restaurant_name
            FROM users u
            LEFT JOIN restaurants r ON u.restaurant_id = r.id
            WHERE u.role = ?
        ');
        $stmt->execute(['restaurant']);
        $owners = $stmt->fetchAll();

        echo json_encode($owners);
        return;
    }

    http_response_code(404);
    echo json_encode(['error' => 'Route not found']);
}
