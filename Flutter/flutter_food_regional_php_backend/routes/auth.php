<?php

use Firebase\JWT\JWT;

require_once __DIR__ . '/../config/Database.php';

function handleAuthRoutes($method, $path) {
    $database = new Database();
    $db = $database->getConnection();

    // Register
    if ($method === 'POST' && $path === '/register') {
        $data = json_decode(file_get_contents("php://input"), true);
        
        if (!isset($data['name'], $data['email'], $data['password'])) {
            http_response_code(400);
            echo json_encode(['error' => 'Missing required fields']);
            return;
        }

        // Check if user exists
        $stmt = $db->prepare('SELECT * FROM users WHERE email = ?');
        $stmt->execute([$data['email']]);
        
        if ($stmt->rowCount() > 0) {
            http_response_code(400);
            echo json_encode(['error' => 'User already exists']);
            return;
        }

        // Hash password
        $passwordHash = password_hash($data['password'], PASSWORD_BCRYPT);
        
        // Create user
        $userId = generateUuid();
        $stmt = $db->prepare('INSERT INTO users (id, name, email, password_hash, phone) VALUES (?, ?, ?, ?, ?)');
        $stmt->execute([
            $userId,
            $data['name'],
            $data['email'],
            $passwordHash,
            $data['phone'] ?? null
        ]);

        // Generate token
        $secret = $_ENV['JWT_SECRET'] ?? 'your_secret_key_here';
        $token = JWT::encode(
            ['userId' => $userId, 'exp' => time() + (7 * 24 * 60 * 60)],
            $secret,
            'HS256'
        );

        http_response_code(201);
        echo json_encode([
            'token' => $token,
            'user' => [
                'id' => $userId,
                'name' => $data['name'],
                'email' => $data['email'],
                'phone' => $data['phone'] ?? null
            ]
        ]);
        return;
    }

    // Login
    if ($method === 'POST' && $path === '/login') {
        $data = json_decode(file_get_contents("php://input"), true);
        
        if (!isset($data['email'], $data['password'])) {
            http_response_code(400);
            echo json_encode(['error' => 'Missing required fields']);
            return;
        }

        // Find user
        $stmt = $db->prepare('SELECT * FROM users WHERE email = ?');
        $stmt->execute([$data['email']]);
        $user = $stmt->fetch();

        if (!$user) {
            http_response_code(400);
            echo json_encode(['error' => 'Invalid credentials']);
            return;
        }

        // Check password
        if (!password_verify($data['password'], $user['password_hash'])) {
            http_response_code(400);
            echo json_encode(['error' => 'Invalid credentials']);
            return;
        }

        // Generate token
        $secret = $_ENV['JWT_SECRET'] ?? 'your_secret_key_here';
        $token = JWT::encode(
            ['userId' => $user['id'], 'exp' => time() + (7 * 24 * 60 * 60)],
            $secret,
            'HS256'
        );

        echo json_encode([
            'token' => $token,
            'user' => [
                'id' => $user['id'],
                'name' => $user['name'],
                'email' => $user['email'],
                'phone' => $user['phone']
            ]
        ]);
        return;
    }

    // Get current user
    if ($method === 'GET' && $path === '/me') {
        $userId = AuthMiddleware::authenticate();

        $stmt = $db->prepare('SELECT id, name, email, phone FROM users WHERE id = ?');
        $stmt->execute([$userId]);
        $user = $stmt->fetch();

        if (!$user) {
            http_response_code(404);
            echo json_encode(['error' => 'User not found']);
            return;
        }

        echo json_encode($user);
        return;
    }

    http_response_code(404);
    echo json_encode(['error' => 'Route not found']);
}


