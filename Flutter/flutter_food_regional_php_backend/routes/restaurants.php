<?php

require_once __DIR__ . '/../config/Database.php';

function handleRestaurantRoutes($method, $path) {
    $database = new Database();
    $db = $database->getConnection();

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

    http_response_code(404);
    echo json_encode(['error' => 'Route not found']);
}
