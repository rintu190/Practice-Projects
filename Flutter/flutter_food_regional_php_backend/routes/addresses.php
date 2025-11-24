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
        $isDefault = $data['isDefault'] ?? false;
        
        // If setting as default, unset other defaults first
        if ($isDefault) {
            $stmt = $db->prepare('UPDATE addresses SET is_default = FALSE WHERE user_id = ?');
            $stmt->execute([$userId]);
        }
        
        $stmt = $db->prepare('INSERT INTO addresses (id, user_id, house_number, street, locality, city, state, pincode, landmark, latitude, longitude, is_default) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)');
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
            $data['longitude'] ?? null,
            $isDefault ? 1 : 0
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

    // Update address
    if ($method === 'PUT' && preg_match('/^\/([a-f0-9-]+)$/', $path, $matches)) {
        $id = $matches[1];
        $input = file_get_contents("php://input");
        $data = json_decode($input, true);

        // Verify address belongs to user
        $stmt = $db->prepare('SELECT id FROM addresses WHERE id = ? AND user_id = ?');
        $stmt->execute([$id, $userId]);
        if (!$stmt->fetch()) {
            http_response_code(404);
            echo json_encode(['error' => 'Address not found']);
            return;
        }

        // Build update query dynamically
        $updates = [];
        $params = [];
        
        if (isset($data['houseNumber'])) {
            $updates[] = 'house_number = ?';
            $params[] = $data['houseNumber'];
        }
        if (isset($data['street'])) {
            $updates[] = 'street = ?';
            $params[] = $data['street'];
        }
        if (isset($data['locality'])) {
            $updates[] = 'locality = ?';
            $params[] = $data['locality'];
        }
        if (isset($data['city'])) {
            $updates[] = 'city = ?';
            $params[] = $data['city'];
        }
        if (isset($data['state'])) {
            $updates[] = 'state = ?';
            $params[] = $data['state'];
        }
        if (isset($data['pincode'])) {
            $updates[] = 'pincode = ?';
            $params[] = $data['pincode'];
        }
        if (isset($data['landmark'])) {
            $updates[] = 'landmark = ?';
            $params[] = $data['landmark'];
        }
        if (isset($data['latitude'])) {
            $updates[] = 'latitude = ?';
            $params[] = $data['latitude'];
        }
        if (isset($data['longitude'])) {
            $updates[] = 'longitude = ?';
            $params[] = $data['longitude'];
        }
        if (isset($data['isDefault'])) {
            // If setting as default, unset other defaults first
            if ($data['isDefault']) {
                $stmt = $db->prepare('UPDATE addresses SET is_default = FALSE WHERE user_id = ?');
                $stmt->execute([$userId]);
            }
            $updates[] = 'is_default = ?';
            $params[] = $data['isDefault'] ? 1 : 0;
        }

        if (empty($updates)) {
            http_response_code(400);
            echo json_encode(['error' => 'No fields to update']);
            return;
        }

        $params[] = $id;
        $params[] = $userId;
        $sql = 'UPDATE addresses SET ' . implode(', ', $updates) . ' WHERE id = ? AND user_id = ?';
        $stmt = $db->prepare($sql);
        $stmt->execute($params);

        // Return updated address
        $stmt = $db->prepare('SELECT * FROM addresses WHERE id = ?');
        $stmt->execute([$id]);
        $updatedAddress = $stmt->fetch();

        echo json_encode($updatedAddress);
        return;
    }

    // Set address as default
    if ($method === 'PUT' && preg_match('/^\/([a-f0-9-]+)\/set-default$/', $path, $matches)) {
        $id = $matches[1];

        // Verify address belongs to user
        $stmt = $db->prepare('SELECT id FROM addresses WHERE id = ? AND user_id = ?');
        $stmt->execute([$id, $userId]);
        if (!$stmt->fetch()) {
            http_response_code(404);
            echo json_encode(['error' => 'Address not found']);
            return;
        }

        // Unset all defaults for this user
        $stmt = $db->prepare('UPDATE addresses SET is_default = FALSE WHERE user_id = ?');
        $stmt->execute([$userId]);

        // Set this address as default
        $stmt = $db->prepare('UPDATE addresses SET is_default = TRUE WHERE id = ? AND user_id = ?');
        $stmt->execute([$id, $userId]);

        // Return updated address
        $stmt = $db->prepare('SELECT * FROM addresses WHERE id = ?');
        $stmt->execute([$id]);
        $updatedAddress = $stmt->fetch();

        echo json_encode($updatedAddress);
        return;
    }

    http_response_code(404);
    echo json_encode(['error' => 'Route not found']);
}


