<?php

require_once __DIR__ . '/../config/Database.php';

function handleAddressRoutes($method, $path) {
    $database = new Database();
    $db = $database->getConnection();
    $userId = AuthMiddleware::authenticate();

    // Get user's addresses
    if ($method === 'GET' && $path === '') {
        $stmt = $db->prepare('SELECT * FROM addresses WHERE user_id = ?');
        $stmt->execute([$userId]);
        $addresses = $stmt->fetchAll();

        echo json_encode($addresses);
        return;
    }

    // Create new address
    if ($method === 'POST' && $path === '') {
        $input = file_get_contents("php://input");
        error_log("Received address data: " . $input);
        $data = json_decode($input, true);
        
        if (!isset($data['houseNumber'], $data['street'], $data['locality'], $data['city'], $data['state'], $data['pincode'])) {
            error_log("Missing required fields. Data: " . print_r($data, true));
            http_response_code(400);
            echo json_encode(['error' => 'Missing required fields']);
            return;
        }

        $addressId = generateUuid();
        $stmt = $db->prepare('INSERT INTO addresses (id, user_id, house_number, street, locality, city, state, pincode, landmark, latitude, longitude) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)');
        $stmt->execute([
            $addressId,
            $userId,
            $data['houseNumber'],
            $data['street'],
            $data['locality'],
            $data['city'],
            $data['state'],
            $data['pincode'],
            $data['landmark'] ?? null,
            $data['latitude'] ?? null,
            $data['longitude'] ?? null
        ]);

        $stmt = $db->prepare('SELECT * FROM addresses WHERE id = ?');
        $stmt->execute([$addressId]);
        $newAddress = $stmt->fetch();

        http_response_code(201);
        echo json_encode($newAddress);
        return;
    }

    // Delete address
    if ($method === 'DELETE' && preg_match('/^\/([a-f0-9-]+)$/', $path, $matches)) {
        $id = $matches[1];

        $stmt = $db->prepare('DELETE FROM addresses WHERE id = ? AND user_id = ?');
        $stmt->execute([$id, $userId]);

        if ($stmt->rowCount() === 0) {
            http_response_code(404);
            echo json_encode(['error' => 'Address not found']);
            return;
        }

        echo json_encode(['message' => 'Address deleted successfully']);
        return;
    }

    http_response_code(404);
    echo json_encode(['error' => 'Route not found']);
}


