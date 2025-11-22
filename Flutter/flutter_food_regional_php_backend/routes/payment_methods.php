<?php

require_once __DIR__ . '/../config/Database.php';

function handlePaymentMethodRoutes($method, $path) {
    $database = new Database();
    $db = $database->getConnection();
    $userId = AuthMiddleware::authenticate();

    // Get user's payment methods
    if ($method === 'GET' && $path === '') {
        $stmt = $db->prepare('SELECT * FROM payment_methods WHERE user_id = ?');
        $stmt->execute([$userId]);
        $paymentMethods = $stmt->fetchAll();

        echo json_encode($paymentMethods);
        return;
    }

    // Create new payment method
    if ($method === 'POST' && $path === '') {
        $input = file_get_contents("php://input");
        error_log("Received payment method data: " . $input);
        $data = json_decode($input, true);
        
        if (!isset($data['type'], $data['title'], $data['subtitle'])) {
            http_response_code(400);
            echo json_encode(['error' => 'Missing required fields']);
            return;
        }

        $id = generateUuid();
        $stmt = $db->prepare('INSERT INTO payment_methods (id, user_id, type, title, subtitle) VALUES (?, ?, ?, ?, ?)');
        $stmt->execute([
            $id,
            $userId,
            $data['type'],
            $data['title'],
            $data['subtitle']
        ]);

        $stmt = $db->prepare('SELECT * FROM payment_methods WHERE id = ?');
        $stmt->execute([$id]);
        $newMethod = $stmt->fetch();

        http_response_code(201);
        echo json_encode($newMethod);
        return;
    }

    // Delete payment method
    if ($method === 'DELETE' && preg_match('/^\/([a-f0-9-]+)$/', $path, $matches)) {
        $id = $matches[1];

        $stmt = $db->prepare('DELETE FROM payment_methods WHERE id = ? AND user_id = ?');
        $stmt->execute([$id, $userId]);

        if ($stmt->rowCount() === 0) {
            http_response_code(404);
            echo json_encode(['error' => 'Payment method not found']);
            return;
        }

        echo json_encode(['message' => 'Payment method deleted successfully']);
        return;
    }

    http_response_code(404);
    echo json_encode(['error' => 'Route not found']);
}
